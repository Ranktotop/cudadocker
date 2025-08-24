# syntax=docker/dockerfile:1.6

# PyTorch (cu118) Runtime-Layer
FROM ranktotop/cudadocker:11.8_base

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    # für Extensions/JIT-Builds (optional, schadet nicht)
    TORCH_CUDA_ARCH_LIST="8.6" \
    # einige Loader erwarten Torch-Libs im Suchpfad
    LD_LIBRARY_PATH=/usr/local/lib/python3.10/dist-packages/torch/lib:$LD_LIBRARY_PATH

# PyTorch 2.5.1 + passende Vision/Audio (cu118 Wheels)
# plus deine Zusatzpakete
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --extra-index-url https://download.pytorch.org/whl/cu118 \
    "torch==2.5.1" \
    "torchvision==0.20.1" \
    "torchaudio==2.5.1" \
    "torch-audiomentations==0.11.2" \
    "torch_pitch_shift==1.2.5" \
    "torchmetrics==1.6.1"
