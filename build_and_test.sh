#!/bin/sh -e

# Build Docker image for a complete torchvid environment
docker build -t downstroke_image .

# Run torchvid tests in a container created from the image
docker run --rm -it downstroke_image \
  busted --cpath="./build/?.so" test
