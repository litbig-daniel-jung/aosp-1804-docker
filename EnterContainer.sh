#!/bin/bash

source common-env.sh

docker exec -u $USER -ti $(cat ~/ContainerName.log) /bin/bash
