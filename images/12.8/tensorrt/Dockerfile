# syntax=docker/dockerfile:1.6

# Runtime-Layer: TensorRT 8.5.1 + CUDA 12.5, basierend auf deinem schlanken Base
FROM ranktotop/cudadocker:12.8_base
ENV DEBIAN_FRONTEND=noninteractive

# NVIDIA CUDA/ML Repo-Key hinzufügen (für die TensorRT APT-Pakete)
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg ca-certificates \
    && wget -qO /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i /tmp/cuda-keyring.deb \
    && rm -f /tmp/cuda-keyring.deb \
    && apt-get update \
    && apt-get purge -y --auto-remove gnupg wget \
    && rm -rf /var/lib/apt/lists/*

# TensorRT 10.3.0.26 (Runtime) für CUDA 12.5 – strikt versioniert
#check available versions here: https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/
#check support matrix here: https://www.tensorflow.org/install/source#gpu
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libnvinfer-lean10=10.9.0.34-1+cuda12.8 \
    libnvinfer-vc-plugin10=10.9.0.34-1+cuda12.8 \
    libnvinfer-dispatch10=10.9.0.34-1+cuda12.8 \
    libnvinfer10=10.9.0.34-1+cuda12.8 \
    libnvinfer-plugin10=10.9.0.34-1+cuda12.8 \
    libnvonnxparsers10=10.9.0.34-1+cuda12.8 \
    libnvinfer-bin=10.9.0.34-1+cuda12.8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# trtexec in den PATH verlinken, falls von libnvinfer-bin bereitgestellt
RUN if [ -x /usr/src/tensorrt/bin/trtexec ]; then \
    ln -sf /usr/src/tensorrt/bin/trtexec /usr/local/bin/trtexec; \
    else \
    echo "WARN: /usr/src/tensorrt/bin/trtexec nicht gefunden"; \
    fi
