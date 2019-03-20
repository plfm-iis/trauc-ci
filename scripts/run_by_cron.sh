#!/bin/bash

# This script should be set as cron job
# Usage:
#   ./run_by_cron.sh <TARGET> <IMAGE> <BENCHMARK>
#   <BENCHMARK> should contain no '/' at its end


SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/../scripts/ci_defaults.sh"
set -x
set -e
set -o pipefail

TARGET=$1
IMAGE=$2
BENCHMARK_TARGET=$3
TARGET_IMAGE="${IMAGE}:16.04"
TMP_IMAGE="${TARGET}-tmp:16.04"

# Build an image, remove it when all done
# Install benchmarks to image

BENCHMARK_DOCKER_FILE="${DOCKER_FILE_DIR}/install_benchmarks.Dockerfile"
docker build \
  -m 4g \
  -f "${BENCHMARK_DOCKER_FILE}" \
  -t "${TMP_IMAGE}" \
  "--build-arg" \
  "DOCKER_IMAGE_BASE=${TARGET_IMAGE}" \
  .

echo \
  "$(docker run --rm -a STDOUT ${TMP_IMAGE} \
  ${BENCHMARK_PATH}/ci-run.sh ${TARGET} ${BENCHMARK_TARGET})" \
  > "${OUTPUT_DIR}/${TARGET}.${BENCHMARK_TARGET}.log"

docker -rmi ${TMP_IMAGE} 
