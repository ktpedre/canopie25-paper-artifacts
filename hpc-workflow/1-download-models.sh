#!/bin/bash -e

# Load common configuration variables and functions
. common.sh

# Sanity checks
if [ -n "$SLURM_JOB_ID" ]; then
  unset XDG_RUNTIME_DIR
  unset XDG_SESSION_ID
fi

if [ -z "${HF_USERNAME}" ]; then
    echo "Error: HF_USERNAME is not set. Please set it."
    exit 1
fi

if [ -z "${HF_TOKEN}" ]; then
    echo "Error: HF_TOKEN is not set. Please set it."
    exit 1
fi

# Make directory to store the downloaded models
mkdir -p ./${MODEL_DIR}

echo "### Hostname: $(hostname)"

##############################################################################
# First pull the container image, to get it out of the way
##############################################################################
echo "### Container Image: $GIT_CONTAINER_IMAGE"
echo "### Pulling Container Image, Start Time: $(date)"
podman pull -q $GIT_CONTAINER_IMAGE
echo "### Done, End Time: $(date)"

# Download the models
for model in "${models[@]}"; do
    OUTPUT_DIR="${MODEL_DIR}/$model"
    OUTPUT_PARENT_DIR="${MODEL_DIR}/${model%%/*}"
    mkdir -p ${OUTPUT_PARENT_DIR}

    echo "### Downloading $model to $OUTPUT_DIR"
    if [ -d "$OUTPUT_DIR" ]; then
        echo "  Directory already exists, skipping."
    else
        echo "### Doing Git Clone, Start Time: $(date)"
        podman run \
          -v ./${OUTPUT_PARENT_DIR}:/git/${OUTPUT_PARENT_DIR} \
          --workdir /git/${OUTPUT_PARENT_DIR} \
          ${GIT_CONTAINER_IMAGE} \
            clone https://${HF_USERNAME}:${HF_TOKEN}@huggingface.co/${model}
        echo "### Done, End Time: $(date)"
    fi
done
