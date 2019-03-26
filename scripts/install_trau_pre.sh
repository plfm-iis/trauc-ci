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

# Set LANG for scripts/mk_make.py
export LANG=C.UTF-8
python3 -c 'import locale; print(locale.getpreferredencoding())'

# Install z3-4.4.1.0
unzip z3-z3-4.4.1.0.zip
mv $HOME/z3-4.4.1.0.patches ./
patch -p0 < z3-4.4.1.0.patches
cd z3-z3-4.4.1.0
python3.6 scripts/mk_make.py --prefix="$HOME"
cd build
make && make install

sudo cp ${HOME}/lib/lib* /usr/local/lib
