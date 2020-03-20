#!/bin/bash

####
# Sync all servers' ci_script repo
# ./sync_all.sh <username> <password> <branch>
###
servers=("10.32.1.8" "10.32.0.207" "10.32.0.207" "10.32.0.252" "10.32.1.7" "10.32.0.255" "10.32.0.222" "10.32.0.220" "10.32.0.107")


function run_in_ssh() { # $1: ip address
    ip=$1
    username=$2
    password=$3
    branch=$4
    echo $ip
sshpass -p $password ssh deploy@${ip} /bin/bash << EOF
    cd ci_scripts
    git remote set-url origin https://github.com/plfm-iis/trauc-ci.git
    git pull
    git checkout ${branch}
    git pull
EOF
}



username=$1
password=$2
if [[ "$username" == "" ]] || [[ "$password" == "" ]]
then
    echo "Usage: ./sync_all.sh <username> <password>"
    exit
fi

for _ip in "${servers[@]}"
do
    run_in_ssh ${_ip} ${username} ${password} ${branch}
done
