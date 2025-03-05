FROM nvidia/cuda:12.5.0-devel-ubuntu22.04

# Tell the CUDA environment what GPU features to expose in the container.
ENV NVIDIA_DRIVER_CAPABILITIES=all
#ENV NVIDIA_VISIBLE_DEVICES=0
#ENV CUDA_VISIBLE_DEVICES=0
ENV DEBIAN_FRONTEND=noninteractive

# Upgrade libcublas
RUN apt-get update && \
    apt-get install -y --allow-change-held-packages "libcublas-12-5=12.5.3.2-1" "libcublas-dev-12-5=12.5.3.2-1" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-qt5 \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    libgstreamer-plugins-bad1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgtk2.0-0 \
    libunwind-dev \
    libvulkan1 \
    libxcb-xkb1 \
    libxcb1 \
    libxcb-cursor0 \
    python3-pip \
    wget \
    ca-certificates \
    curl \
    git \
    nano \
    iputils-ping \
    net-tools \
    fonts-inter &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#######################################
######### INSTALL cuDNN 9.3 ###########
#######################################

# cuDNN-Local-Repo herunterladen, installieren und konfigurieren
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.3.0/local_installers/cudnn-local-repo-ubuntu2204-9.3.0_1.0-1_amd64.deb && \
    dpkg -i cudnn-local-repo-ubuntu2204-9.3.0_1.0-1_amd64.deb && \
    cp /var/cudnn-local-repo-ubuntu2204-9.3.0/cudnn-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get -y install cudnn-cuda-12 && \
    rm cudnn-local-repo-ubuntu2204-9.3.0_1.0-1_amd64.deb
    
# Update dynamic linker run-time bindings
RUN ldconfig

# Erstelle die Symlinks für cuDNN-Bibliotheken
RUN ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so.9 /usr/local/cuda/lib64/libcudnn.so.9 && \
    ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so.9.7.1 /usr/local/cuda/lib64/libcudnn.so.9.7.1 && \
    ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so /usr/local/cuda/lib64/libcudnn.so
#replace the wrong nvidia path with correct one
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64
ENV CUDA_HOME=/usr/local/cuda
ENV CUB_HOME=/usr/local/cuda/include
ENV FORCE_CUDA=1

#######################################
######### INSTALL TENSORRT ############
#######################################

#check available versions here: https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/
#check support matrix here: https://www.tensorflow.org/install/source#gpu

RUN apt-get update && \
    apt-get install -y --allow-downgrades \
    libnvinfer-lean10=10.3.0.26-1+cuda12.5 \
    libnvinfer-vc-plugin10=10.3.0.26-1+cuda12.5 \
    libnvinfer-dispatch10=10.3.0.26-1+cuda12.5 \
    libnvinfer-headers-dev=10.3.0.26-1+cuda12.5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    apt-get install -y --allow-downgrades \
    libnvinfer10=10.3.0.26-1+cuda12.5 \
    libnvinfer-dev=10.3.0.26-1+cuda12.5 \
    libnvinfer-plugin10=10.3.0.26-1+cuda12.5 \
    libnvinfer-bin=10.3.0.26-1+cuda12.5 \
    libnvonnxparsers10=10.3.0.26-1+cuda12.5 \
    libnvonnxparsers-dev=10.3.0.26-1+cuda12.5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*