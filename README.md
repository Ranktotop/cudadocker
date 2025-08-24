# Build commands

Dockerfiles are in images/<cuda-version>/<variant>.

## Cuda 11.8
### base
docker build -t cudadocker:118_base images/11.8/base
docker tag cudadocker:118_base ranktotop/cudadocker:118_base
docker push ranktotop/cudadocker:118_base

### nvenc
docker build -t cudadocker:118_nvenc images/11.8/nvenc
docker tag cudadocker:118_nvenc ranktotop/cudadocker:118_nvenc
docker push ranktotop/cudadocker:118_nvenc

### torch
docker build -t cudadocker:118_nvenc_torch images/11.8/nvenc-torch
docker tag cudadocker:118_nvenc_torch ranktotop/cudadocker:118_nvenc_torch
docker push ranktotop/cudadocker:118_nvenc_torch

### torch 2.0.1
docker build -t cudadocker:118_nvenc_torch_201 images/11.8/nvenc-torch2.0.1
docker tag cudadocker:118_nvenc_torch_201 ranktotop/cudadocker:118_nvenc_torch2.0.1
docker push ranktotop/cudadocker:118_nvenc_torch_201

### tensorflow
docker build -t cudadocker:118_nvenc_torch_tensorflow images/11.8/nvenc-torch-tensorflow
docker tag cudadocker:118_nvenc_torch_tensorflow ranktotop/cudadocker:118_nvenc_torch_tensorflow
docker push ranktotop/cudadocker:118_nvenc_torch_tensorflow

## Cuda 12.5 (CuDNN 9.3)
### base
docker build -t cudadocker:125_base images/12.5/base
docker tag cudadocker:125_base ranktotop/cudadocker:125_base
docker push ranktotop/cudadocker:125_base

### nvenc
docker build -t cudadocker:125_nvenc images/12.5/nvenc
docker tag cudadocker:125_nvenc ranktotop/cudadocker:125_nvenc
docker push ranktotop/cudadocker:125_nvenc

### torch
docker build -t cudadocker:125_nvenc_torch images/12.5/nvenc-torch
docker tag cudadocker:125_nvenc_torch ranktotop/cudadocker:125_nvenc_torch
docker push ranktotop/cudadocker:125_nvenc_torch

### tensorflow
docker build -t cudadocker:125_nvenc_torch_tensorflow images/12.5/nvenc-torch-tensorflow
docker tag cudadocker:125_nvenc_torch_tensorflow ranktotop/cudadocker:125_nvenc_torch_tensorflow
docker push ranktotop/cudadocker:125_nvenc_torch_tensorflow

## Cuda 12.5 (CuDNN 8.9)
### base
docker build -t cudadocker:125_base_cudnn8 images/12.5/base-cudnn8
docker tag cudadocker:125_base_cudnn8 ranktotop/cudadocker:125_base_cudnn8
docker push ranktotop/cudadocker:125_base_cudnn8

### nvenc
docker build -t cudadocker:125_nvenc_cudnn8 images/12.5/nvenc-cudnn8
docker tag cudadocker:125_nvenc_cudnn8 ranktotop/cudadocker:125_nvenc_cudnn8
docker push ranktotop/cudadocker:125_nvenc_cudnn8

### torch
docker build -t cudadocker:125_nvenc_torch_cudnn8 images/12.5/nvenc-torch-cudnn8
docker tag cudadocker:125_nvenc_torch_cudnn8 ranktotop/cudadocker:125_nvenc_torch_cudnn8
docker push ranktotop/cudadocker:125_nvenc_torch_cudnn8

### tensorflow
docker build -t cudadocker:125_nvenc_torch_tensorflow_cudnn8 images/12.5/nvenc-torch-tensorflow-cudnn8
docker tag cudadocker:125_nvenc_torch_tensorflow_cudnn8 ranktotop/cudadocker:125_nvenc_torch_tensorflow_cudnn8
docker push ranktotop/cudadocker:125_nvenc_torch_tensorflow_cudnn8


