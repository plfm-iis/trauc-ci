#!/usr/bin/python3

import os
import sys
import logging
from datetime import datetime
_base_dir = os.path.dirname(os.path.realpath(__file__))
_child_limit = 3  # max number of running child processes in parallel
BENCHMARK_LIST = ['PyEx_unsat', 'PyEx_sat', 'PyEx_todo', 'cvc4-str-term', 'cvc4-str-pred',
                  'stringfuzz', 'str_2', 'Leetcode']


def run_cmds_in_parallel(cmds=[]):  # cmds: list of 3-tuples
    logging.info("Total number of commands: " + str(len(cmds)))
    if len(cmds) == 0:
        return

    children = []
    for cmd in cmds:
        # Check if maximum number of child processes is reached. If yes, wait one to terminate.
        while len(children) >= _child_limit:
            p = os.wait()
            logging.info("terminated process: " + str(p[0]))
            if p[0] in children:
                children.remove(p[0])

        child = os.fork()
        if child:  # parent
            children.append(child)
            logging.info("Child process forked: " + str(child) + ", cmd: " + cmd[0] +
                         ", total child processes: " + str(len(children)))
        else:  # child
            logging.info(cmd[0])
            if os.system(cmd[0]) != 0:
                logging.info("Failed: " + cmd[1] + " " + cmd[2])
            else:
                logging.info("Succeeded: " + cmd[1] + " " + cmd[2])
            os._exit(0)

    # wait for remaining children to terminate
    while len(children) > 0:
        p = os.wait()
        logging.info("terminated process: " + str(p[0]))
        if p[0] in children:
            children.remove(p[0])


def main():
    os.environ["SCRIPT_HOME"] = "/home/deploy/ci_scripts/"
    os.environ["BENCHMARK_HOME"] = "/home/deploy/benchmarks/"
    # for trauplus only
    tname = 'trauplus'
    tid = -1
    ci_date = datetime.today().strftime('%Y%m%d')
    # Collect commands of checking benchmarks
    ci_cmds = []  # a command is a tuple of (cmd, tool_name, benchmark_name)
    for benchmark_name in BENCHMARK_LIST:
        ci_cmd = f'cd $SCRIPT_HOME && ./scripts/run_by_cron.sh {tname} {benchmark_name} {tid} {ci_date} > /dev/null'
        ci_cmds.append((ci_cmd, tname, benchmark_name))
    logging.info("Run checking benchmarks in parallel...")
    run_cmds_in_parallel(ci_cmds)  # run ci script for all tool-benchmark pairs


if __name__ == '__main__':
    logging.basicConfig(filename='/home/deploy/ci_logs/str_ci_trauplus.log',
                        level=logging.INFO, format='%(asctime)s %(message)s')

    # Check if previous run exists
    ci_pid = str(os.getpid())
    ci_pidfile = "/home/deploy/ci_logs/str_ci.pid"
    if os.path.isfile(ci_pidfile):
        logging.info("Previous ci.py (" + str(ci_pid) + ") is still running, skip this run.")
        sys.exit()
    with open(ci_pidfile, 'w') as fp:
        fp.write(ci_pid)

    main()

    os.unlink(ci_pidfile)
    logging.info("=== All for today !!===")
