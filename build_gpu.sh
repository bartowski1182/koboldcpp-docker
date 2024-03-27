#!/bin/bash

# Define the repository URL
REPO_URL="https://api.github.com/repos/LostRuins/koboldcpp/commits/main"

LATEST_COMMIT=$(curl -s $REPO_URL | grep 'sha' | cut -d\" -f4 | head -n 1)

echo $LATEST_COMMIT

# Build the Docker image
docker build --build-arg commit="$LATEST_COMMIT" -t koboldcpp-gpu .

# Check if Docker build was successful
if [ $? -ne 0 ]; then
  echo "Docker build failed. Exiting..."
  exit 1
fi
