# text-generaion-webui-docker

Docker images and configuration to run koboldcpp with GPU, currently updated to release v1.35 found here: https://github.com/LostRuins/koboldcpp.git

(though currently using https://github.com/henk717/koboldcpp.git for CUDA support and tagged as 1.35 experimental on my dockerhub)

# Build instructions

First checkout this branch

```sh
git clone https://github.com/noneabove1182/koboldcpp-docker.git
```

Next, build the image

```sh
cd koboldcpp-docker
docker build -t koboldcpp-docker:latest .
```

# Running the image with docker run

```sh
docker run --gpus all -p 80:80 -v /media/teamgroup/models:/app/models koboldcpp-docker:latest --model /app/models/wizardlm-13b-v1.1.ggmlv3.q4_1.bin --port 80 --threads 6 --usecublas --gpulayers 43
```

# Running the image with docker compose

A docker-compose.yaml file has been provided, as well as a .env file that I use for setting my model dir and the model name I'd like to load in with

Feel free to modify both to fit your needs, for example I use lowvram for bigger models but remove it for smaller ones but if you don't you can remove it

# Pre-built image

Pre-built images are provided at https://hub.docker.com/r/noneabove1182/koboldcpp-gpu

Follow the same command as above except with noneabove1182/koboldcpp-gpu:(version)
