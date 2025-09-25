#!/bin/bash -e

# Load common configuration variables and functions
. common.sh

# Sanity checks
if [ -n "$SLURM_JOB_ID" ]; then
  unset XDG_RUNTIME_DIR
  unset XDG_SESSION_ID
fi

# Sanity check -- if in an interactive job on a compute node, need to clear the XDG env vars.
if [ -n "$FLUX_ENCLOSING_ID" ]; then
  unset XDG_SESSION_ID
  unset XDG_RUNTIME_DIR
fi

if [ -z "${SERVER_NODE}" ]; then
    echo "Error: SERVER_NODE is not set. Please set it."
    exit 1
fi

echo "### Hostname: $(hostname)"

batch_sizes=(1 2 4 8 16 32 64 128 256 512 1024)
for batch_size in "${batch_sizes[@]}"; do

    echo "### Running batch size ${batch_size}, server_node=${SERVER_NODE}, Start Time: $(date)"

    if [ "$CLUSTER" = "hops" ]; then
        # Use AMD's vLLM container because it has the full vllm app included, including
        # all dependencies needed by the benchmark_serving.py script. The official vLLM
        # container does not. TODO: figure out a better long term option
        podman run \
            -ti --rm \
            --network=host \
            --ipc=host \
            --volume "./models:/vllm-workspace/models" \
            --volume "./datasets:/vllm-workspace/models/datasets" \
            --workdir="/vllm-workspace/models" \
            --env "HF_HUB_DISABLE_TELEMETRY=1" \
            --env "VLLM_NO_USAGE_STATS=1" \
            --env "DO_NOT_TRACK=1" \
            --env "HF_DATASETS_OFFLINE=1" \
            --env "TRANSFORMERS_OFFLINE=1" \
            --env "HF_HUB_OFFLINE=1" \
            --env "OMP_NUM_THREADS=1" \
	    --env "VLLM_DISABLE_COMPILE_CACHE=1" \
            --env "VLLM_USE_TRITON_FLASH_ATTN=0" \
            --env "VLLM_V1_USE_PREFILL_DECODE_ATTENTION=1" \
            --entrypoint="/bin/bash" \
            --env "no_proxy=${no_proxy},${SERVER_NODE}" \
            rocm/vllm:rocm6.4.1_vllm_0.9.1_20250702 \
                -c "python3 /app/vllm/benchmarks/benchmark_serving.py --backend openai-chat --endpoint /v1/chat/completions --base-url http://${SERVER_NODE}:8000 --dataset-name=sharegpt --dataset-path=./datasets/ShareGPT_V3_unfiltered_cleaned_split.json --model meta-llama/Llama-4-Scout-17B-16E-Instruct --seed=12345 --max-concurrency ${batch_size}"
    elif [ "$CLUSTER" = "eldorado" ]; then
	# This special case is needed because on Eldorado, the vLLM container auto-detects
	# it is running on a ROCM platform and tries to initialize ROCM. So, we need to pass
	# through the GPUs. TODO: Eliminate the need for this special case.
        podman run \
            -ti --rm \
            --device=/dev/kfd \
            --device=/dev/dri \
            --device=/dev/mem \
            --group-add render \
            --privileged \
            --cap-add=CAP_SYS_ADMIN \
            --cap-add=SYS_PTRACE \
            --security-opt seccomp=unconfined \
            --network=host \
            --ipc=host \
            --volume "./models:/vllm-workspace/models" \
            --volume "./datasets:/vllm-workspace/models/datasets" \
            --workdir="/vllm-workspace/models" \
            --env "HF_HUB_DISABLE_TELEMETRY=1" \
            --env "VLLM_NO_USAGE_STATS=1" \
            --env "DO_NOT_TRACK=1" \
            --env "HF_DATASETS_OFFLINE=1" \
            --env "TRANSFORMERS_OFFLINE=1" \
            --env "HF_HUB_OFFLINE=1" \
            --env "OMP_NUM_THREADS=1" \
	    --env "VLLM_DISABLE_COMPILE_CACHE=1" \
            --env "VLLM_USE_TRITON_FLASH_ATTN=0" \
            --env "VLLM_V1_USE_PREFILL_DECODE_ATTENTION=1" \
            --entrypoint="/bin/bash" \
            --env "no_proxy=${no_proxy},${SERVER_NODE}" \
            rocm/vllm:rocm6.4.1_vllm_0.9.1_20250702 \
                -c "python3 /app/vllm/benchmarks/benchmark_serving.py --backend openai-chat --endpoint /v1/chat/completions --base-url http://${SERVER_NODE}:8000 --dataset-name=sharegpt --dataset-path=./datasets/ShareGPT_V3_unfiltered_cleaned_split.json --model meta-llama/Llama-4-Scout-17B-16E-Instruct --seed=12345 --max-concurrency ${batch_size}"

    else
        echo "Unknown platform"
        exit 1
    fi

    echo "### Done, End Time: $(date)"
    echo "###"
done
