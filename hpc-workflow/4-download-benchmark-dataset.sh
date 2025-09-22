#!/bin/bash -e

echo "### Downloading ShareGPT dataset, Start Time: $(date)"
mkdir -p ./datasets
cd datasets
wget https://huggingface.co/datasets/anon8231489123/ShareGPT_Vicuna_unfiltered/resolve/main/ShareGPT_V3_unfiltered_cleaned_split.json
echo "### Done, End Time: $(date)"
