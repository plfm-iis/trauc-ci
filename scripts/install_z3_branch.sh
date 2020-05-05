#!/bin/bash
# Executed by Dockerfiles
# Usage:
#   install_z3_branch.sh <repo> <branch> <command_name>

REPO_URL=$1
BRANCH=$2
COMMAND_NAME=$3
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Change gcc to gcc-7 if z3-trau
#if [ "${COMMAND_NAME}" == "z3-trau" ]
#then
#    sudo update-alternatives --remove-all gcc
#    sudo apt-get install -y -f gcc-7 g++-7
#    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7
#fi

# Clone & Build Z3
git clone -b $BRANCH $REPO_URL ${Z3_SRC_DIR}
cd ${Z3_BUILD_DIR}

if [[ ${COMMAND_NAME} == "trauc" ]]  # debug mode for trauc only
then
    cmake -DCMAKE_BUILD_TYPE=Debug ${Z3_SRC_DIR}
elif [ "${COMMAND_NAME}" == "z3-trau" ]
then
    cmake ${Z3_SRC_DIR}
else
    sudo apt update
    sudo apt -y install python
    cd ${Z3_SRC_DIR}
    ./configure
    cd build
fi
make
#cmake -DCMAKE_BUILD_TYPE=Debug ${Z3_SRC_DIR}
#make

if [ "${COMMAND_NAME}" == "trauc" ]
then
    sudo ln "${Z3_BUILD_DIR}/z3" /usr/bin/${COMMAND_NAME}
elif [ "${COMMAND_NAME}" == "z3-trau" ]
then
    sudo ln "${Z3_BUILD_DIR}/z3" /usr/bin/${COMMAND_NAME}
else
    #sudo ln "${Z3_BUILD_DIR}/z3" /usr/bin/z3
    sudo make install  # z3seq or z3str3
fi
