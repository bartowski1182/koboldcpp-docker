## This work is not official

I am providing this work as a helpful hand to people who are looking for a simple, easy to build docker image with GPU support, this is not official in any capacity, and any issues arising from this docker image should be posted here and not on their own repo or discord.

# koboldcpp-docker

Docker images and configuration to run koboldcpp with GPU, currently updated to release v1.39.1 found here: https://github.com/LostRuins/koboldcpp.git

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

(add -d for detached)

```sh
docker run --gpus all -p 80:80 -v /media/teamgroup/models:/app/models koboldcpp-docker:latest --model /app/models/wizardlm-13b-v1.1.ggmlv3.q4_1.bin --port 80 --threads 6 --usecublas --gpulayers 43
```

# Running the image with docker compose

A docker-compose.yaml file has been provided, as well as a .env file that I use for setting my model dir and the model name I'd like to load in with

Feel free to modify both to fit your needs, for example I use lowvram for bigger models but remove it for smaller ones but if you don't you can remove it

# Pre-built image

Pre-built images are provided at https://hub.docker.com/r/noneabove1182/koboldcpp-gpu

Follow the same command as above except with noneabove1182/koboldcpp-gpu:(version)

# Quirks and features

If you're having trouble saving info across sessions, try adding a docker volume (which may have to be removed between updates)

add:

```
      - kobold:/koboldcpp
```

to the volumes section of docker-compose.yml and

```
volumes:
  kobold:
```

at the bottom

or for docker run:

```
docker volume create kobold
```

and add

```
-v kobold:/koboldcpp
```

to your run command (will make these instructions better soontm)
