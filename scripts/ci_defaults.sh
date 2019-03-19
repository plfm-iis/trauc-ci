# This file should only be sourced

# Set CI variables
DOCKER_FILE_DIR="$(cd ${SCRIPT_DIR}/../Dockerfiles; echo $PWD)"

BASE_IMAGE="base_ubuntu:16.04"
Z3_DOCKER_IMAGE="z3_ubuntu:16.04"
TRAU_DOCKER_IMAGE="trau_ubuntu:16.04"

Z3_SRC_DIR="/home/user/z3_src/"
Z3_BUILD_DIR="/home/user/z3_build/"
Z3_BENCHMARK="/home/user/z3_benchmark/"

BENCHMARK_REPO="https://github.com/guluchen/z3.git"
BENCHMARK_PATH="/benchmarks/"

# Variables for host
OUTPUT_DIR="${HOME}/output/"
