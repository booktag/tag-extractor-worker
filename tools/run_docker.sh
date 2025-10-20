#!/bin/bash
set -e

IMAGE_NAME=extractor-worker-image
TAG=latest

source resolve_path.sh

# move to project root (one level up from tools)
cd "$(dirname "$0")/.."
source .env
set +a
VOLUME_FOLDER=/app
# Normalize paths
ARTIFACTS_ROOT_PATH="$(resolve_path "$ARTIFACTS_ROOT_PATH" "$VOLUME_FOLDER")"
DICTIONARIES_PATH="$(resolve_path "$DICTIONARIES_PATH" "$VOLUME_FOLDER")"

echo "Resolved ARTIFACTS_ROOT_PATH=$ARTIFACTS_ROOT_PATH"
echo "Resolved DICTIONARIES_PATH=$DICTIONARIES_PATH"

echo "Running $IMAGE_NAME:$TAG ..."

export MSYS_NO_PATHCONV=1 #disable "helpful" path interpolations

docker run --rm \
       -v "$(pwd -W)":"$VOLUME_FOLDER" \
       --env-file .env \
       -e ARTIFACTS_ROOT_PATH="$ARTIFACTS_ROOT_PATH" \
       -e DICTIONARIES_PATH="$DICTIONARIES_PATH" \
       $IMAGE_NAME:$TAG

#docker run -it \
#       -v "$(pwd -W)":"$VOLUME_FOLDER" \
#       --env-file .env \
#       -e ARTIFACTS_ROOT_PATH="$ARTIFACTS_ROOT_PATH" \
#       -e DICTIONARIES_PATH="$DICTIONARIES_PATH" \
#       $IMAGE_NAME:$TAG sh

unset MSYS_NO_PATHCONV