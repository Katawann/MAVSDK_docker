FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

ARG TARGETPLATFORM

# Install dependencies
RUN apt-get update \
    && apt-get -y --quiet --no-install-recommends install \
        build-essential \
        ca-certificates \ 
        git \ 
        sudo \ 
        wget \
        cmake \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Install MAVSDK prebuilt C++ library
ENV MAVSDK_VERSION=1.0.8
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then MAVSDK_PKG=ubuntu20.04_amd64; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then MAVSDK_PKG=debian11_armv7; \
    else MAVSDK_PKG=ubuntu20.04_amd64; fi \
    && wget --no-check-certificate https://github.com/mavlink/MAVSDK/releases/download/v${MAVSDK_VERSION}/libmavsdk-dev_${MAVSDK_VERSION}_${MAVSDK_PKG}.deb \
    && sudo dpkg -i libmavsdk-dev_${MAVSDK_VERSION}_${MAVSDK_PKG}.deb \
    && sudo rm libmavsdk-dev_${MAVSDK_VERSION}_${MAVSDK_PKG}.deb

# Run MAVSDK takeoff example
RUN git clone https://github.com/mavlink/MAVSDK.git --recursive \
    && cd MAVSDK/examples/takeoff_and_land/ \
    && cmake -Bbuild -H. \
    && cmake --build build
