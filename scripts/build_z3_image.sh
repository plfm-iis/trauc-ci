#!/bin/bash

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

DOCKER_FILE_DIR="$(cd ${SCRIPT_DIR}/../Dockerfiles; echo $PWD)"

BUILD_OPTS=()
# Pass Docker build arguments
# When building an image, Docker steps through the instructions 
# in your Dockerfile, executing each in the order specified. 
# As each instruction is examined, Docker looks for an existing 
# image in its cache that it can reuse, rather than creating a 
# new (duplicate) image.

# The base image contains all the dependencies we want to build Z3.
BASE_DOCKER_FILE="${DOCKER_FILE_DIR}/z3_base_ubuntu_16.04.Dockerfile"
BASE_DOCKER_IMAGE_NAME="z3_base_ubuntu:16.04"

docker build -t "${BASE_DOCKER_IMAGE_NAME}" - < "${BASE_DOCKER_FILE}"
DOCKER_BUILD_FILE="${DOCKER_FILE_DIR}/z3_build.Dockerfile"
BUILD_OPTS+=( \
	"--build-arg" \
	"DOCKER_IMAGE_BASE=${BASE_DOCKER_IMAGE_NAME}" \
)

# Now build Z3 and test it using the created base image
docker build \
  -f "${DOCKER_BUILD_FILE}" \
  "${BUILD_OPTS[@]}" \
  .
