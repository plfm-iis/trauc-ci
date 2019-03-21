#!/bin/bash

# This script should be set as cron job
# Usage:
#   ./run_by_cron.sh <TARGET> <IMAGE> <BENCHMARK> <tool_id> <commit>
#   <BENCHMARK> should contain no '/' at its end


SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/ci_defaults.sh"
set -x
set -e
set -o pipefail

TARGET=$1
IMAGE=$2
BENCHMARK_TARGET=$3
TOOL_ID=$4
COMMIT=$5
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
  "${BENCHMARK_PATH}/ci_run.sh" ${TARGET} ${BENCHMARK_TARGET})" \
  > "${OUTPUT_DIR}/${TARGET}.${BENCHMARK_TARGET}.log"

# Write results to postgresql
python3 ${SCRIPT_DIR}/write_log_to_db.py ${TOOL_ID} ${TARGET} ${BENCHMARK_TARGET} ${COMMIT}

docker rmi ${TMP_IMAGE} 
