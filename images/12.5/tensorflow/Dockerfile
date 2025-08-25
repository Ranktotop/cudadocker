# syntax=docker/dockerfile:1.6
FROM ranktotop/cudadocker:12.5_base

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    TF_ENABLE_ONEDNN_OPTS=0 \
    TF_CPP_MIN_LOG_LEVEL=3

#check compatibility here -> https://www.tensorflow.org/install/source#gpu
#install 2.18.0 for beeing compatible with cudnn 9.3
RUN mkdir -p /opt/python/tf \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install \
    "numpy<2" \
    tensorflow==2.18.0 \
    tensorflow-hub \
    tensorboard==2.18.0 \
    --target /opt/python/tf
