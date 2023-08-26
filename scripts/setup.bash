#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
BUILD_DIR=${SCRIPT_DIR}/../build

mkdir -p ${BUILD_DIR}

docker build . -f ${SCRIPT_DIR}/../docker/Dockerfile -t ownwar-deps-builder:latest
docker run --rm --entrypoint cat ownwar-deps-builder:latest \
    /app/godot/bin/godot.x11.tools.64 >${BUILD_DIR}/Godot_v3.3.5-modified_x11.64
