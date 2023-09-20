#!/bin/sh

imageName="cdm-agency-rabbit"
version="latest"

# Build the container
docker build -t $imageName:$version . --no-cache
