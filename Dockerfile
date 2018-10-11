FROM debian:testing AS base

RUN apt update && \
    apt install -y -q \
        wget \
        xz-utils \
        tar

FROM base AS binutils

ARG BINUTILS_VERSION=2.31.1

RUN wget http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz && \
    tar -xJf binutils-${BINUTILS_VERSION}.tar.xz && \
    mv binutils-${BINUTILS_VERSION} binutils

FROM base AS gcc

ARG GCC_VERSION=8.2.0

RUN wget ftp://ftp.lip6.fr/pub/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz && \
    tar -xJf gcc-${GCC_VERSION}.tar.xz && \
    mv gcc-${GCC_VERSION} gcc

FROM base

COPY --from=binutils binutils/ /binutils
COPY --from=gcc gcc /gcc

RUN apt update && \
    apt install -y -q \
        build-essential \
        bison \
        flex \
        libgmp3-dev \
        libmpc-dev \
        libmpfr-dev \
        texinfo \
        libcloog-isl-dev \
        libisl-0.18-dev \
        file \
        grub-common \
        grub-pc-bin \
        xorriso

ENV PREFIX="/opt/cross" \
    TARGET=i686-elf

ENV PATH="$PREFIX/bin:$PATH"

RUN mkdir build-binutils build-gcc

WORKDIR /build-binutils
RUN ../binutils/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \  
    make -j5 && \
    make -j5 install

WORKDIR /build-gcc
RUN ../gcc/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers && \
    make -j5 all-gcc && \
    make -j5 all-target-libgcc && \
    make -j5 install-gcc && \
    make -j5 install-target-libgcc
