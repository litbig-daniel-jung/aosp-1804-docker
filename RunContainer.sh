#!/bin/bash

# $ bash RunContainer.sh [mount dir] [mount dir] ...

source common-env.sh

CurPath=`pwd`
ScriptPath=`dirname $(readlink -f "$0")`

DockerImage=`grep 'DockerImageTag=' ./DockerImageBuilder.sh | awk -F= '{print $2}' | awk -F\' '{print $2}'`

# ContainerName='container_'$USER
ContainerName='aosp-build-1804'

MountHome="--mount type=bind,source=$HOME,target=$HOME"
MountDir=$MountHome

if [ $# -gt 0 ]; then
   for arg in $@; do
      # check path exist
      if [ ! -d $arg ]; then
         echo "[Error!] This path does not exist: $arg"
         exit
      fi
      
      # check permission
      ls $arg > /dev/null
      if [ "$?" -gt 0 ]; then
         echo "[Error!] you do not have permission for this path: $arg"
         exit
      fi
      
      echo $path
      if [ "$arg" = "$HOME" ] || [ "$arg" = "$HOME/" ]; then
         continue
      else
         MountDir=$MountDir" --mount type=bind,source=$arg,target=$arg"
      fi    
   done
else
   echo "default mount home dir: $HOME"
fi

OptionNamespace='--userns=host'
OptionTimezone="-e TZ=$(cat /etc/timezone) "
OptionHome="-e HOME=$HOME"

if [ "$DEBUG" = true ]; then
   # ex) /home/me
   echo -e "${COLOR_BLUE}ScriptPath      : $ScriptPath ${COLOR_REST}"
   echo -e "${COLOR_BLUE}DockerImage     : $DockerImage ${COLOR_REST}"

   echo -e "${COLOR_BLUE}ContainerName   : $ContainerName ${COLOR_REST}"
   echo -e "${COLOR_BLUE}MountDir        : $MountDir ${COLOR_REST}"

   echo -e "${COLOR_BLUE}OptionNamespace : $OptionNamespace ${COLOR_REST}"
   echo -e "${COLOR_BLUE}OptionTimezone  : $OptionTimezone ${COLOR_REST}"
   echo -e "${COLOR_BLUE}OptionHome      : $OptionHome ${COLOR_REST}"
fi

# docker run -d -u root \
#     --name container_daniel \
#     --mount type=bind,source=/home/daniel,target=/home/daniel \
#     --mount type=bind,source=/media,target=/media \
#     --userns=host \
#     -e TZ=Asia/Seoul \
#     -e HOME=/home/daniel \
#     -i aosp-1804:18.04 \
#        > docker_run.log
docker run --privileged --device /dev/bus -v /dev/bus:/dev/bus -d -u root --name $ContainerName $MountDir $OptionNamespace $OptionTimezone $OptionHome -i $DockerImage > docker_run.log

ErrCode=$?
if [ "$ErrCode" -ne 0 ]; then
   echo -e "${COLOR_RED}Fail run container, error code: $ErrCode${COLOR_REST}"
   cat docker_run.log
   exit $ErrCode
else
   ContainerID=`cat docker_run.log`
   ContainerShortID=${ContainerID:0:12}
   # docker container rename $ContainerName 'container_internal_'$ContainerShortID
   # docker container rename $ContainerName 'aosp-build'
   # ContainerName='container_internal_'$ContainerShortID
fi

# necessary for user namespace
docker exec -i $ContainerName /bin/bash -c "chown -R man /var/cache/man"
docker exec -i $ContainerName /bin/bash -c "mkdir -p $HOME"

# add current user
Groups=$(id -nG)
for g in ${Groups}; do
   docker exec -i $ContainerName /bin/bash -c "addgroup --gid $(getent group $g | cut -d: -f3) $g"
done

docker exec -i $ContainerName /bin/bash -c "useradd ${USER} --create-home --home-dir $HOME --shell /bin/bash -g $(id -g) --uid=$(id -u)"
docker exec -i $ContainerName /bin/bash -c "echo "${USER}:${USER}" | chpasswd"

for g in ${Groups}; do
   docker exec -i $ContainerName /bin/bash -c "adduser $USER $g"
done

echo "$ContainerName" > ~/ContainerName.log
echo "$ContainerName" >> ~/ContainerName_history.log
echo "Please memorise your container: $ContainerName"

exit
