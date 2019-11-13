#!/bin/bash
#./scripts/run_abc_by_cron.sh <TARGET> <BENCHMARK> <Tool_id> <Repo_url> <Branch>

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
BM_LIST=('full_str_int' 'filtered_str_int' 'cvc4-str-term' 'cvc4-str-pred' 'stringfuzz' 'str_2' 'slog' 'Leetcode')

echo "tools: abc, ostrich, trau+"
echo "benchmarks: "${BM_LIST[*]}

for bm in ${BM_LIST[*]}
do
    ${SCRIPT_DIR}/run_standalone_single.sh abc ${bm} -1 https://github.com/vlab-cs-ucsb/ABC master 2>&1 | tee ~/ci_logs/$(date "+%Y%m%d")abc-${bm}
    ${SCRIPT_DIR}/run_standalone_single.sh ostrich ${bm} -1  https://github.com/uuverifiers/ostrich master 2>&1 | tee ~/ci_logs/$(date "+%Y%m%d")ostrich-${bm}
    ${SCRIPT_DIR}/run_standalone_single.sh trau+ ${bm} -1 https://zenodo.org/record/3384428/files/trau+.zip master 2>&1 | tee ~/ci_logs/$(date "+%Y%m%d")trau+-${bm}
done

