######## START: General Configuration ########

# Location of the container registry
REGISTRY=${REGISTRY:-""}

# Detect platform
PLATFORM=${CLUSTER:-unknown}

######## END: General Configuration ########

######## START: vLLM Configuration ########

# Location of models directory on the host filesystem.
HOST_MODELS_PATH=./models

# Pick the container image to use based on the detected platform
if [ "$PLATFORM"  = "hops" ] || [ "$PLATFORM" = "unknown" ]; then
    IMAGE_NAME="${REGISTRY}vllm/vllm-openai:v0.9.1"
    TARGET="cuda"
elif [ "$CLUSTER" = "eldorado" ]; then
    IMAGE_NAME="${REGISTRY}rocm/vllm:rocm6.4.1_vllm_0.9.1_20250702"
    TARGET="rocm"
fi

# Name to give to the container, so it is easy to reference later in scripts
CONTAINER_NAME="vllm"

# Short name to use in things like the Apptainer SIF file name
SHORT_NAME="vllm-${TARGET}"

# Environment variables to set in the container
declare -a ENV_VARS=(
    # Configure OpenMP to use one thread per vLLM process
    "OMP_NUM_THREADS=1"

    # Configure vLLM to disable Hugging Face fast transfer mode, since it has issues with web proxies and/or custom ssl certs
    "HF_HUB_ENABLE_HF_TRANSFER=0"

    # Tell vLLM to operate in offline mode (disconnected from internet)
    "HF_HUB_DISABLE_TELEMETRY=1"
    "VLLM_NO_USAGE_STATS=1"
    "DO_NOT_TRACK=1"
    "HF_DATASETS_OFFLINE=1"
    "TRANSFORMERS_OFFLINE=1"
    "HF_HUB_OFFLINE=1"

    # Disable the compile cache to save memory
    "VLLM_DISABLE_COMPILE_CACHE=1"

    # Try to make vLLM determistic
    "VLLM_ENABLE_V1_MULTIPROCESSING=0"
)

if [ "$TARGET" = "rocm" ]; then
    # vLLM with ROCm defaults to V0 engine, saying V1 is still experimental. It
    # seems to work fine, though, and is higher performing and uses less memory.
    # TODO: This should likey be a vLLM version dependent set (vllm 0.8.5
    #       defaults to V0, vLLM 0.9.1 defaults to V1)
    ENV_VARS+=("VLLM_USE_V1=1")

    # vLLM on ROCm says that TRITON is only partially supported, so should set
    # this. However, after setting it, it doesn't seem to have any effect, so
    # not sure if it does anything.
    ENV_VARS+=("VLLM_USE_TRITON_FLASH_ATTN=0")
fi

# Working directory to use when launching the vLLM container
WORK_DIR="/vllm-workspace/models"

# The container's entry point, run the vLLM command
CONTAINER_ENTRYPOINT="vllm"

declare -a PODMAN_ARGS=(
    "--rm"
    "--name=${CONTAINER_NAME}"
    "--network=host"
    "--ipc=host"
    "--entrypoint=${CONTAINER_ENTRYPOINT}"
    "--workdir=${WORK_DIR}"
    "--volume=${HOST_MODELS_PATH}:${WORK_DIR}"
)

# Apptainer args to mimick podman behavior, vllm needs to be able to write to /root and mapping host env vars messes up python
declare -a APPTAINER_ARGS=(
    "--fakeroot"
    "--writable-tmpfs"
    "--cleanenv"
    "--no-home"
    "--cwd ${WORK_DIR}"
    "--bind ${HOST_MODELS_PATH}:${WORK_DIR}"
    "--env HF_HOME=/root/.cache/huggingface"
)

# These are arguments to always add. They get tacked on last.
# TODO: If user has already set any of these args, don't tack them on (don't override the user).
declare -a CONTAINER_ARGS=()
if [ "$CLUSTER" = "eldorado" ]; then
    # Eldorado has MI300a accelerators, which only have HBM memory and it is
    # shared with the host CPU. So, you can't use all 128 GB of HBM. Some has
    # to be left for the OS and, if using a ramdisk to store the container
    # images, some for the vLLM container, which is large (30+ GB). It's
    # unclear if the container image hits one MI300a or if it is spread out
    # evenly among the 4x MI300a's in a node (numa balanced). My guess is it
    # hits one, which is bad. Conclusion is that it is best not to store
    # container images in a ramdisk, if possible, and something less than
    # gpu-memory-utilization=0.9 (the default) has to be used to leave some
    # memory for the host OS / Linux.
    CONTAINER_ARGS+=("--gpu-memory-utilization=0.7")
