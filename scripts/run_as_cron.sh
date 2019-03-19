#!/bin/bash

# This script should be set as cron job
# Usage:
#   ./run_as_cron.sh <TARGET> <BENCHMARK>
#   <BENCHMARK> should contain no '/' at its end


SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/../scripts/ci_defaults.sh"
set -x
set -e
set -o pipefail

TARGET=$1
TARGET_IMAGE="${TARGET}:16.04"
BENCHMARK_TARGET=$2

# Build an image, remove it when all done
# Install benchmarks to image

BENCHMARK_DOCKER_FILE="${DOCKER_FILE_DIR}/install_benchmarks.Dockerfile"
docker build \
  -m 4g \
  -f "${BENCHMARK_DOCKER_FILE}" \
  -t "${TARGET_IMAGE}" \
  "--build-arg DOCKER_IMAGE_BASE=${Z3_DOCKER_IMAGE}"

echo \
  "$(docker run --rm -a STDOUT ${TARGET_IMAGE} \
  ${BENCHMARK_PATH}/ci-run.sh ${TARGET} ${BENCHMARK_TARGET})" \
  > "${OUTPUT_DIR}/${TARGET}.${BENCHMARK_TARGET}.log"

docker -rmi ${TARGET_IMAGE} 
