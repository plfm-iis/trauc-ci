#!/bin/bash

Z3_SINICA="${HOME}/z3-sinica"
mkdir -p $Z3_SINICA
git clone --branch master --depth 1 https://github.com/guluchen/z3.git $Z3_SINICA
mv $Z3_SINICA/benchmarks ${Z3_BENCHMARK}
