#!/bin/bash
#./scripts/run_abc_by_cron.sh <TARGET> <BENCHMARK> <Tool_id> <Repo_url> <Branch>

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
BM_LIST=('PyEx_unsat' 'PyEx_sat' 'PyEx_todo' 'Kaluza_unsat' 'Kaluza_sat' 'Kaluza_todo')

echo "tools: abc, ostrich, trauplus"
echo "benchmarks: "${BM_LIST[*]}

set -x
set -e
set -o pipefail

for bm in ${BM_LIST[*]}
do
    ${SCRIPT_DIR}/run_standalone_single.sh abc ${bm} -1 https://github.com/vlab-cs-ucsb/ABC master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")abc-${bm}
    ${SCRIPT_DIR}/run_standalone_single.sh ostrich ${bm} -1  https://github.com/uuverifiers/ostrich master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")ostrich-${bm}
    ${SCRIPT_DIR}/run_standalone_single.sh trauplus ${bm} -1 https://zenodo.org/record/3384428/files/trau+.zip master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")trau+-${bm}
done

