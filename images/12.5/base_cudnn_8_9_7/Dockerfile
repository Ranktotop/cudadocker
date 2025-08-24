FROM nvidia/cuda:12.5.0-runtime-ubuntu22.04

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
    "libcublas-12-5=12.5.3.2-1" "libcublas-dev-12-5=12.5.3.2-1" \
    && apt-mark hold libcublas-12-5 libcublas-dev-12-5 \
    && rm -rf /var/lib/apt/lists/*

# --- cuDNN strikt auf 8.9.7 pinnen (Runtime-only) ---
# Install cuDNN 8.9.7 for getting compatibility with tensorflow 2.14 -> https://www.tensorflow.org/install/source#gpu
RUN wget -q https://developer.download.nvidia.com/compute/cudnn/8.9.7/local_installers/cudnn-local-repo-ubuntu2204-8.9.7.29_1.0-1_amd64.deb -O /tmp/cudnn.deb \
    && dpkg -i /tmp/cudnn.deb \
    && cp /var/cudnn-local-repo-ubuntu2204-8.9.7.29/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y --no-install-recommends cudnn-cuda-12 \
    && apt-mark hold cudnn-cuda-12 \
    && ldconfig \
    && rm -f /tmp/cudnn.deb \
    && rm -rf /var/lib/apt/lists/*


