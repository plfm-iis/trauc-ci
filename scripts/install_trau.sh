#!/bin/bash
# Executed by Dockerfiles

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Install Antlr
wget https://www.antlr.org/download/antlr4-cpp-runtime-4.7.2-source.zip\
	-O antlr.zip

unzip antlr.zip -d antlr
cd antlr
mkdir build && mkdir run
cd build
cmake ../
make && sudo make install

cd $HOME
rm -rf antlr*

TRAU_PATH=$HOME/trau
mkdir -p $TRAU_PATH

# Clone Trau
git clone https://github.com/diepbp/Trau.git $TRAU_PATH
cd $TRAU_PATH

# Install z3-4.4.1.0
unzip z3-z3-4.4.1.0.zip
mv $HOME/z3-4.4.1.0.patches ./
patch -p0 < z3-4.4.1.0.patches
cd z3-z3-4.4.1.0
python3.6 scripts/mk_make.py --prefix="$HOME"
cd build
make && make install

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

sudo cp "$(HOME)/lib/lib*" /usr/local/lib
export LD_LIBRARY_PATH="/usr/local/lib"    # export it

# Finally, build Trau
cd "${TRAU_PATH}/build"; make
sudo ln "${TRAU_PATH}/build/Trau" /usr/bin/Trau

