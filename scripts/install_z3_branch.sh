#!/bin/bash
# Executed by Dockerfiles
# Usage:
#   install_z3_branch.sh <repo> <branch> <command_name> <commit>

REPO_URL=$1
BRANCH=$2
COMMAND_NAME=$3
COMMIT=$4
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Change gcc to gcc-7 if z3-trau
if [[ "${COMMAND_NAME}" == "z3-trau" ]]
then
    sudo update-alternatives --remove-all gcc
    sudo apt-get install -y -f gcc-7 g++-7 
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7
fi

# Clone & Build Z3
git clone -b $BRANCH $REPO_URL ${Z3_SRC_DIR}

if [[ ${COMMAND_NAME} == "z3seq" ]] || [[ ${COMMAND_NAME} == "z3str3" ]] || [[ ${COMMAND_NAME} == "z3-trau" ]] # for pldi2020
then
    cd ${Z3_SRC_DIR}
    git checkout ${COMMIT}
fi

cd ${Z3_BUILD_DIR}

if [[ ${COMMAND_NAME} == "trauc" ]]
then
    cmake -DCMAKE_BUILD_TYPE=Debug ${Z3_SRC_DIR}
else
    cmake ${Z3_SRC_DIR}
fi
make

if [[ "${COMMAND_NAME}" == "trauc" ]]
then
    sudo ln "${Z3_BUILD_DIR}/z3" /usr/bin/${COMMAND_NAME}
elif [[ "${COMMAND_NAME}" == "z3-trau" ]]
then
    sudo ln "${Z3_BUILD_DIR}/z3" /usr/bin/${COMMAND_NAME}
else
    sudo ln "${Z3_BUILD_DIR}/z3" /usr/bin/z3
fi
