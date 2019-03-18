#!/bin/bash

# Executed within Container
# COPY while installing compiler
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"

set -x
set -e
set -o pipefail

TARGET=$1
BENCHMARK_TARGET=$2
cd ${Z3_BENCHMARK}/

python3 check_benchmark -c=$TARGET "${BENCHMARK_TARGET}/" 2&1 > /dev/null
python3 compare_benchmark_log $BENCHMARK_TARGET
