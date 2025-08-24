# syntax=docker/dockerfile:1.6
FROM ranktotop/cudadocker:11.8_base

#set gpu capability version. Check here: https://developer.nvidia.com/cuda-gpus
# Geforce 3090 -> 8.6, Geforce 4090 -> 8.9, Geforce 5090 -> 10.0
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    TORCH_CUDA_ARCH_LIST="8.6"

# Pakete direkt in ein Zielverzeichnis installieren (kein venv!)
#check compatible versions here -> https://pytorch.org/get-started/locally/
RUN mkdir -p /opt/python/torch \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install --extra-index-url https://download.pytorch.org/whl/cu118 \
    "numpy<2" \
    torch==2.5.1 \
    torchvision==0.20.1 \
    torchaudio==2.5.1 \
    torch-audiomentations==0.11.2 \
    torch_pitch_shift==1.2.5 \
    torchmetrics==1.6.1 \
    --target /opt/python/torch