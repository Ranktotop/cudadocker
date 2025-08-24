# syntax=docker/dockerfile:1.6

########################
# Stage 1: Build-Stage #
########################
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

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

COPY NDI_SDK${NDI_VERSION}.tar.gz /tmp/NDI_SDK${NDI_VERSION}.tar.gz
RUN mkdir -p /opt/ndi-sdk && \
    tar --strip-components=1 -xzf /tmp/NDI_SDK${NDI_VERSION}.tar.gz -C /opt/ndi-sdk && \
    echo "/opt/ndi-sdk/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/ndi.conf && ldconfig

# ---- nv-codec-headers: kompatibler Commit (11.1.5.3) ----
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /tmp/nvch && \
    cd /tmp/nvch && \
    git checkout 43d91706e097565f57b311e567f0219838bcc2f6 && \
    make && make install

# FFmpeg + NDI Patch
RUN wget -O ffmpeg-6.1.1.tar.gz https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n6.1.1.tar.gz && \
    tar -xzf ffmpeg-6.1.1.tar.gz && mv FFmpeg-n6.1.1 ffmpeg
WORKDIR /tmp/ffmpeg-build/ffmpeg
COPY ndi-support.patch ./ndi-support.patch
RUN patch -p1 < ndi-support.patch

# ---- Configure ----
RUN PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig" \
    ./configure \
    --prefix="/opt/ffmpeg-ndi" \
    --extra-cflags="-I/opt/ndi-sdk/include -I/usr/local/cuda/include" \
    --extra-ldflags="-L/opt/ndi-sdk/lib/x86_64-linux-gnu -L/usr/local/cuda/lib64 -Wl,-rpath,/opt/ndi-sdk/lib/x86_64-linux-gnu" \
    --extra-libs="-ldl -lpthread" \
    --bindir="/opt/ffmpeg-ndi/bin" \
    --libdir="/opt/ffmpeg-ndi/lib" \
    --enable-gpl --enable-nonfree \
    --enable-gnutls \
    --enable-libndi_newtek \
    --enable-libass --enable-libfreetype --enable-libfontconfig \
    --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx \
    --enable-libx264 --enable-libx265 --enable-libfdk-aac \
    --enable-cuda --enable-nvenc --enable-nvdec --enable-cuvid --enable-libnpp \
    && make -j"$(nproc)" && make install \
    && strip /opt/ffmpeg-ndi/bin/ffmpeg /opt/ffmpeg-ndi/bin/ffprobe || true

# NPP-Libs für Runtime bündeln
RUN mkdir -p /tmp/ndi_runtime/usr/local/lib && \
    cp -a /usr/local/cuda/lib64/libnpp*.so* /tmp/ndi_runtime/usr/local/lib/ || true

#########################
# Stage 2: Runtime-Base #
#########################
FROM ranktotop/cudadocker:11.8_base

RUN apt-get update && apt-get install -y --no-install-recommends \
    libass9 libfreetype6 libfontconfig1 \
    libmp3lame0 libopus0 libvorbis0a libvorbisenc2 \
    libvpx7 \
    libgnutls30 \
    libx264-163 \
    libfdk-aac2 \
    libnuma1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/ndi-sdk/ /opt/ndi-sdk/
RUN echo "/opt/ndi-sdk/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/ndi.conf && ldconfig
ENV LD_LIBRARY_PATH=/opt/ndi-sdk/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

COPY --from=build /tmp/ndi_runtime/usr/local/lib/ /usr/local/lib/
RUN ldconfig || true

COPY --from=build /opt/ffmpeg-ndi/bin/ffmpeg  /usr/local/bin/ffmpeg
COPY --from=build /opt/ffmpeg-ndi/bin/ffprobe /usr/local/bin/ffprobe
