# syntax=docker/dockerfile:1.6
FROM ranktotop/cudadocker:12.5_base_cudnn_8_9_7

#set gpu capability version. Check here: https://developer.nvidia.com/cuda-gpus
# Geforce 3090 -> 8.6, Geforce 4090 -> 8.9, Geforce 5090 -> 10.0
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    TORCH_CUDA_ARCH_LIST="8.6" \
    TORCH_SERIALIZATION_WEIGHTS_ONLY=FALSE

# Pakete direkt in ein Zielverzeichnis installieren (kein venv!)
#check compatible versions here -> https://pytorch.org/get-started/locally/
RUN mkdir -p /opt/python/torch \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install --extra-index-url https://download.pytorch.org/whl/cu118 \
    "numpy>=2.0.2" \
    torch \
    torchvision \
    torchaudio \
    torch-audiomentations \
    torch_pitch_shift \
    torchmetrics \
    --target /opt/python/torch

# create constraint file for preventing torch reinstalls
RUN python3 -m pip freeze --path /opt/python/torch > /opt/python/torch/constraints_torch.txt