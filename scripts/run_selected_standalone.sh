#!/bin/bash
#./scripts/run_abc_by_cron.sh <TARGET> <BENCHMARK> <Tool_id> <Repo_url> <Branch>

#TOOL_LIST=('abc https://github.com/vlab-cs-ucsb/ABC run_abc_by_cron.sh' 'ostrich https://github.com/uuverifiers/ostrich run_ostrich_by_cron.sh')
BM_LIST=('full_str_int' 'filtered_str_int' 'cvc4-str-term' 'cvc4-str-pred' 'stringfuzz' 'str_2' 'slog' 'Leetcode')

echo "tools: abc, ostrich"
echo "benchmarks: "${BM_LIST[*]}

for bm in ${BM_LIST[*]}
do
#    ./scripts/run_abc_by_cron.sh abc ${bm} -1 https://github.com/vlab-cs-ucsb/ABC master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")abc
    ./scripts/run_ostrich_by_cron.sh ostrich ${bm} -1  https://github.com/uuverifiers/ostrich master 2>&1 | tee -a ~/ci_logs/$(date "+%Y%m%d")ostrich
done

