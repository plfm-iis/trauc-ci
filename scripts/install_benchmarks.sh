#!/bin/bash

# Executed by Dockerfiles
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail


git clone --branch master --depth 1 ${BENCHMARK_REPO} $BENCHMARK_PATH

# Remove any logs happen to be existed
rm -f ${BENCHMARK_PATH}/*log ${BENCHMARK_PATH}/*log.err ${BENCHMARK_PATH}/*.result ${BENCHMARK_PATH}/*.note

cd $HOME
