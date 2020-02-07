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

# copy bash script to /usr/bin
cp trau+.sh trauplus
sed -i -e 's/#!bin/#!\/bin/g' -e 's/LD_LIBRARY_PATH=/export LD_LIBRARY_PATH=/g' -e 's/runTrau+.py/\/home\/user\/trauplus\/runTrau+.py/g' trauplus
sudo mv trauplus /usr/bin/
sudo chmod 755 /usr/bin/trauplus

# modify python script to use full path for sloth
path1='./sloth/sloth'
path2="${HOME}/trauplus/sloth/sloth"
sed -i -e 's/timeout = 100000/timeout = 12/g' -e "s~${path1}~${path2}~g" runTrau+.py
