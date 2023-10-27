#!/bin/bash

# Define the repository URL
REPO_URL="https://api.github.com/repos/LostRuins/koboldcpp/releases/latest"

# Get the latest release tag from the GitHub repository
RELEASE_TAG=$(curl -s $REPO_URL | grep 'tag_name' | cut -d\" -f4)

# Define clone argument for Docker
if [ -z "$RELEASE_TAG" ]; then
  echo "Failed to get the latest release tag. Exiting..."
  exit 1
fi

echo $RELEASE_TAG

CLONE_ARG="--branch $RELEASE_TAG"

# Build the Docker image
docker build --build-arg clone_arg="$CLONE_ARG" -t noneabove1182/koboldcpp-gpu .

# Check if Docker build was successful
if [ $? -ne 0 ]; then
  echo "Docker build failed. Exiting..."
  exit 1
fi

# Tag the Docker image
docker tag noneabove1182/koboldcpp-gpu:latest noneabove1182/koboldcpp-gpu:$RELEASE_TAG

# Push the Docker images
docker push noneabove1182/koboldcpp-gpu:latest
docker push noneabove1182/koboldcpp-gpu:$RELEASE_TAG
