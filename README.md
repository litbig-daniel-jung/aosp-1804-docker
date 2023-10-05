# Docker for AOSP Build and Android App Build

### Summary

* Install docker

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
Executing docker install script, commit: 7cae5f8b0decc17d6571f9f52eb840fbc13b2737
<...>
```

* As a non-root USer

```bash
$ sudo groupadd docker && sudo usermod -aG docker $USER
```

* Build Docker Image

```bash
$ bash DockerImageBuilder.sh
```

* Run

   precondition : 
   * install build docker
   * build docker image

```bash
$ bash RemoveContainer.sh # if container exist, remove it
$ bash RunContainer.sh    # run container as daemon
$ bash EnterContainer.sh  # enter container as user
```

### Install Docker Engine

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
Executing docker install script, commit: 7cae5f8b0decc17d6571f9f52eb840fbc13b2737
<...>
```

### Manage Docker as a non-root User

Create a group called Docker and add users to it.

```bash
$ sudo groupadd docker && sudo usermod -aG docker $USER
$ newgrp docker
```

### Build Docker Image

```bash
$ bash DockerImageBuilder.sh
```

### Run Image as a Container

1. Check the current installed Docker images:

For example:

```bash
$ docker image ls
REPOSITORY            TAG       IMAGE ID       CREATED             SIZE
aosp-1804-docker      18.04     96da6a6808b5   About an hour ago   4.13GB
```

2. Run image as a container in the background by script:

This script will also add the current user in container.

```bash
$ bash RunContainer.sh [mount path1] [mount path2] ...
```

For example:

```bash
$ bash RunContainer.sh /mnt/storage1 /media
```

### Enter Container

1. Check the current running containers:

```bash
$ docker container ls
CONTAINER ID   IMAGE                     COMMAND                  CREATED             STATUS             PORTS                                   NAMES
1520b180cc2a   aosp-1804-docker:18.04    "/bin/sh -c '/opt/to…"   46 minutes ago      Up 46 minutes                                              aosp-build
```

2. Enter the container by current user:

```bash
$ docker exec -u $USER -ti $(cat ~/ContainerName.log) /bin/bash
```

> NOTE: EnterContainer.sh can be used by same.

### Some docker command usage

* Stop one or more containers:

   ```
   $ docker stop [container]
   ```

* Start one or more stopped containers:

  ```
  $ docker start [container]
  ```

* Remove one or more containers:

  ```
  $ docker rm [container]
  ```

* Remove one or more images:

  ```
  $ docker rmi [image]
  ```

### Some utils

* DockerCleanImage.sh : remove container, image, image cache
* DockerImageBuilder.sh : image builder
* EnterContainer.sh : Enter container
* RemoveContainer.sh : Remove container
* RunContainer.sh : Run container from docker image
