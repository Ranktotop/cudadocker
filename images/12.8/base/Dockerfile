FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    CUDA_HOME=/usr/local/cuda \
    FORCE_CUDA=1 \
    NVIDIA_DRIVER_CAPABILITIES=all

# Systembasics
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-distutils \
    wget curl ca-certificates nano iputils-ping \
    libvulkan1 libglib2.0-0 libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# --- libcublas exakt pinnen ---
RUN apt-get update \
    && apt-get install -y --allow-change-held-packages \
    "libcublas-12-8=12.8.4.1-1" "libcublas-dev-12-8=12.8.4.1-1" \
    && apt-mark hold libcublas-12-8 libcublas-dev-12-8 \
    && rm -rf /var/lib/apt/lists/*

# --- cuDNN strikt auf 9.3 pinnen (Runtime-only) ---
# Install cuDNN 9.3 for getting compatibility with tensorflow 2.14 -> https://www.tensorflow.org/install/source#gpu
RUN wget -q https://developer.download.nvidia.com/compute/cudnn/9.3.0/local_installers/cudnn-local-repo-ubuntu2204-9.3.0_1.0-1_amd64.deb -O /tmp/cudnn.deb \
    && dpkg -i /tmp/cudnn.deb \
    && cp /var/cudnn-local-repo-ubuntu2204-9.3.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y --no-install-recommends "libcudnn9-cuda-12=9.3.0.75-1" \
    && ldconfig \
    && apt-mark hold libcudnn9-cuda-12 \
    && rm -f /tmp/cudnn.deb \
    && rm -rf /var/lib/apt/lists/*
