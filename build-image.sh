#!/bin/bash

SB_NAME="Source OS"
SB_VERSION="$(git describe --tags --always)"

rm -f *-image-*.img.xz

docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm:latest \
    build \
    -var "SB_NAME=${SB_NAME}" \
    -var "SB_VERSION=${SB_VERSION}" \
    pi.json
