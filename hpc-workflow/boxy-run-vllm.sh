#!/bin/bash -e

# Load prototype 'boxy' tool for deploying containers with multiple container runtimes.
# This is just a bunch of bash scripting for the prototype, the actual tool would be
# written in Python/Rust/something and have use a modular 'box' definition scheme to
# define the containerized application/service and a modular 'location' definition to
# define particulars for the target site / container cluster execution environment.
. common_boxy.sh

# Pick which container runtime to use, podman or apptainer
CONTAINER_RUNTIME="podman"
#CONTAINER_RUNTIME="apptainer"

if [ "$CONTAINER_RUNTIME" = "podman" ]; then
    # Sanity check, must have Podman
    check_podman

    # Build the Podman command to deploy the container
    cmd=$(build_podman_command "$@")

elif [ "$CONTAINER_RUNTIME" = "apptainer" ]; then
    # Sanity check, must have Apptainer
    check_apptainer

    # Sanity check, must have SIF file.
    # If we don't, this will auto-build the Apptainer SIF file from the upstream image.
    build_apptainer_image

    # Build the Apptainer command to deploy the container
    cmd=$(build_apptainer_command "$@")

else
    echo "Container runtime '${CONTAINER_RUNTIME}' is not supported."
    exit 1
fi

echo "### Running Command:"
echo "    $cmd"

# Deploy the container
echo "### Start Time: $(date)"
eval $cmd
