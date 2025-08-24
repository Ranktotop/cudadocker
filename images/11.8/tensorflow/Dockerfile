# syntax=docker/dockerfile:1.6
FROM ranktotop/cudadocker:11.8_base

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    TF_ENABLE_ONEDNN_OPTS=0 \
    TF_CPP_MIN_LOG_LEVEL=3

RUN mkdir -p /opt/python/tf \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install \
    "numpy<2" \
    tensorflow==2.14.0 \
    tensorflow-hub \
    tensorboard==2.14.0 \
    --target /opt/python/tf
