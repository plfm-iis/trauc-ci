#!/bin/bash
# Executed by Dockerfiles

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# install python
sudo apt update
sudo apt -y install python

# get trau+ source code
wget https://zenodo.org/record/3384428/files/trau+.zip
unzip trau+.zip
mv trau+ trauplus
cd ${HOME}/trauplus

# modify install.sh
sed -i '/deb/d' install.sh
sed -i '/cvc4/d' install.sh

# build and install trau+
sudo sh install.sh
