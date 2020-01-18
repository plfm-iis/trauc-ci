#!/bin/bash

# This script should be set as cron job
# Usage:
#   ./run_by_cron.sh <TOOL> <BENCHMARK> <tool_id>
#   <BENCHMARK> should contain no '/' at its end


SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/ci_defaults.sh"
set -x
set -e
set -o pipefail

TOOL=$1
BENCHMARK=$2
TOOL_ID=$3

BENCH_SMALL="$(echo ${BENCHMARK} | tr '[:upper:]' '[:lower:]')"
TOOL_IMAGE="${TOOL}:16.04"
TAG_NAME="${TOOL}-${BENCH_SMALL}-tmp"
#TMP_IMAGE="${TAG_NAME}:16.04"
read COMMIT < ${TOOL}.commit
echo "Run ci on ${BENCHMARK} by ${TOOL}:${COMMIT}"

# Run benchmark check via container from tool image
docker run --rm -a STDOUT -a STDERR \
-v ${BENCHMARK_HOME}:${BENCHMARK_PATH} \
--name ${TAG_NAME} ${TOOL_IMAGE} \
"${BENCHMARK_PATH}/ci_run.sh" ${TOOL} ${BENCHMARK} > "${OUTPUT_DIR}/${TOOL}.${BENCHMARK}.log"

# Write results to postgresql
if [[ ${TOOL_ID} == '-1' ]]
then
    python3 ${SCRIPT_DIR}/write_log_only.py ${TOOL_ID} ${TOOL} ${BENCHMARK} ${COMMIT}
else
    python3 ${SCRIPT_DIR}/write_log_to_db.py ${TOOL_ID} ${TOOL} ${BENCHMARK} ${COMMIT}
fi
