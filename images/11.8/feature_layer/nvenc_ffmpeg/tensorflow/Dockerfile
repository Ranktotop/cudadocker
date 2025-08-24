# ranktotop/cudadocker:11.8_tf-layer
FROM ranktotop/cudadocker:11.8_base AS build
RUN mkdir -p /opt/runtime/lib/python3.10/site-packages
RUN pip3 install --no-cache-dir \
    "tensorflow==2.14.0" "tensorboard==2.14.0" "tensorflow-hub" "numpy<2" \
    --target /opt/runtime/lib/python3.10/site-packages
ENV TF_ENABLE_ONEDNN_OPTS=0 TF_CPP_MIN_LOG_LEVEL=3
FROM scratch
COPY --from=build /opt/runtime /layer/opt/runtime
LABEL org.opencontainers.image.title="TensorFlow layer" \
    com.ranktotop.tf="2.14.0" com.ranktotop.cuda="11.8"
