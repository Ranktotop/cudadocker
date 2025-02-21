FROM ranktotop/cudadocker:125_nvenc_torch_cudnn8 AS base
    
######################################
###### INSTALL PYTHON PACKAGES #######
######################################
#check compatibility here -> https://www.tensorflow.org/install/source#gpu
#install 2.16.1 instead of 2.17 to surpress message Unable to register cuDNN factory... and Unable to register cuBLAS factory...
RUN pip3 install --no-cache-dir "tensorflow-hub" \
    "tensorflow==2.16.1" \
    "tensorboard==2.16.1" \
    "numpy<2"
    
ENV TF_ENABLE_ONEDNN_OPTS=0
ENV TF_CPP_MIN_LOG_LEVEL=3