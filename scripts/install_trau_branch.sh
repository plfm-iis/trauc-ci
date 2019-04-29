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

# Install newest z3 for Trau os system call
cd $HOME
wget https://github.com/Z3Prover/z3/releases/download/z3-4.8.4/z3-4.8.4.d6df51951f4c-x64-debian-8.11.zip -O z3.zip
unzip z3.zip -d z3_orig
sudo ln "${HOME}/z3_orig/z3-4.8.4.d6df51951f4c-x64-debian-8.11/bin/z3" /usr/local/bin/z3

# Install newest cvc4 for Trau os system call
wget http://cvc4.cs.stanford.edu/downloads/builds/x86_64-linux-opt/cvc4-1.6-x86_64-linux-opt \
        -O cvc4
chmod +x cvc4
sudo ln ${HOME}/cvc4 /usr/local/bin/cvc4
