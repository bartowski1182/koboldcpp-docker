# cuda devel image for base, best build compatibility
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 as builder

# Update base image and install dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential \
    python3 pip gcc wget \
    ocl-icd-opencl-dev opencl-headers clinfo \
    libclblast-dev libopenblas-dev \
    && mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

WORKDIR /koboldcpp

ARG clone_arg

# Pulling latest koboldcpp branch and installing requirements
RUN git clone https://github.com/LostRuins/koboldcpp.git $clone_arg ./

RUN pip3 install -r requirements.txt

# Setting up env variables
ENV CUDA_DOCKER_ARCH=all
ENV LLAMA_CUBLAS=1
ENV LLAMA_CLBLAST=1
ENV LLAMA_OPENBLAS=1

# build-o'clock
RUN make

# Using runtime for smaller final image
FROM noneabove1182/nvidia-runtime-docker:12.1.1-runtime-ubuntu22.04

# update image and install necessary packages
RUN apt-get update && apt-get upgrade -y \
    && apt-get -y install python3 \
    ocl-icd-opencl-dev opencl-headers clinfo \
    libclblast-dev libopenblas-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the git repo from builder
COPY --from=builder /koboldcpp /koboldcpp

WORKDIR /koboldcpp

EXPOSE 80

# koboldcpp.py as entry command
CMD ["python3", "koboldcpp.py"]