fi

# Try to make vLLM deterministic
CONTAINER_ARGS+=("--seed=12345")

######## END: vLLM Configuration ########

######## START: Podman Configuration ########

# Verify that Podman is available and configure it as needed
check_podman() {
    # Sanity check -- must have Podman
    if ! command -v podman &> /dev/null; then
        echo "This script requires Podman. Please install it."
        exit 1
    fi

    # Sanity check -- if in an interactive job on a compute node, need to clear the XDG env vars.
    if [ -n "$SLURM_JOB_ID" ]; then
        unset XDG_SESSION_ID
	unset XDG_RUNTIME_DIR
    fi

    # Sanity check -- if in an interactive job on a compute node, need to clear the XDG env vars.
    if [ -n "$FLUX_ENCLOSING_ID" ]; then
        unset XDG_SESSION_ID
	unset XDG_RUNTIME_DIR
    fi
}

# Podman magic args to get accelerator support in containers working
if [ "$TARGET" = "cuda" ]; then
    PODMAN_ARGS+=("--device nvidia.com/gpu=all")
elif [ "$TARGET" = "rocm" ]; then
    PODMAN_ARGS+=("--group-add=video --cap-add=SYS_PTRACE --device /dev/kfd --device /dev/dri --security-opt seccomp=unconfined")
fi

build_podman_command() {
    COMMAND="podman run "

    # Add Podman arguments
    for arg in "${PODMAN_ARGS[@]}"; do
        COMMAND+="$arg "
    done

    # Add environment variables, converting to Podman syntax
    for var in "${ENV_VARS[@]}"; do
        COMMAND+="--env \"$var\" "
    done

    # Add the container image name
    COMMAND+="${IMAGE_NAME} "

    # Add arguments passed in by the caller
    for arg in "$@"; do
        COMMAND+="$arg "
    done

    # Add default container arguments
    for arg in "${CONTAINER_ARGS[@]}"; do
        COMMAND+="$arg "
    done

    echo $COMMAND
}

######## END: Podman Configuration ########

######## START: Apptainer Configuration ########

check_apptainer() {
    # Sanity check -- must have Apptainer
    if ! command -v apptainer &> /dev/null; then
        echo "This script requires Apptainer. Please install it."
        exit 1
    fi

    if [ "$TARGET" = "rocm" ]; then
        # Apptainer "--rocm" option depends on rocm being available on host,
        # otherwise this warning message is printed:
        #    "WARNING: Could not find any rocm files on this host!"
        if ! module list 2>&1 | grep rocm; then
            module load rocm/6.4.0
        fi
    fi
}

# If it doesn't already exist, build the Apptainer SIF file from the OCI container image
build_apptainer_image() {
    if [ ! -f "${SHORT_NAME}.sif" ]; then
        export APPTAINER_CACHEDIR=./apptainer_cachedir
        apptainer build --force ${SHORT_NAME}.sif docker://$IMAGE_NAME
    fi
}

# Apptainer magic args to get accelerator support in containers working
if [ "$TARGET" = "cuda" ]; then
    APPTAINER_ARGS+=("--nv")
elif [ "$TARGET" = "rocm" ]; then
    APPTAINER_ARGS+=("--rocm")
fi

build_apptainer_command() {
    COMMAND="apptainer exec "

    # Add Apptainer arguments
    for arg in "${APPTAINER_ARGS[@]}"; do
        COMMAND+="$arg "
    done

    # Add environment variables, converting to Podman syntax
    for var in "${ENV_VARS[@]}"; do
        COMMAND+="--env \"$var\" "
    done

    # Add the container image name
    COMMAND+="${SHORT_NAME}.sif "

    # Add entrypoint
    COMMAND+="${CONTAINER_ENTRYPOINT} "

    # Add arguments passed in by the caller
    for arg in "$@"; do
        COMMAND+="$arg "
    done

    # Add default container arguments
    for arg in "${CONTAINER_ARGS[@]}"; do
        COMMAND+="$arg "
    done

    echo $COMMAND
}

######## END: Apptainer Configuration ########
