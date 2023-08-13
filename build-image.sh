#!/bin/bash
if [ $1 == "fast" ]; then
    SKIP_COMPRESSION="true"
else
    SKIP_COMPRESSION="false"
fi

SB_NAME="Source OS"
SB_VERSION="$(git describe --tags --always)"

rm -f *-image-*.img.xz
rm -f *-image-*.img

docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm:latest \
    build \
    -var "SB_NAME=${SB_NAME}" \
    -var "SB_VERSION=${SB_VERSION}" \
    -var "SKIP_COMPRESSION=${SKIP_COMPRESSION}" \
    pi.json
