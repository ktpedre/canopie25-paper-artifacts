# vLLM Helm Chart Adapted for CANOPIE25 paper

This is the upstream vLLM Helm chart slightly adapted for use in the CANOPIE25
paper "Experience Deploying Containerized GenAI Services at an HPC Center".

This is derived from the upstream vLLM repo at
https://github.com/vllm-project/vllm.git with the Helm chart that this repo is
based on in the examples/online_serving/chart-helm directory.

Modifications include changes to ingress, the addition of a persistent storage
config, and the ability to download from public s3 buckets.

TODO: Merge changes upstream.
