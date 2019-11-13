#!/bin/bash
# Executed by Dockerfiles

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# install python2
sudo apt -y install python

# Clone & Build ABC
git clone https://github.com/vlab-cs-ucsb/ABC.git ${HOME}/ABC
cd ${HOME}/ABC/build

./install-build-deps.py

