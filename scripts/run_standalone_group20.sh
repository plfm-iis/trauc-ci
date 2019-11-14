#!/bin/bash
#./scripts/run_abc_by_cron.sh <TARGET> <BENCHMARK> <Tool_id> <Repo_url> <Branch>

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
BM_LIST=('PyEx_unsat' 'PyEx_sat' 'PyEx_todo' 'Kaluza_unsat' 'Kaluza_sat' 'Kaluza_todo')

echo "tools: z3-trau, trauc"
echo "benchmarks: "${BM_LIST[*]}

set -x
set -e
set -o pipefail

for bm in ${BM_LIST[*]}
do
    ${SCRIPT_DIR}/run_standalone_single.sh z3-trau ${bm} -1 https://github.com/guluchen/z3 new_trau 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")z3-trau-${bm}
    ${SCRIPT_DIR}/run_standalone_single.sh trauc ${bm} -1 https://github.com/guluchen/z3 master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")trauc-${bm}
done
