#!/usr/bin/python3

import os
import sys
import logging
from datetime import datetime
_base_dir = os.path.dirname(os.path.realpath(__file__))
_child_limit = 3  # max number of running child processes in parallel
# BENCHMARK_LIST = ['PyEx_unsat', 'PyEx_sat', 'PyEx_todo', 'cvc4-str-term', 'cvc4-str-pred',
#                   'stringfuzz', 'str_2', 'Leetcode']


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


def run_cmds_in_serial(cmds=[]):
    logging.info("Total number of commands: " + str(len(cmds)))
    if len(cmds) == 0:
        return

    for cmd in cmds:
        logging.info(cmd)
        os.system(cmd)


def main():
    # set env variables
    script_path = f'{os.environ["HOME"]}/ci_scripts/'
    benchmark_path = f'{os.environ["HOME"]}/benchmarks/'
    os.environ["SCRIPT_HOME"] = script_path
    os.environ["BENCHMARK_HOME"] = benchmark_path

    # read tool and benchmark names
    with open(f'{script_path}/ci_tool.list', 'r') as fp_tool:
        tool_list = fp_tool.readlines()
    with open(f'{script_path}/ci_benchmark.list', 'r') as fp_benchmark:
        benchmark_list = fp_benchmark.read().splitlines()

    # prepare benchmark
    os.system("git clone https://github.com/plfm-iis/trauc_benchmarks.git $BENCHMARK_HOME")  # install benchmarks
    os.system("cp scripts/ci_run.sh $BENCHMARK_HOME")
    # Collect commands of checking benchmarks
    tid = -1
    ci_date = datetime.today().strftime('%Y%m%d')
    ci_cmds = []  # a command is a tuple of (cmd, tool_name, benchmark_name)
    img_build_cmds = []
    img_remove_cmds = []
    for t in tool_list:
        tname, repo_url, branch_name = t.split()
        img_build_cmd = f'cd $SCRIPT_HOME && ./scripts/build_docker_image.sh {tname} {repo_url} {branch_name} > /dev/null'
        img_remove_cmd = f'docker rmi {tname}:16.04 && rm {tname}.commit > /dev/null'
        img_build_cmds.append(img_build_cmd)
        img_remove_cmds.append(img_remove_cmd)
        for benchmark_name in benchmark_list:
            ci_cmd = f'cd $SCRIPT_HOME && ./scripts/run_by_cron.sh {tname} {benchmark_name} {tid} {ci_date} > /dev/null'
            ci_cmds.append((ci_cmd, tname, benchmark_name))
    # build images
    logging.info("Build tool images...")
    run_cmds_in_parallel([(a, a, '') for a in img_build_cmds])  # build images of each tool
    # Run ci_cmds
    logging.info("Run checking benchmarks in parallel...")
    run_cmds_in_parallel(ci_cmds)  # run ci script for all tool-benchmark pairs
    # remove images and benchmarks
    logging.info("Cleaning tool images and benchmarks...")
    run_cmds_in_serial(img_remove_cmds)  # remove images of each tool
    os.system("rm -rf $BENCHMARK_HOME")  # remove benchmarks


if __name__ == '__main__':
    ci_log_dir = f'{os.environ["HOME"]}/ci_logs'
    logging.basicConfig(filename=f'{ci_log_dir}/str_ci_alone.log',
                        level=logging.INFO, format='%(asctime)s %(message)s')

    # Check if previous run exists
    ci_pid = str(os.getpid())
    ci_pidfile = f'{ci_log_dir}/str_ci.pid'
    if os.path.isfile(ci_pidfile):
        logging.info("Previous ci.py (" + str(ci_pid) + ") is still running, skip this run.")
        sys.exit()
    with open(ci_pidfile, 'w') as fp:
        fp.write(ci_pid)

    main()

    os.unlink(ci_pidfile)
    logging.info("=== All for today !!===")
