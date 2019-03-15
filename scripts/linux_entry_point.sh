#!/bin/bash

TARGET_NAME=$1
DOCKER_BUILD_SCRIPT=$2
TARGET_RESULT_LOC=$3
TARGET_IMAGE="${TARGET_NAME}_image"

BUILD_OPTS=()

BASE_DOCKER_IMAGE_NAME="z3_base_ubuntu:16.04"

BUILD_OPTS+=( \
"--build-arg" \
"DOCKER_IMAGE_BASE=${BASE_DOCKER_IMAGE_NAME}" \
)

docker build \
  -m 4g \
  -f "${DOCKER_BUILD_FILE}" \
  -t "${TARGET_IMAGE}" \
  "${BUILD_OPTS[@]}" \
  .

docker run --name "${TARGET_NAME}_result" --rm ${TARGET_IMAGE} /usr/bin/cat ${TARGET_RESULT_LOC}
docker rmi ${TARGET_IMAGE}
