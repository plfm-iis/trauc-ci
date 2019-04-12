#!/bin/bash

# Executed within Container
# COPY while installing benchmarks
TARGET=$1
BENCHMARK_TARGET=$2
cd ${BENCHMARK_PATH}/

DATE=$(date "+%Y%m%d")
python3.6 check_benchmark -c=$TARGET "${BENCHMARK_TARGET}/" > /dev/null

PWD="deploy"
sudo apt-get install -y -f sshpass

if [ "${COMMAND_NAME}" == "z3-trau" ]
    TARGET="z3trau"
    chmod 777 -R trace/
    sshpass -p "$PWD" scp -r trace deploy@10.32.0.252:/home/deploy/traces/${TARGET}.${DATE}.${BENCHMARK_TARGET}

then
fi
cat ${BENCHMARK_TARGET}.${DATE}.${TARGET}.log
echo "LOG.ERR:"
cat ${BENCHMARK_TARGET}.${DATE}.${TARGET}.log.err
echo "LOG.END:"
python3.6 compare_benchmark_logs $BENCHMARK_TARGET
