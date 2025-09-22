#!/bin/bash -e

# Sanity check
if [ -z "${VLLM_API_KEY}" ]; then
    echo "Error: VLLM_API_KEY is not set. Please set it."
    exit 1
fi

# Issue the query
curl https://vllm-bench.openshift.server.location.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${VLLM_API_KEY}" \
  -d '{
     "model": "RedHatAI/Llama-4-Scout-17B-16E-Instruct-quantized.w4a16",
     "messages": [{"role": "user", "content": "How long would it take to get from Earth to Mars traveling on a rocket when Mars is at its closest distance to Earth?"}],
     "temperature": 0.7
   }'
