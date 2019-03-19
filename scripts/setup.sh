#!/bin/bash

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/ci_defaults.sh"
set -x
set -e
set -o pipefail

mkdir -p $OUTPUT_DIR

# Build required images

# The base image contains all the dependencies we want to build Z3.
BASE_DOCKER_FILE="${DOCKER_FILE_DIR}/base_ubuntu_16.04.Dockerfile"

BUILD_OPTS=()
BUILD_OPTS+=("--build-arg" "Z3_SRC_DIR=${Z3_SRC_DIR}")
BUILD_OPTS+=("--build-arg" "Z3_BUILD_DIR=${Z3_BUILD_DIR}")
BUILD_OPTS+=("--build-arg" "BENCHMARK_PATH=${BENCHMARK_PATH}")
BUILD_OPTS+=("--build-arg" "BENCHMARK_REPO=${BENCHMARK_REPO}")
docker build -t "${BASE_IMAGE_NAME}" \
    "${BUILD_OPTS[@]}" \
    - < "${BASE_DOCKER_FILE}"

# Build an image with trau installed
TRAU_DOCKER_FILE="${DOCKER_FILE_DIR}/trau_build.Dockerfile"
docker build \
  -f "${TRAU_DOCKER_FILE}" \
  -t "${TRAU_DOCKER_IMAGE}" \
  "--build-arg DOCKER_IMAGE_BASE=${BASE_IMAGE_NAME}"
  .


# Build an image with Z3Prover/z3 installed
BUILD_OPTS=()
BUILD_OPTS+=("--build-arg" "SCRIPT='install_original_z3.sh'")
BUILD_OPTS+=("--build-arg" "SCRIPT_ARG=''")

Z3_DOCKER_FILE="${DOCKER_FILE_DIR}/build_single_script.Dockerfile"
docker build \
  -f "${Z3_DOCKER_FILE}" \
  -t "${Z3_DOCKER_IMAGE}" \
  "--build-arg DOCKER_IMAGE_BASE=${BASE_IMAGE_NAME}"
  "${BUILD_OPTS[@]}" \
  .

