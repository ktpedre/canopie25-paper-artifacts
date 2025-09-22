#!/bin/bash

# Load common configuration variables and functions
. common.sh

# Sanity checks
if [ -n "$SLURM_JOB_ID" ]; then
  unset XDG_RUNTIME_DIR
  unset XDG_SESSION_ID
fi

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    echo "Error: AWS_ACCESS_KEY_ID is not set. Please set it."
    exit 1
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo "Error: AWS_SECRET_ACCESS_KEY is not set. Please set it."
    exit 1
fi

if [ -z "${AWS_ENDPOINT_URL}" ]; then
    echo "Error: AWS_ENDPOINT_URL is not set. Please set it."
    exit 1
fi

if [ -z "${S3_TARGET_BUCKET}" ]; then
    echo "Error: S3_TARGET_BUCKET is not set. Please set it."
    exit 1
fi

echo "### Hostname: $(hostname)"

##############################################################################
# First pull the container image, to get it out of the way
##############################################################################
echo "### Container Image: $AWSCLI_CONTAINER_IMAGE"
echo "### Pulling Container Image, Start Time: $(date)"
podman pull -q $AWSCLI_CONTAINER_IMAGE
echo "### Done, End Time: $(date)"

# Sync the models to local s3 object storage
for model in "${models[@]}"; do
    echo "### Doing S3 Sync Upload of ${model}, Start Time: $(date)"
    podman run \
        -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
        -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
        -e AWS_ENDPOINT_URL=${AWS_ENDPOINT_URL} \
        -e AWS_REQUEST_CHECKSUM_CALCULATION="when_required" \
        -e AWS_MAX_ATTEMPTS=10 \
        -v ./${MODEL_DIR}:/aws/${MODEL_DIR} \
        ${AWSCLI_CONTAINER_IMAGE} \
            s3 sync ./${MODEL_DIR}/${model} s3://${S3_TARGET_BUCKET}/${model} --exclude ".git*"
        echo "### Done, End Time: $(date)"
done
