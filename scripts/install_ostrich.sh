#!/bin/bash
# Executed by Dockerfiles

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
set -x
set -e
set -o pipefail

# install scala
sudo apt -y install scala

# install sbt
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt

# Clone & Build ostrich
git clone https://github.com/uuverifiers/ostrich.git ${HOME}/ostrich
cd ${HOME}/ostrich

sbt assembly

cd ${HOME}
echo "#"'!'"/bin/bash" > ostrich111
echo "/home/user/ostrich/ostrich +quiet \"\$@\"" >> ostrich111
sudo mv ostrich111 /usr/bin/ostrich
sudo chmod 755 /usr/bin/ostrich

