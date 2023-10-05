#!/bin/bash

source common-env.sh

CurPath=`pwd`
ScriptPath=`dirname $(readlink -f "$0")`

DockerImage=`grep 'DockerImageTag=' ./DockerImageBuilder.sh | awk -F= '{print $2}' | awk -F\' '{print $2}'`

# ContainerName='container_'$USER
ContainerName='aosp-build-1804'

if [ "$DEBUG" = true ]; then
   ContainerID=`cat docker_run.log`
   ContainerShortID=${ContainerID:0:12}

   # ex) /home/me
   echo -e "${COLOR_BLUE}ContainerName    : $ContainerName ${COLOR_REST}"
   echo -e "${COLOR_BLUE}ContainerShortID : $ContainerShortID ${COLOR_REST}"
fi

docker rm -f $ContainerName

exit
