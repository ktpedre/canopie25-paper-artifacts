#!/bin/bash -e

# Sanity check
if [ -z "${VLLM_API_KEY}" ]; then
    echo "Error: VLLM_API_KEY is not set. Please set it."
    exit 1
fi

helm install vllm ./helm-chart --set apiKey=$VLLM_API_KEY
