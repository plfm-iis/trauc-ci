#!/usr/bin/python3

import os
import sys
import logging
from datetime import datetime
_base_dir = os.path.dirname(os.path.realpath(__file__))
_child_limit = 3  # max number of running child processes in parallel


def run_sql(sql):
    logging.info(sql)
    return os.popen("psql \
            -X \
            -t \
            -U pguser \
            -h trauc-db -p 5432 \
            --set ON_ERROR_STOP=on \
            --set AUTOCOMMIT=off \
            -d ci \
            --field-separator , \
            --quiet \
            --no-align \
            -c" + "\"" + sql + "\"").read()


def update_sql(sql):
    logging.info(sql)
    return os.popen("psql \
            -U pguser \
            -h trauc-db -p 5432 \
            -d ci \
            -c" + "\"" + sql + "\"").read()


# Get tool list
def get_targets():
    return run_sql("SELECT id FROM tools")


# For a given target tool (tid), update days-to-run and generate commands if activated for checking
def process_target(tid):
    [tname, cycle, command, repo_url, branch_name, commit] = \
            run_sql(f'SELECT name, test_cycle, command, repo_url, branch_name, '
                    f'lastest_commit FROM tools WHERE id={tid}').replace("\n","").split(",")

    # Get benchmarks
    benchmark_type = os.environ["CI_BENCHMARK_TYPE"]
    benchmark_type_id = run_sql("SELECT id from benchmark_types WHERE name=\'" + benchmark_type + "\';").replace("\n", "")

    # Verify days to run
    [d_id, days_to_run] = \
            run_sql("SELECT id,days from days_to_runs WHERE benchmark_type_id=" + benchmark_type_id + " AND tool_id=" + tid + ";").replace("\n", "").split(",")
    if len(days_to_run) == 0:
        logging.info(update_sql("UPDATE days_to_runs SET days = 1 WHERE id=" + d_id))
    else:
        days_to_run = int(days_to_run) - 1

    cycle = int(cycle)

    # Check the execution cycle
    if days_to_run == 0:
        days_to_run = cycle
        logging.info("Running ci for " + tname)
        logging.info(update_sql("UPDATE days_to_runs SET days = " + str(cycle) +" WHERE id=" + d_id))
    elif days_to_run < 0:
        logging.info("Skip " + tname)
        return [], "", ""
    else:
        logging.info(str(days_to_run) + "/" + str(cycle) + " days for " + tname)
        logging.info(update_sql("UPDATE days_to_runs SET days = " + str(days_to_run) +" WHERE id=" + d_id))
        return [], "", ""

    # Check if new commit
    """
    if len(commit) != 0 and commit != "-" and len(repo_url) != 0:
        new_commit = os.popen("git ls-remote " + repo_url + " HEAD").read()
        if commit in new_commit:
            logging.info(tname + " has no new commit, Skip")
            logging.info("Succeeded: " + tname)
            exit()
    """

    # Fetch benchmark target and return commands
    benchmarks = run_sql(f'SELECT name from benchmark_names WHERE benchmark_type_id={benchmark_type_id};').splitlines()
    ci_date = datetime.today().strftime('%Y%m%d')
    ci_cmds = []
    for benchmark_name in benchmarks:
        ci_cmd = f'cd $SCRIPT_HOME && ./scripts/run_by_cron.sh {tname} {benchmark_name} {tid} {ci_date} > /dev/null'
        ci_cmds.append((ci_cmd, tname, benchmark_name))

    img_build_cmd = f'cd $SCRIPT_HOME && ./scripts/build_docker_image.sh {tname} {repo_url} {branch_name} > /dev/null'
    img_remove_cmd = f'docker rmi {tname}:16.04 && rm {tname}.commit > /dev/null'

    return ci_cmds, img_build_cmd, img_remove_cmd


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
    os.environ["PGPASSWORD"] = os.environ["CI_DB_PASSWORD"]
    os.environ["SCRIPT_HOME"] = "/home/deploy/ci_scripts/"
    os.environ["BENCHMARK_HOME"] = "/home/deploy/benchmarks/"
    targets = get_targets().splitlines()

    # Collect commands of checking benchmarks
    ci_cmds = []  # a command is a tuple of (cmd, tool_name, benchmark_name)
    img_build_cmds = []  # commands for building docker images of tools
    img_remove_cmds = []  # command for removing docker images of tools
    for target in targets:
        cmds1, img_cmd1, img_cmd2 = process_target(target)
        if len(cmds1) != 0:
            ci_cmds.extend(cmds1)
            img_build_cmds.append(img_cmd1)
            img_remove_cmds.append(img_cmd2)
    # Execute commands by forking child processes
    logging.info("Build tool images...")
    # run_cmds_in_serial(img_build_cmds)  # build images of each tool
    run_cmds_in_parallel([(a, a, '') for a in img_build_cmds])  # build images of each tool
    os.system("git clone https://github.com/plfm-iis/trauc_benchmarks.git $BENCHMARK_HOME")  # install benchmarks
    os.system("cp scripts/ci_run.sh $BENCHMARK_HOME")
    logging.info("Run checking benchmarks...")
    run_cmds_in_parallel(ci_cmds)  # run ci script for all tool-benchmark pairs
    logging.info("Cleaning tool images and benchmarks...")
    run_cmds_in_serial(img_remove_cmds)  # remove images of each tool
    os.system("rm -rf $BENCHMARK_HOME")  # remove benchmarks


if __name__ == '__main__':
    logging.basicConfig(filename='/home/deploy/ci_logs/str_ci.log',
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
