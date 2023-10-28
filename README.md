## This work is not official

I am providing this work as a helpful hand to people who are looking for a simple, easy to build docker image with GPU support, this is not official in any capacity, and any issues arising from this docker image should be posted here and not on their own repo or discord.


Note: this step may no longer be necessary, it was a workaround for a broken driver version
Requires nvidia-driver 535.113.01, installed with apt-get install -y --allow-downgrades nvidia-driver-535/jammy-updates

# koboldcpp-docker

Docker images and configuration to run koboldcpp with GPU, currently updated to release v1.47.2 found here: https://github.com/LostRuins/koboldcpp.git

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

(note, if you don't require CUDA you can instead pass -f Dockerfile_cpu to build without CUDA support, and you can use the docker-compose.yml.for-cpu from ./alternative-compose/)

# Running the image with docker run

(add -d for detached)

```sh
docker run --gpus all -p 80:80 -v /media/teamgroup/models:/app/models koboldcpp-docker:latest --model /app/models/wizardlm-13b-v1.1.ggmlv3.q4_1.bin --port 80 --threads 6 --usecublas --gpulayers 43
```

# Running the image with docker compose

A docker-compose.yml file has been provided, as well as a .env file that I use for setting my model dir and the model name I'd like to load in with

Feel free to modify both to fit your needs, for example I use lowvram for bigger models but remove it for smaller ones but if you don't you can remove it

I've also provided an alternative-compose a docker-compose.yml.for-cpu for the default CPU arguments

# Pre-built image

Pre-built images are provided at https://hub.docker.com/r/noneabove1182/koboldcpp-gpu

Follow the same command as above except with noneabove1182/koboldcpp-gpu:(version)

CPU version provided as well but I'm slower at updating it: https://hub.docker.com/r/noneabove1182/koboldcpp-cpu

# Quirks and features

If you're having trouble saving info across sessions, try adding a docker volume. See alternative-compose folder for the one with volumes.

I've had some issues in the past keeping the volume between versions, so try 'docker volume rm kobold' if you have some weird behaviour as a first troubleshooting step.

for docker run:

```
docker volume create kobold
```

and the full command is now:

```sh
docker run --gpus all -p 80:80 -v /media/teamgroup/models:/app/models koboldcpp-docker:latest -v kobold:/koboldcpp --model /app/models/wizardlm-13b-v1.1.ggmlv3.q4_1.bin --port 80 --threads 6 --usecublas --gpulayers 43
```
