# syntax=docker/dockerfile:1.6

########################
# Stage 1: Build-Stage #
########################
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# Build-Tools + Dev-Libs für alle gewünschten Codecs/Features
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake build-essential cmake git-core libtool pkg-config texinfo \
    yasm nasm meson ninja-build \
    libass-dev libfreetype6-dev libfontconfig1-dev \
    libmp3lame-dev libopus-dev libvorbis-dev libvpx-dev \
    libx264-dev \
    libgnutls28-dev \
    libnuma-dev \
    libfftw3-dev libsamplerate0-dev libsndfile1-dev \
    wget ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN mkdir -p /root/ffmpeg_sources /root/ffmpeg_build /root/bin

# Rubberband (per meson) – für Zeit-/Pitch-Stretching
WORKDIR /root/ffmpeg_sources
RUN git clone https://github.com/breakfastquay/rubberband.git && \
    cd rubberband && \
    meson setup builddir --prefix=/root/ffmpeg_build --libdir=lib && \
    ninja -C builddir && ninja -C builddir install

# x265 (statisch)
WORKDIR /root/ffmpeg_sources
RUN wget -O x265.tar.bz2 "https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2" && \
    tar xjvf x265.tar.bz2 && \
    cd multicoreware*/build/linux && \
    cmake -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="/root/ffmpeg_build" \
    -DENABLE_SHARED=off ../../source && \
    make -j"$(nproc)" && make install

# NVENC-Header (Video Codec SDK)
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /tmp/nvch && \
    make -C /tmp/nvch && make -C /tmp/nvch install

# FFmpeg (NVENC/NVDEC/CUDA/libnpp + alle gewünschten Codecs)
WORKDIR /root/ffmpeg_sources
RUN wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar xjvf ffmpeg-snapshot.tar.bz2
WORKDIR /root/ffmpeg_sources/ffmpeg

# Wichtig:
#  - --enable-gnutls für HTTPS
#  - --enable-cuda / --enable-cuda-nvcc / --enable-nvenc / --enable-nvdec
#  - --enable-libnpp (erfordert zur Laufzeit libnpp*.so – s. Stage 2)
RUN PKG_CONFIG_PATH="/root/ffmpeg_build/lib/pkgconfig" \
    ./configure \
    --prefix="/root/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I/root/ffmpeg_build/include -I/usr/local/cuda/include" \
    --extra-ldflags="-L/root/ffmpeg_build/lib -L/usr/local/cuda/lib64/stubs -L/usr/local/cuda/lib64" \
    --bindir="/root/bin" \
    --enable-nonfree --enable-gpl \
    --enable-gnutls \
    --enable-librubberband \
    --enable-libass --enable-libfreetype --enable-libfontconfig \
    --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-cuda --enable-cuda-nvcc --enable-nvenc --enable-nvdec \
    --enable-libnpp \
    && make -j"$(nproc)" && make install && hash -r \
    && strip /root/bin/ffmpeg /root/bin/ffprobe || true

# Kleine Laufzeit-Bündelung aus dem Build (falls FFmpeg private libs erzeugt hat)
RUN mkdir -p /root/ffmpeg_runtime/usr/local/lib && \
    [ -d /root/ffmpeg_build/lib ] && cp -a /root/ffmpeg_build/lib/* /root/ffmpeg_runtime/usr/local/lib/ || true

# Benötigte CUDA NPP-Libs für --enable-libnpp ins Runtime bündeln (sonst fehlt libnpp*.so zur Laufzeit)
# (Wir kopieren NUR libnpp*.so*, nicht die Toolchain)
RUN mkdir -p /root/ffmpeg_runtime/usr/local/cuda/lib64 && \
    cp -a /usr/local/cuda/lib64/libnpp*.so* /root/ffmpeg_runtime/usr/local/cuda/lib64/ || true

#########################
# Stage 2: Runtime-Base #
#########################
FROM ranktotop/cudadocker:11.8_base

# Runtime-Libs für die dynamisch gelinkten Codecs/Filter (klein halten, aber vollständig)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libass9 libfreetype6 libfontconfig1 \
    libmp3lame0 libopus0 libvorbis0a libvorbisenc2 \
    libvpx7 \
    libgnutls30 \
    libfftw3-3 libsamplerate0 libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# FFmpeg-Binaries
COPY --from=build /root/bin/ffmpeg  /usr/local/bin/ffmpeg
COPY --from=build /root/bin/ffprobe /usr/local/bin/ffprobe

# FFmpeg-eigene libs (falls vorhanden) + NPP-Libs
COPY --from=build /root/ffmpeg_runtime/ //

# Loader-Cache aktualisieren
RUN ldconfig || true
