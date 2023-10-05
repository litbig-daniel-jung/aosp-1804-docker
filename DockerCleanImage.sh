#!/bin/bash

source common-env.sh

CurPath=`pwd`
ScriptPath=`dirname $(readlink -f "$0")`

DockerImage=`grep 'DockerImageTag=' ./DockerImageBuilder.sh | awk -F= '{print $2}' | awk -F\' '{print $2}'`

ContainerName='aosp-build-1804'

if [ "$DEBUG" = true ]; then
   # ex) /home/me
   echo -e "${COLOR_BLUE}ScriptPath      : $ScriptPath ${COLOR_REST}"
   echo -e "${COLOR_BLUE}DockerImage     : $DockerImage ${COLOR_REST}"
   echo -e "${COLOR_BLUE}ContainerName   : $ContainerName ${COLOR_REST}"
fi

docker rm -f $ContainerName
docker rmi -f $DockerImage
docker image prune -f
docker builder prune -f --verbose

exit
