# cuda devel image for base, best build compatibility
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as builder

# Using conda to transfer python env from builder to runtime later
COPY --from=continuumio/miniconda3:4.12.0 /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH

WORKDIR /koboldcpp

# Update base image
RUN apt-get update && apt-get install -y git python3.10 python3-pip \
    build-essential libclblast-dev libopenblas-dev \
    ocl-icd-opencl-dev opencl-headers clinfo

RUN mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Create new conda environment
RUN conda create -y -n koboldcpp python=3.10.9
SHELL ["conda", "run", "-n", "koboldcpp", "/bin/bash", "-c"]

# Pulling latest koboldcpp branch
RUN git clone https://github.com/LostRuins/koboldcpp.git --branch v1.37.1a ./

# install requirements and build with GPU support
RUN pip3 install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt \
    && make LLAMA_OPENBLAS=1 LLAMA_CLBLAST=1 LLAMA_CUBLAS=1

RUN conda clean -afy

# Using runtime for smaller final image
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# Copy conda and cuda files over
COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /etc/OpenCL/vendors/nvidia.icd /etc/OpenCL/vendors/nvidia.icd

ENV PATH=/opt/conda/bin:$PATH

# update image and install necessary packages
RUN apt-get update && apt-get upgrade -y \
    && apt-get -y install python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /etc/OpenCL/vendors

# Copy the git repo from builder
COPY --from=builder /koboldcpp /koboldcpp

WORKDIR /koboldcpp

EXPOSE 80

# Define the entrypoiny enabling conda environment
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "koboldcpp"]
CMD ["python3", "koboldcpp.py"]
