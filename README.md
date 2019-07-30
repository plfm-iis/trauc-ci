# Str-solver CI scripts

## Installation
Run `scripts/setup.sh` to build basic dockers.

## Usage
The main entry point is **core/ci.py**.   
This script is executed everyday by crontab.
You can find this line in `/etc/crontab`
```
12 1    * * *   deploy  cd /home/deploy/ci_scripts && ./core/ci.py > /home/deploy/ci_logs/$(date "+\%Y\%m\%d") 2>&1
```

## Logs
Log for the cronjob is located in **$HOME/ci_logs**.   
**$HOME/ci_logs_full/** contains log for each docker on that day.   
**$HOME/output** is the final result log for each docker.
These files will be parsed and stored into database by **core/ci.py** 
with **scripts/write_log_to_db.py**.

## Experiments
There are scripts available in **exp/**.
