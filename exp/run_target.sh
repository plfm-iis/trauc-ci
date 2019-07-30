#!/bin/bash

TARGET=$1
BENCHMARK_TARGET=$2

# target = z3seq, z3str, cvc4, trauc(z3-trau)

python3 check_benchmark -c=$TARGET "${BENCHMARK_TARGET}/" > /dev/null
python3 compare_benchmark_logs $BENCHMARK_TARGET > "results/${TARGET}-${BENCHMARK_TARGET}"
rm -rf *.log*
