#!/bin/bash

set -ev

export GCC_VERSION=8.2.0
export BINUTILS_VERSION=2.31.1

for TARGET in i686-elf x86_64-elf; do
    docker build \
    	--build-arg BUILD_TARGET=${TARGET} \
	--build-arg GCC_VERSION=${GCC_VERSION} \
	--build-arg BINUTILS_VERSION=${BINUTILS_VERSION} \
	. --tag thomasruiz/cross-compile:${TARGET}-${BINUTILS_VERSION}-${GCC_VERSION}
done
