#!/bin/bash

# DEBUG=false

source common-env.sh

CurPath=`pwd`
Script=`readlink -f $0`
ScriptPath=`dirname $Script`

DockerImageTag='aosp-1804-docker:18.04'
Dockerfile='Dockerfile'

if [ "$DEBUG" = true ]; then
   # ex) /home/me/DockerImageBuilder.sh
   echo -e "${COLOR_BLUE}Script=$Script ${COLOR_REST}"
   # ex) /home/me
   echo -e "${COLOR_BLUE}ScriptPath=$ScriptPath ${COLOR_REST}"
fi

if [ ! -f Dockerfile ]; then
   echo -e "${COLOR_RED}Error! There is no Dockerfile ${COLOR_REST}"
   exit 64
fi

# if [ "$#" -eq 1 ]; then
#    Dockerfile=$1
# else
#    echo -e "${COLOR_RED}Error! please assign a dockerfile ${COLOR_REST}"
#    exit 64
# fi

if which docker; then
   DockerCommand=docker
elif which podman; then
   DockerCommand=podman
else
   "${COLOR_RED}Error! docker command not found ${COLOR_REST}"
   exit 64
fi

cd $ScriptPath/

$DockerCommand build -t $DockerImageTag .

if [ "$?" -eq 0 ]; then
   echo -e "${COLOR_BLUE}Success! $DockerImageTag ${COLOR_REST}"
   $DockerCommand images
else
   echo $?
fi

exit
