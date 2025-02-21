# Build commands

## Cuda 11.8
### base
docker build -t cudadocker:118_base -f docker118.base .
docker tag cudadocker:118_base ranktotop/cudadocker:118_base
docker push ranktotop/cudadocker:118_base

### nvenc
docker build -t cudadocker:118_nvenc -f docker118.nvenc .
docker tag cudadocker:118_nvenc ranktotop/cudadocker:118_nvenc
docker push ranktotop/cudadocker:118_nvenc

### torch
docker build -t cudadocker:118_nvenc_torch -f docker118.nvenc.torch .
docker tag cudadocker:118_nvenc_torch ranktotop/cudadocker:118_nvenc_torch
docker push ranktotop/cudadocker:118_nvenc_torch

### tensorflow
docker build -t cudadocker:118_nvenc_torch_tensorflow -f docker118.nvenc.torch.tensorflow .
docker tag cudadocker:118_nvenc_torch_tensorflow ranktotop/cudadocker:118_nvenc_torch_tensorflow
docker push ranktotop/cudadocker:118_nvenc_torch_tensorflow

## Cuda 12.5 (CuDNN 9.3)
### base
docker build -t cudadocker:125_base -f docker125.base .
docker tag cudadocker:125_base ranktotop/cudadocker:125_base
docker push ranktotop/cudadocker:125_base

### nvenc
docker build -t cudadocker:125_nvenc -f docker125.nvenc .
docker tag cudadocker:125_nvenc ranktotop/cudadocker:125_nvenc
docker push ranktotop/cudadocker:125_nvenc

### torch
docker build -t cudadocker:125_nvenc_torch -f docker125.nvenc.torch .
docker tag cudadocker:125_nvenc_torch ranktotop/cudadocker:125_nvenc_torch
docker push ranktotop/cudadocker:125_nvenc_torch

### tensorflow
docker build -t cudadocker:125_nvenc_torch_tensorflow -f docker125.nvenc.torch.tensorflow .
docker tag cudadocker:125_nvenc_torch_tensorflow ranktotop/cudadocker:125_nvenc_torch_tensorflow
docker push ranktotop/cudadocker:125_nvenc_torch_tensorflow

## Cuda 12.5 (CuDNN 8.9)
### base
docker build -t cudadocker:125_base_cudnn8 -f docker125.base.cudnn8 .
docker tag cudadocker:125_base_cudnn8 ranktotop/cudadocker:125_base_cudnn8
docker push ranktotop/cudadocker:125_base_cudnn8

### nvenc
docker build -t cudadocker:125_nvenc_cudnn8 -f docker125.nvenc.cudnn8 .
docker tag cudadocker:125_nvenc_cudnn8 ranktotop/cudadocker:125_nvenc_cudnn8
docker push ranktotop/cudadocker:125_nvenc_cudnn8

### torch
docker build -t cudadocker:125_nvenc_torch_cudnn8 -f docker125.nvenc.torch.cudnn8 .
docker tag cudadocker:125_nvenc_torch_cudnn8 ranktotop/cudadocker:125_nvenc_torch_cudnn8
docker push ranktotop/cudadocker:125_nvenc_torch_cudnn8

### tensorflow
docker build -t cudadocker:125_nvenc_torch_tensorflow_cudnn8 -f docker125.nvenc.torch.tensorflow.cudnn8 .
docker tag cudadocker:125_nvenc_torch_tensorflow_cudnn8 ranktotop/cudadocker:125_nvenc_torch_tensorflow_cudnn8
docker push ranktotop/cudadocker:125_nvenc_torch_tensorflow_cudnn8


