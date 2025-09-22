# Local directory to store the downloaded models
MODEL_DIR="./models"

# List of models to download
models=(
  # Llama 4 Scout Instruct, as shipped by Meta, fits on 4x 80 GB GPUs
  "meta-llama/Llama-4-Scout-17B-16E-Instruct"

  # Quantized version of Llama4 Scout Instruct, fits on 2x 80 GB GPUs
  "RedHatAI/Llama-4-Scout-17B-16E-Instruct-quantized.w4a16"

  # Llama 3.1 405B Instruct, as shipped by Meta, fits on 16x 80 GB GPUs
  "meta-llama/Llama-3.1-405B-Instruct"
)

# Container images
GIT_CONTAINER_IMAGE="alpine/git:latest"
AWSCLI_CONTAINER_IMAGE="amazon/aws-cli:latest"
