#!/bin/bash
# Executed by Dockerfiles
# Usage:
#   install_z3_branch.sh <repo> <branch> <command_name> <commit>

REPO_URL=$1
BRANCH=$2
COMMAND_NAME=$3
COMMIT=$4
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Clone & Build CVC4
git clone -b ${BRANCH} ${REPO_URL} CVC4
cd CVC4
git checkout ${COMMIT}  # for pldi2020

sudo apt update
sudo apt -y install python-pip
pip install toml
./contrib/get-antlr-3.4
./configure.sh
cd build
make
sudo make install
