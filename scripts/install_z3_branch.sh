#!/bin/bash
# Executed by Dockerfiles
# Usage:
#   install_z3_branch.sh <repo> <branch> <command_name>

REPO_URL=$1
BRANCH=$2
COMMAND_NAME=$3
SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# Clone & Build Z3
git clone -b $BRANCH $REPO_URL ${Z3_SRC_DIR}
cd ${Z3_BUILD_DIR}

cmake ${Z3_SRC_DIR}
make
make install DESTDIR="${HOME}/"
sudo ln "${HOME}/usr/local/bin/z3" /usr/bin/${COMMAND_NAME}
