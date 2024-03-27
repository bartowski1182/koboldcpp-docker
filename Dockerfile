# cuda devel image for base, best build compatibility
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 as builder

# Update base image and install dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential \
    python3 pip gcc wget \
    ocl-icd-opencl-dev opencl-headers clinfo \
    libclblast-dev libopenblas-dev \
    && mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

ARG clone_arg

# Pulling latest koboldcpp branch and installing requirements
RUN git clone https://github.com/LostRuins/koboldcpp.git $clone_arg

WORKDIR /koboldcpp

RUN pip3 install -r requirements.txt

# Setting up env variables
ENV LLAMA_PORTABLE=1
ENV LLAMA_CUBLAS=1
ENV LLAMA_CLBLAST=1
ENV LLAMA_OPENBLAS=1

# build-o'clock
RUN make

# Using ubuntu 22.04 for smaller final image
FROM ubuntu:22.04

# update image and install necessary packages
RUN apt-get update && apt-get upgrade -y \
    && apt-get -y install python3 \
    ocl-icd-opencl-dev opencl-headers clinfo \
    libclblast-dev libopenblas-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /usr/local/cuda-12.1 /usr/local/cuda-12.1
COPY --from=builder /usr/local/cuda-12.1/bin /usr/local/cuda-12.1/bin
COPY --from=builder /usr/local/cuda-12.1/lib64 /usr/local/cuda-12.1/lib64

# Copy the git repo from builder
COPY --from=builder /koboldcpp /koboldcpp

WORKDIR /koboldcpp

EXPOSE 80

ENV CUDA_HOME='/usr/local/cuda-12.1'
ENV PATH=/usr/local/cuda-12.1/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# koboldcpp.py as entry command
CMD ["python3", "koboldcpp.py"]
