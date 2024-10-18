#!/bin/bash
set -e  # End script on error

apt-get update
apt-get install -y python3.10-venv

echo "Installing pip dependencies..."
python3 -m venv /gputest/.venv \
    && . /gputest/.venv/bin/activate \
    && pip3 install pytz \
    && pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 \
    && pip3 install tensorflow==2.14.0 \
    && pip3 install ultralytics \
    && pip3 install requests \
    && pip3 install "numpy<2" \
    && pip3 install dill \
    && deactivate

echo "HOST Cuda Infos (nvidia-smi):"
nvidia-smi
echo "Container Cuda Infos (nvcc --version):"
nvcc --version
echo "CuDnn Version (cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 1):"
cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 1
echo "Content of ENV CUDA_HOME:"
echo $CUDA_HOME
echo "Content of ENVLD_LIBRARY_PATH:"
echo $LD_LIBRARY_PATH
echo "LibCudnn Files (ls /usr/local/cuda/lib64/libcudnn*):"
ls /usr/local/cuda/lib64/libcudnn*
echo "Other Cuda-related infos (env | grep CU | sort):"
env | grep CU | sort

echo "Starting python tests..."
/gputest/.venv/bin/python -u /gputest/testskript.py 2>&1 | tee -a /gputest/logs/app.log