FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as builder

COPY --from=continuumio/miniconda3:4.12.0 /opt/conda /opt/conda

ENV PATH=/opt/conda/bin:$PATH

WORKDIR /koboldcpp

RUN apt-get update && apt-get install -y git python3.10 python3-pip \
    build-essential libclblast-dev libopenblas-dev \
    ocl-icd-opencl-dev opencl-headers clinfo

RUN mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN conda create -y -n koboldcpp python=3.10.9
SHELL ["conda", "run", "-n", "koboldcpp", "/bin/bash", "-c"]

RUN git clone https://github.com/LostRuins/koboldcpp.git --branch v1.36 ./

RUN pip3 install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt \
    && make LLAMA_OPENBLAS=1 LLAMA_CLBLAST=1 LLAMA_CUBLAS=1

RUN conda clean -afy

FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

COPY --from=builder /opt/conda /opt/conda

ENV PATH=/opt/conda/bin:$PATH

RUN apt-get update && apt-get upgrade -y \
    && apt-get -y install python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /etc/OpenCL/vendors

COPY --from=builder /koboldcpp /koboldcpp

COPY --from=builder /etc/OpenCL/vendors/nvidia.icd /etc/OpenCL/vendors/nvidia.icd

WORKDIR /koboldcpp

EXPOSE 80

# Define the entrypoint
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "koboldcpp"]
CMD ["python3", "koboldcpp.py"]
