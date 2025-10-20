#!/bin/bash
set -e

IMAGE_NAME=extractor-worker-image
TAG=latest

# move to project root (one level up from tools)
cd "$(dirname "$0")/.."

echo "Building $IMAGE_NAME:$TAG ..."
docker build -t $IMAGE_NAME:$TAG .
