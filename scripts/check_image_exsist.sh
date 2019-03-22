#!/bin/bash

# Usage:
#   ./check_image_exsist.sh <tag name>

TAG_NAME="$1"
ANS="$(docker image ls | grep $TAG_NAME)"

if [ "$ANS" == "" ]
then
    echo "Image name safe"
else
    echo "Image duplicated, rmi it"
    docker rmi ${TAG_NAME}:16.04
fi
