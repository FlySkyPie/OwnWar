#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
BUILD_DIR=${SCRIPT_DIR}/../build
GAME_PROJECT_DIR=${SCRIPT_DIR}/../OwnWar

mkdir -p ${BUILD_DIR}

docker build . -f ${SCRIPT_DIR}/../docker/Dockerfile -t ownwar-deps-builder:latest

if [ $? -ne 0 ]; then
    exit 1
fi

if [ ! -f "${BUILD_DIR}/Godot_v3.3.5-modified_x11.64" ]; then
    echo "Extracting Godot engine..."
    docker run --rm --entrypoint cat ownwar-deps-builder:latest \
        /build/Godot_v3.3.5-modified_x11.64 >${BUILD_DIR}/Godot_v3.3.5-modified_x11.64
else
    echo "Godot engine exists."
fi

echo "Extracting native libraries..."
docker run --rm --entrypoint cat ownwar-deps-builder:latest \
    /build/libgd_3d_batcher.so >${BUILD_DIR}/libgd_3d_batcher.so
docker run --rm --entrypoint cat ownwar-deps-builder:latest \
    /build/libhterrain.so >${BUILD_DIR}/libhterrain.so
docker run --rm --entrypoint cat ownwar-deps-builder:latest \
    /build/libownwar.so >${BUILD_DIR}/libownwar.so

cp ${BUILD_DIR}/*.so ${GAME_PROJECT_DIR}/gd/lib/.
