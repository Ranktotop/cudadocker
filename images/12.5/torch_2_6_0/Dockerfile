# syntax=docker/dockerfile:1.6
FROM ranktotop/cudadocker:12.5_base

#set gpu capability version. Check here: https://developer.nvidia.com/cuda-gpus
# Geforce 3090 -> 8.6, Geforce 4090 -> 8.9, Geforce 5090 -> 10.0
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    TORCH_CUDA_ARCH_LIST="8.6" \
    TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

# Pakete direkt in ein Zielverzeichnis installieren (kein venv!)
#check compatible versions here -> https://pytorch.org/get-started/locally/
RUN mkdir -p /opt/python/torch \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install --extra-index-url https://download.pytorch.org/whl/cu124 \
    "numpy>=2.0.2" \
    torch==2.6.0 \
    torchvision==0.21.0 \
    torchaudio==2.6.0 \
    torch-audiomentations==0.12.0 \
    torch_pitch_shift==1.2.5 \
    torchmetrics==1.8.1 \
    --target /opt/python/torch

# create constraint file for preventing torch reinstalls
RUN python3 -m pip freeze --path /opt/python/torch > /opt/python/torch/constraints_torch.txt