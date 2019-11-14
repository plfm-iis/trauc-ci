#!/bin/bash
#./scripts/run_abc_by_cron.sh <TARGET> <BENCHMARK> <Tool_id> <Repo_url> <Branch>

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
BM_LIST=('full_str_int' 'filtered_str_int' 'cvc4-str-term' 'cvc4-str-pred' 'stringfuzz' 'str_2' 'slog' 'Leetcode')

echo "tools: z3, z3str3, cvc4"
echo "benchmarks: "${BM_LIST[*]}

set -x
set -e
set -o pipefail

for bm in ${BM_LIST[*]}
do
    ${SCRIPT_DIR}/run_standalone_single.sh z3seq ${bm} -1 https://github.com/Z3Prover/z3 master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")z3seq-${bm}
    ${SCRIPT_DIR}/run_standalone_single.sh z3str3 ${bm} -1 https://github.com/Z3Prover/z3 master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")z3str3-${bm}
    ${SCRIPT_DIR}/run_standalone_single.sh cvc4 ${bm} -1 http://cvc4.cs.stanford.edu/downloads/builds/x86_64-linux-opt/cvc4-1.7-x86_64-linux-opt master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")cvc4-${bm}
done
