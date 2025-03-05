FROM ranktotop/cudadocker:125_nvenc_cudnn8 AS base
    
######################################
###### INSTALL PYTHON PACKAGES #######
######################################
#check compatible versions here -> https://pytorch.org/get-started/locally/
RUN pip3 install --no-cache-dir torch \
    torchvision \
    torchaudio \
    torch-audiomentations \
    torch_pitch_shift \
    torchmetrics
    
#set gpu capability version. Check here: https://developer.nvidia.com/cuda-gpus
# Geforce 3090 -> 8.6, Geforce 4090 -> 8.9, Geforce 5090 -> 10.0
ENV TORCH_CUDA_ARCH_LIST="8.6"
ENV LD_LIBRARY_PATH=/usr/local/lib/python3.10/dist-packages/torch/lib:$LD_LIBRARY_PATH