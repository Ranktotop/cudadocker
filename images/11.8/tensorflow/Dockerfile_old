FROM ranktotop/cudadocker:118_nvenc_torch AS base
    
######################################
###### INSTALL PYTHON PACKAGES #######
######################################
RUN pip3 install --no-cache-dir "tensorflow-hub" \
    "tensorflow==2.14.0" \
    "tensorboard==2.14.0" \
    "numpy<2"
    
ENV TF_ENABLE_ONEDNN_OPTS=0
ENV TF_CPP_MIN_LOG_LEVEL=3