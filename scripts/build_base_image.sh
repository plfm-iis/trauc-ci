#!/bin/bash

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

DOCKER_FILE_DIR="$(cd ${SCRIPT_DIR}/../Dockerfiles; echo $PWD)"

# The base image contains all the dependencies we want to build Z3.
BASE_DOCKER_FILE="${DOCKER_FILE_DIR}/z3_base_ubuntu_16.04.Dockerfile"
BASE_DOCKER_IMAGE_NAME="z3_base_ubuntu:16.04"

docker build \
	-t "${BASE_DOCKER_IMAGE_NAME}" \
	-f "${BASE_DOCKER_FILE}"
