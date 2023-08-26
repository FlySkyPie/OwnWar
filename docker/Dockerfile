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

RUN cd godot && scons platform=x11 -j$(nproc)
