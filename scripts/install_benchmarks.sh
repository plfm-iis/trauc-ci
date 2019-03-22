#!/bin/bash

# Executed by Dockerfiles
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

Z3_SINICA="${HOME}/z3-sinica"
mkdir -p $Z3_SINICA

git clone --branch master --depth 1 ${BENCHMARK_REPO} $Z3_SINICA
mv ${Z3_SINICA}/benchmarks/* ${BENCHMARK_PATH}

# Remove any logs happen to be existed
rm -f ${BENCHMARK_PATH}/*log ${BENCHMARK_PATH}/*log.err ${BENCHMARK_PATH}/*.result ${BENCHMARK_PATH}/*.note

cd $HOME
