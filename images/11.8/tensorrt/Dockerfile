# syntax=docker/dockerfile:1.6

# Runtime-Layer: TensorRT 8.5.1 + CUDA 11.8, basierend auf deinem schlanken Base
FROM ranktotop/cudadocker:11.8_base
ENV DEBIAN_FRONTEND=noninteractive

# NVIDIA CUDA/ML Repo-Key hinzufügen (für die TensorRT APT-Pakete)
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg ca-certificates \
    && wget -qO /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i /tmp/cuda-keyring.deb \
    && rm -f /tmp/cuda-keyring.deb \
    && apt-get update

# TensorRT 8.5.1 (Runtime) für CUDA 11.8 – strikt versioniert
#check available versions here: https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/
#check support matrix here: https://www.tensorflow.org/install/source#gpu
RUN apt-get install -y --no-install-recommends \
    libnvinfer8=8.5.1-1+cuda11.8 \
    libnvinfer-plugin8=8.5.1-1+cuda11.8 \
    libnvparsers8=8.5.1-1+cuda11.8 \
    libnvonnxparsers8=8.5.1-1+cuda11.8 \
    libnvinfer-bin=8.5.1-1+cuda11.8 \
    && apt-mark hold libnvinfer8 libnvinfer-plugin8 libnvparsers8 libnvonnxparsers8 libnvinfer-bin \
    && rm -rf /var/lib/apt/lists/*

# trtexec in den PATH verlinken, falls von libnvinfer-bin bereitgestellt
RUN if [ -x /usr/src/tensorrt/bin/trtexec ]; then \
    ln -sf /usr/src/tensorrt/bin/trtexec /usr/local/bin/trtexec; \
    else \
    echo "WARN: /usr/src/tensorrt/bin/trtexec nicht gefunden"; \
    fi