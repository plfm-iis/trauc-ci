#!/bin/bash

# Executed by Dockerfiles
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Clone & Build Z3
git clone https://github.com/Z3Prover/z3.git ${Z3_SRC_DIR}
cd ${Z3_BUILD_DIR}

cmake ${Z3_SRC_DIR}
make
make install DESTDIR="${HOME}/"
sudo ln "${HOME}/usr/local/bin/z3" /usr/bin/z3
