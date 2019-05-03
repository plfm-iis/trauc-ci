#!/bin/bash
# Executed by Dockerfiles

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Install CVC4
wget http://cvc4.cs.stanford.edu/downloads/builds/x86_64-linux-opt/cvc4-1.7-x86_64-linux-opt \
        -O cvc4
chmod +x cvc4
sudo ln ${HOME}/cvc4 /usr/bin/cvc4

