# This file should only be sourced

# Variables for host
OUTPUT_DIR="${HOME}/output/"
DOCKER_FILE_DIR="$(cd ${SCRIPT_DIR}/../Dockerfiles/; echo $PWD)"
S_SCRIPT_DOCKER_FILE="${DOCKER_FILE_DIR}/build_single_script.Dockerfile"

BASE_IMAGE_NAME="base_ubuntu:16.04"
Z3_DOCKER_IMAGE="z3_ubuntu:16.04"
TRAU_DOCKER_IMAGE="trau_ubuntu:16.04"
CVC4_DOCKER_IMAGE="cvc4_ubuntu:16.04"

# Set CI variables
Z3_SRC_DIR="/home/user/z3_src/"
Z3_BUILD_DIR="/home/user/z3_build/"

BENCHMARK_REPO="https://github.com/guluchen/z3.git"
BENCHMARK_PATH="/home/user/benchmarks/"
