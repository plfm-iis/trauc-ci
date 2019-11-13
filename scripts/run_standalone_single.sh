#!/bin/bash

# This script is ment for run independly (standalone, not a cron job)
# Usage:
#   ./run_standalone.sh <TARGET> <BENCHMARK> <Tool_id> <Repo_url> <Branch>
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
if [ ${TARGET} == 'z3' ] || [ ${TARGET} == 'z3-trau' ] || [ ${TARGET} == 'trauc' ] || [ ${TARGET} == 'z3str3' ]
then
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_z3_branch.sh")
    BUILD_OPTS+=("--build-arg" "SCRIPT_ARGS=$REPO_URL $BRANCH $TARGET")
else
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_${TARGET}.sh")
    BUILD_OPTS+=("--build-arg" "SCRIPT_ARGS=")
fi
TARGET_IMAGE="${TARGET}:16.04"

${SCRIPT_DIR}/check_image_exsist.sh ${TARGET}
docker build \
  -m 4g \
  -q \
  -f "${S_SCRIPT_DOCKER_FILE}" \
  -t "${TARGET_IMAGE}" \
  "--build-arg" \
  "DOCKER_IMAGE_BASE=${BASE_IMAGE_NAME}" \
  "${BUILD_OPTS[@]}" \
  .

# Run run_by_cron.sh with this image
${SCRIPT_DIR}/run_by_cron.sh ${TARGET} ${TARGET} ${BENCHMARK} ${TOOL_ID} ${COMMIT_HASH}

docker rmi ${TARGET_IMAGE} 

