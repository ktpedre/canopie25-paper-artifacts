#!/bin/bash -e

if [ "$CLUSTER" = "hops" ]; then
    salloc --nodes=2 --gpus-per-node=4 --time=2-00:00:00
elif [ "$CLUSTER" = "eldorado" ]; then
    flux alloc --job-name=vllm --nodes=2 --exclusive --queue=pbatch --time-limit=2d
else
    echo "Unknown platform"
    exit 1
fi
