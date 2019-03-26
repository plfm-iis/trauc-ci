#!/bin/bash
# Executed by Dockerfiles
# Usage:
#   install_trau_branch.sh <repo> <branch> <command_name>

REPO_URL=$1
BRANCH=$2
COMMAND_NAME=$3
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

TRAU_PATH=$HOME/trau
rm -rf $TRAU_PATH && mkdir -p $TRAU_PATH

# Clone Trau
git clone -b $BRANCH $REPO_URL ${TRAU_PATH}
cd $TRAU_PATH

# Write config to $TRAU/build/config.mk
TRAU_CONFIG="${TRAU_PATH}/build/config.mk"
echo "CUSTOM_Z3_LIB_PATH := ${HOME}/lib" > $TRAU_CONFIG
echo "CUSTOM_Z3_INCLUDE_PATH := ${HOME}/include" >> $TRAU_CONFIG
echo "ANTLR_RUNTIME_PATH := /usr/local/include/antlr4-runtime" >>  $TRAU_CONFIG
echo "" >> $TRAU_CONFIG
echo "FOPENMP := " >> $TRAU_CONFIG
echo "ifeq ($(shell uname -s) ,Darwin)" >> $TRAU_CONFIG
echo "    FOPENMP := " >> $TRAU_CONFIG
echo "endif " >> $TRAU_CONFIG

# Finally, build Trau
cd "${TRAU_PATH}/build"; make
sudo ln "${TRAU_PATH}/build/Trau" /usr/bin/${COMMAND_NAME}

