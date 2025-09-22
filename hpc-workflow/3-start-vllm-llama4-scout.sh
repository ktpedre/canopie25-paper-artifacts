#!/bin/bash -e

./boxy-run-vllm.sh \
    "serve" \
    "meta-llama/Llama-4-Scout-17B-16E-Instruct" \
    "--tensor_parallel_size=4" \
    "--disable-log-requests" \
    "--max_model_len=65536" \
    "--override-generation-config='{\"attn_temperature_tuning\": true}'"
