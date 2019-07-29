#!/bin/bash

# Executed within Container
# COPY while installing benchmarks
TARGET=$1
BENCHMARK_TARGET=$2
cd ${BENCHMARK_PATH}/

DATE=$(date "+%Y%m%d")
if [ "${BENCHMARK_TARGET}" == "filtered_str_int" ]
then
    git clone https://github.com/spencerwuwu/str_int_benchmarks.git
    rm -rf ${BENCHMARK_TARGET}
    mv str_int_benchmarks/${BENCHMARK_TARGET} ./
fi
if [ "${BENCHMARK_TARGET}" == "full_str_int" ]
then
    git clone https://github.com/spencerwuwu/str_int_benchmarks.git
    rm -rf ${BENCHMARK_TARGET}
    mv str_int_benchmarks/${BENCHMARK_TARGET} ./
fi

python3.6 check_benchmark -c=$TARGET "${BENCHMARK_TARGET}/" > /dev/null

if [ $TARGET == "trauc" ]
then
    PASSWD=deploy
    chmod 777 -R trace/
    sshpass -p $PASSWD scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r trace deploy@10.32.1.7:/home/deploy/traces/${TARGET}.${DATE}.${BENCHMARK_TARGET}
fi

if [ "${TARGET}" == "z3-trau" ]
then
    TARGET="z3trau"

fi

cat ${BENCHMARK_TARGET}.${DATE}.${TARGET}.log
echo "LOG.ERR:"
cat ${BENCHMARK_TARGET}.${DATE}.${TARGET}.log.err
echo "LOG.END:"
python3.6 compare_benchmark_logs $BENCHMARK_TARGET
