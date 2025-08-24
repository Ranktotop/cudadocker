FROM ranktotop/cudadocker:125_nvenc AS base
    
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
    