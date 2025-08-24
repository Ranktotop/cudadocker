# syntax=docker/dockerfile:1.6

########################
# Stage 1: Build-Stage #
########################
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# Build-Tools + Dev-Libs (NDI + Codecs + HTTPS)
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake build-essential cmake git-core libtool pkg-config texinfo \
    yasm nasm \
    libass-dev libfreetype6-dev libfontconfig1-dev \
    libmp3lame-dev libopus-dev libvorbis-dev libvpx-dev \
    libx264-dev libx265-dev libfdk-aac-dev \
    libgnutls28-dev zlib1g-dev \
    libnuma-dev \
    wget ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/ffmpeg-build
ARG NDI_VERSION=6

# NDI SDK (erwarte NDI_SDK${NDI_VERSION}.tar.gz im selben Ordner wie dieses Dockerfile)
COPY NDI_SDK${NDI_VERSION}.tar.gz /tmp/NDI_SDK${NDI_VERSION}.tar.gz
RUN mkdir -p /opt/ndi-sdk && \
    tar --strip-components=1 -xzf /tmp/NDI_SDK${NDI_VERSION}.tar.gz -C /opt/ndi-sdk && \
    echo "/opt/ndi-sdk/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/ndi.conf && ldconfig

# FFmpeg Quelle + (optional) NDI Patch
# Falls du einen Patch brauchst, lege ihn als "ndi-support.patch" neben dieses Dockerfile.
RUN wget -O ffmpeg-6.1.1.tar.gz https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n6.1.1.tar.gz && \
    tar -xzf ffmpeg-6.1.1.tar.gz && mv FFmpeg-n6.1.1 ffmpeg
WORKDIR /tmp/ffmpeg-build/ffmpeg
# (Optional) Patch einspielen, falls vorhanden:
# COPY ndi-support.patch ./ndi-support.patch
# RUN patch -p1 < ndi-support.patch

# FFmpeg konfigurieren (NDI+NVENC+Codecs; dynamisch gelinkt)
RUN PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig" \
    ./configure \
    --prefix="/opt/ffmpeg-ndi" \
    --extra-cflags="-I/opt/ndi-sdk/include -I/usr/local/cuda/include" \
    --extra-ldflags="-L/opt/ndi-sdk/lib/x86_64-linux-gnu -L/usr/local/cuda/lib64 -Wl,-rpath,/opt/ndi-sdk/lib/x86_64-linux-gnu" \
    --bindir="/opt/ffmpeg-ndi/bin" \
    --libdir="/opt/ffmpeg-ndi/lib" \
    --enable-gpl --enable-nonfree \
    --enable-gnutls \
    --enable-libndi_newtek \
    --enable-libass --enable-libfreetype --enable-libfontconfig \
    --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx \
    --enable-libx264 --enable-libx265 --enable-libfdk-aac \
    --enable-cuda --enable-nvenc --enable-nvdec --enable-libnpp \
    && make -j"$(nproc)" && make install \
    && strip /opt/ffmpeg-ndi/bin/ffmpeg /opt/ffmpeg-ndi/bin/ffprobe || true

#########################
# Stage 2: Runtime-Base #
#########################
FROM ranktotop/cudadocker:11.8_base

# Runtime-Libs (für dynamische Codecs) – klein, aber vollständig
RUN apt-get update && apt-get install -y --no-install-recommends \
    libass9 libfreetype6 libfontconfig1 \
    libmp3lame0 libopus0 libvorbis0a libvorbisenc2 \
    libvpx7 \
    libgnutls30 \
    libx264-163 \
    libfdk-aac2 \
    libnuma1 \
    && rm -rf /var/lib/apt/lists/*

# NDI SDK Runtime mitnehmen
COPY --from=build /opt/ndi-sdk/ /opt/ndi-sdk/
RUN echo "/opt/ndi-sdk/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/ndi.conf && ldconfig
ENV LD_LIBRARY_PATH=/opt/ndi-sdk/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# FFmpeg (als separate Binaries, um nicht dein anderes ffmpeg zu überschreiben)
COPY --from=build /opt/ffmpeg-ndi/bin/ffmpeg  /usr/local/bin/ffmpeg-ndi
COPY --from=build /opt/ffmpeg-ndi/bin/ffprobe /usr/local/bin/ffprobe-ndi

# Optional: symlinks setzen, wenn du dieses FFmpeg "als Standard" willst
# RUN ln -sf /usr/local/bin/ffmpeg-ndi /usr/local/bin/ffmpeg && \
#     ln -sf /usr/local/bin/ffprobe-ndi /usr/local/bin/ffprobe
