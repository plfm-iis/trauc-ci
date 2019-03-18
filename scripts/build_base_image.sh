#!/bin/bash

source "${SOURCE_DIR}/ci_defaults.sh"
set -x
set -e
set -o pipefail

# The base image contains all the dependencies we want to build Z3.
BASE_DOCKER_FILE="${DOCKER_FILE_DIR}/base_ubuntu_16.04.Dockerfile"

docker build \
  -t "${BASE_IMAGE}" \
  -f "${BASE_DOCKER_FILE}"

# Build an image with z3 installed
Z3_DOCKER_FILE="${DOCKER_FILE_DIR}/z3_build.Dockerfile"
docker build \
  -f "${Z3_DOCKER_FILE}" \
  -t "${Z3_DOCKER_IMAGE}" \
  "--build-arg DOCKER_IMAGE_BASE=${BASE_IMAGE}"

