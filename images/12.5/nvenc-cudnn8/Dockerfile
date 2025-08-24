FROM ranktotop/cudadocker:125_base_cudnn8

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    yasm \
    nasm \
    gcc \
    g++ \
    cmake \
    libx264-dev \
    libx265-dev \
    libvpx-dev \
    libfdk-aac-dev \
    libvorbis-dev \
    libopus-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libfreetype6-dev \
    libfontconfig1-dev \
    libass-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#######################################
########### INSTALL NVENC #############
#######################################

# Install cuda toolkit for cuda 12.5
RUN apt-get update && \
    apt-get install -y "cuda-toolkit-12-5=12.5.0-1" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Klone die nv-codec-headers
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /tmp/nv-codec-headers && \
    cd /tmp/nv-codec-headers && \
    make && \
    make install && \
    cd -

# Erstellen von Symlinks für CUDA-Bibliotheken
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/lib/libcuda.so