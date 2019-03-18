#!/bin/bash

# Build an image, remove it when all done
# Install benchmarks to image
source "${SOURCE_DIR}/ci_defaults.sh"
set -x
set -e
set -o pipefail

BENCHMARK_TARGET=$1
TARGET_IMAGE="z3seq:16.04"
BENCHMARK_DOCKER_FILE="${DOCKER_FILE_DIR}/install_benchmarks.Dockerfile"
docker build \
  -m 4g \
  -f "${BENCHMARK_DOCKER_FILE}" \
  -t "${TARGET_IMAGE}" \
  "--build-arg DOCKER_IMAGE_BASE=${Z3_DOCKER_IMAGE}"

echo \
  "$(docker run --rm -a STDOUT ${TARGET_IMAGE} \
  ${BENCHMARK_PATH}/ci-run.sh z3seq ${BENCHMARK_TARGET})" \
  > "${OUTPUT_DIR}/z3seq_${BENCHMARK_TARGET}.log"

docker -rmi ${TARGET_IMAGE} 
