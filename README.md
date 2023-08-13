# robot-image

Packer scripts to build SourceBots robot image

## Requirements

- Docker
- This repository cloned

## Usage

Simply run the `./build-image.sh` script. Packer will download all needed files and save the output image to `Source OS-image-<GIT-TAG/HASH>.img.xz`, ready for distribution. Running `./build-image.sh fast` will skip the compression step, which greatly speeds up the build process.
