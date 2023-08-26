FROM ubuntu:20.04 as rust-base
WORKDIR /app

RUN apt update
RUN apt install -y \
    git \
    build-essential \
    curl \
    python3

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup install nightly-2021-07-29
RUN rustup default nightly-2021-07-29

FROM rust-base as godot_rapier3d-builder
WORKDIR /app
RUN git clone https://github.com/Demindiro/godot_rapier3d

RUN cd godot_rapier3d/module && python3 generate.py

FROM rust-base as native-library-builder
WORKDIR /app

ARG TARGET_LINUX=x86_64-unknown-linux-gnu

RUN apt install -y libclang-dev

COPY --from=godot_rapier3d-builder /app/godot_rapier3d godot_rapier3d
COPY OwnWar/gdn gdn

RUN cd gdn/gd_3d_batcher && cargo build --release --target ${TARGET_LINUX}
RUN cd gdn/hterrain && cargo build --release --target ${TARGET_LINUX}

FROM rust-base as godot-builder
WORKDIR /app
RUN git clone --depth 1 -b 3.3 https://github.com/godotengine/godot

ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y \
    build-essential \
    scons \
    pkg-config \
    libx11-dev \
    libxcursor-dev \
    libxinerama-dev \
    libgl1-mesa-dev \
    libglu-dev \
    libasound2-dev \
    libpulse-dev \
    libudev-dev \
    libxi-dev \
    libxrandr-dev

COPY --from=godot_rapier3d-builder /app/godot_rapier3d/module godot/modules/pluggable_physics

COPY OwnWar/patch/godot/vehicle_body.patch vehicle_body.patch
RUN cd godot && git apply ../vehicle_body.patch

RUN cd godot && scons platform=x11 -j$(nproc)

FROM rust-base as expoter
WORKDIR /build

ARG TARGET_LINUX=x86_64-unknown-linux-gnu

COPY --from=godot-builder \
    /app/godot/bin/godot.x11.tools.64 \
    Godot_v3.3.5-modified_x11.64

COPY --from=native-library-builder \
    /app/gdn/gd_3d_batcher/target/${TARGET_LINUX}/release/libgd_3d_batcher.so .
COPY --from=native-library-builder \
    /app/gdn/hterrain/target/${TARGET_LINUX}/release/libhterrain.so .
