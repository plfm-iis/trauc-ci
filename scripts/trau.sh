#!/bin/bash

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Install Antlr
wget https://www.antlr.org/download/antlr4-cpp-runtime-4.7.2-source.zip\
	-O antlr.zip

unzip antlr.zip 0d antlr
cd antlr
mkdir build && mkdir run
cd build
cmake ../
make && sudo make install

TRAU_PATH=$HOME/trau
mkdir -p $TRAU_PATH

# Clone Trau
git clone https://github.com/diepbp/Trau.git $TRAU_PATH

TRAU_CONFIG="${TRAU_PATH}/build/config.mk"
echo "CUSTOM_Z3_LIB_PATH := ${Z3_BUILD_DIR}/lib" > $TRAU_CONFIG
echo "CUSTOM_Z3_INCLUDE_PATH := ${Z3_BUILD_DIR}/include" >> $TRAU_CONFIG
echo "ANTLR_RUNTIME_PATH := /usr/local/include/antlr4-runtime" >>  $TRAU_CONFIG
echo "" >> $TRAU_CONFIG
echo "FOPENMP := " >> $TRAU_CONFIG
echo "ifeq ($(shell uname -s) ,Darwin)" >> $TRAU_CONFIG
echo "    FOPENMP := " >> $TRAU_CONFIG
echo "endif " >> $TRAU_CONFIG

export LD_LIBRARY_PATH="/usr/local/lib"    # export it
cd "${TRAU_PATH}/build"; make

sudo ln "${TRAU_PATH}/build/trau" /usr/bin/trau
