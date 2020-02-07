#!/bin/bash

# This script builds a docker images for a specified tool.
# Usage:
#   ./build_docker_image.sh <TOOL> <Repo_url> <Branch>
#   <TOOL> should be one of [z3-trau, cvc4, z3seq, z3str3, trau]

TOOL=$1
REPO_URL=$2
BRANCH=$3

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/ci_defaults.sh"
set -x
set -e
set -o pipefail

# Get the latest commit hash
if [[ ${REPO_URL} =~ 'github' ]]
then
    TMPDIR=${TOOL}-${BRANCH}
    rm -rf $TMPDIR
    mkdir $TMPDIR
    git clone --branch $BRANCH $REPO_URL ${TMPDIR}
    cd ${TMPDIR}
    COMMIT_HASH="$(git log -1 --abbrev-commit --oneline $BRANCH | awk '{print $1}')"
    cd ../ && rm -rf ${TMPDIR}
    echo "Build tool image of ${TOOL}: commit hash=${COMMIT_HASH}"
    echo ${COMMIT_HASH} > ${TOOL}.commit  # write commit hash to file
else
    echo "Build tool image of ${TOOL}: url=${REPO_URL}"  # use repository url as commit
    echo ${REPO_URL} > ${TOOL}.commit  # write commit hash to file
fi

# Build an image with <repo_url> <branch> installed, also install benchmarks too
BUILD_OPTS=()
if [[ ${TOOL} == "cvc4" ]]
then
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_cvc4_branch.sh")
elif [[ ${TOOL} == "trau" ]]
then
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_trau_branch.sh")
elif [[ ${TOOL} == "trauplus" ]]
then
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_trauplus.sh")
elif [[ ${TOOL} == "abc" ]]
then
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_abc.sh")
elif [[ ${TOOL} == "ostrich" ]]
then
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_ostrich.sh")
else
    BUILD_OPTS+=("--build-arg" "SCRIPT=install_z3_branch.sh")
fi
BUILD_OPTS+=("--build-arg" "SCRIPT_ARGS=${REPO_URL} ${BRANCH} ${TOOL}")
TOOL_IMAGE="${TOOL}:16.04"

# delete image built for last run
${SCRIPT_DIR}/check_image_exsist.sh ${TOOL}

# build image for this run
docker build \
  -m 4g \
  -q \
  -f "${S_SCRIPT_DOCKER_FILE}" \
  -t "${TOOL_IMAGE}" \
  "--build-arg" \
  "DOCKER_IMAGE_BASE=${BASE_IMAGE_NAME}" \
  "${BUILD_OPTS[@]}" \
  .

# further build image to install benchmarks (with the same name)
#BENCHMARK_DOCKER_FILE="${DOCKER_FILE_DIR}/install_benchmarks.Dockerfile"
#docker build \
#  -m 4g \
#  -q \
#  -f "${BENCHMARK_DOCKER_FILE}" \
#  -t "${TOOL_IMAGE}" \
#  "--build-arg" \
#  "DOCKER_IMAGE_BASE=${TOOL_IMAGE}" \
#  .

# Run run_by_cron.sh with this image
#${SCRIPT_DIR}/run_by_cron.sh ${TARGET} "${TARGET}-${BENCH_SMALL}" ${BENCHMARK} ${TOOL_ID} ${COMMIT_HASH}
#
#docker rmi ${TARGET_IMAGE}
