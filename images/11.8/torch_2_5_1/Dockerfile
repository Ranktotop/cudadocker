# syntax=docker/dockerfile:1.6
FROM ranktotop/cudadocker:11.8_base

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    TORCH_CUDA_ARCH_LIST="8.6" \
    PATH="/opt/venv/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/venv/lib/python3.10/site-packages/torch/lib:${LD_LIBRARY_PATH}"

# PyTorch 2.5.1 (cu118) + Addons in venv
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install --extra-index-url https://download.pytorch.org/whl/cu118 \
    torch==2.5.1 \
    torchvision==0.20.1 \
    torchaudio==2.5.1 \
    torch-audiomentations==0.11.2 \
    torch_pitch_shift==1.2.5 \
    torchmetrics==1.6.1
