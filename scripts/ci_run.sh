#!/bin/bash

# Executed within Container
# COPY while installing benchmarks
TARGET=$1
BENCHMARK_TARGET=$2
DATE=$3
cd ${BENCHMARK_PATH}/

# make a workspace dir and copy necessary files to run benchmark inside container
BENCHMARK_NAME=$(echo ${BENCHMARK_TARGET} | cut -d'.' -f1)  # remove separated target like "benchmark.3.0"
WORK_DIR=${HOME}/workspace
mkdir ${WORK_DIR};
cd ${WORK_DIR}
cp -r ${BENCHMARK_PATH}/${BENCHMARK_NAME} ./
cp ${BENCHMARK_PATH}/check_benchmark ./
cp ${BENCHMARK_PATH}/compare_benchmark_logs ./
python3.6 check_benchmark -c=${TARGET} -d=${DATE} "${BENCHMARK_TARGET}/" > /dev/null

if [[ ${TARGET} == "trauc" ]]
then
    PASSWD=deploy
    chmod 777 -R trace/
    sshpass -p ${PASSWD} scp -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null -r trace deploy@10.32.1.7:/home/deploy/traces/${TARGET}.${DATE}.${BENCHMARK_TARGET}
fi

if [[ "${TARGET}" == "z3-trau" ]]
then
    TARGET="z3trau"

fi

cat ${BENCHMARK_TARGET}.${DATE}.${TARGET}.log
echo "LOG.ERR:"
cat ${BENCHMARK_TARGET}.${DATE}.${TARGET}.log.err
echo "LOG.END:"
python3.6 compare_benchmark_logs ${BENCHMARK_TARGET} -f=${BENCHMARK_TARGET}.${DATE}.${TARGET}.log
