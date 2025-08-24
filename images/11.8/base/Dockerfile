# bases/11.8_base-core.Dockerfile
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

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
    wget nano curl iputils-ping \
    ca-certificates \
    libvulkan1 libglib2.0-0 libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# --- cuDNN strikt auf 8.7 pinnen (Runtime-only) ---
# evtl. vorinstallierte Version entfernen
RUN apt-get update && apt-get remove -y --allow-change-held-packages libcudnn8 libcudnn8-dev || true

# exakt 8.7.0.84 für CUDA 11.8 installieren
RUN wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/libcudnn8_8.7.0.84-1+cuda11.8_amd64.deb -O /tmp/libcudnn8.deb \
    && dpkg -i /tmp/libcudnn8.deb \
    && rm -f /tmp/libcudnn8.deb \
    && ldconfig \
    && apt-mark hold libcudnn8