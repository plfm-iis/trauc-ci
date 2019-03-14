#!/bin/bash

# Clone & Build Z3seq
git clone https://github.com/Z3Prover/z3.git ${Z3_SRC_DIR}
cd ${Z3_BUILD_DIR}

cmake ${Z3_SRC_DIR}
make
sudo ln ${Z3_BUILD_DIR}/z3 /usr/bin/z3
