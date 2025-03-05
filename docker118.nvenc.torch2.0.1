FROM ranktotop/cudadocker:118_nvenc AS base
    
######################################
###### INSTALL PYTHON PACKAGES #######
######################################
#check compatible versions here -> https://pytorch.org/get-started/locally/
RUN pip3 install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu118 \
    "torch==2.0.1" \
    "torchvision==0.15.2" \
    "torchaudio==2.0.2" \
    "torch-audiomentations==0.11.2" \
    "torch_pitch_shift==1.2.5" \
    "torchmetrics==1.6.1"
    
#set gpu capability version. Check here: https://developer.nvidia.com/cuda-gpus
# Geforce 3090 -> 8.6, Geforce 4090 -> 8.9, Geforce 5090 -> 10.0
ENV TORCH_CUDA_ARCH_LIST="8.6"
ENV LD_LIBRARY_PATH=/usr/local/lib/python3.10/dist-packages/torch/lib:$LD_LIBRARY_PATH