#!/bin/bash

# This script should be set as cron job
# Usage:
#   ./run_trau_branch_as_cron.sh <TARGET> <BENCHMARK> <Tool_id> <Repo_URL> <Branch>
#   <BENCHMARK> should contain no '/' at its end

TARGET=$1
BENCHMARK=$2
TOOL_ID=$3
REPO_URL=$4
BRANCH=$5

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/ci_defaults.sh"
source "${SCRIPT_DIR}/get_commit.sh"
set -x
set -e
set -o pipefail

# Get the latest commit hash
get_commit

# Build an image with <repo_url> <branch> installed
BUILD_OPTS=()
BUILD_OPTS+=("--build-arg" "SCRIPT=install_trau_branch.sh")
BUILD_OPTS+=("--build-arg" "SCRIPT_ARGS=$REPO_URL $BRANCH $TARGET")
BENCH_SMALL="$(echo ${BENCHMARK} | tr '[:upper:]' '[:lower:]')"
TARGET_IMAGE="${TARGET}-${BENCH_SMALL}:16.04"

${SCRIPT_DIR}/check_image_exsist.sh "${TARGET}-${BENCH_SMALL}"
docker build \
  -m 4g \
  -q \
  -f "${S_SCRIPT_DOCKER_FILE}" \
  -t "${TARGET_IMAGE}" \
  "--build-arg" \
  "DOCKER_IMAGE_BASE=${TRAU_BASE_IMAGE}" \
  "${BUILD_OPTS[@]}" \
  .

# Run run_by_cron.sh with this image
${SCRIPT_DIR}/run_by_cron.sh ${TARGET} "${TARGET}-${BENCH_SMALL}" ${BENCHMARK} ${TOOL_ID} ${COMMIT_HASH}

docker rmi ${TARGET_IMAGE} 

