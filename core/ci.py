#!/usr/bin/python3

import os
import sys
import logging
_base_dir = os.path.dirname(os.path.realpath(__file__))

def run_sql(sql):
    return os.popen("psql \
            -X \
            -t \
            -U pguser \
            --set ON_ERROR_STOP=on \
            --set AUTOCOMMIT=off \
            -d ci \
            --field-separator , \
            --quiet \
            --no-align \
            -c" + "\"" + sql + "\"").read()

def get_targets():
    return run_sql("SELECT id FROM tools")

def run_target(tid):
    [tname, cycle, command, repo_url, branch_name, days_to_run] = \
            run_sql("SELECT \
            name, \
            test_cycle, \
            command, \
            repo_url, \
            branch_name, \
            days_to_run \
            FROM tools WHERE id=" + tid).split(",")

    days_to_run = int(days_to_run) - 1
    cycle = int(cycle)

    
    # Check the execution cycle
    if days_to_run == 0:
        days_to_run = cycle
        logging.info("Running ci for" + tname)
    else:
        logging.info(str(days_to_run) + "/" + str(cycle) + " days for " + tname)
        return

    # set commands
    if "z3" in tname:
        cmd1 = "cd $SCRIPT_HOME && scripts/run_by_cron.sh " + \
                tname + " " + z3_ubuntu + "Kaluza_unsat" + tid + " -"
        cmd2 = "cd $SCRIPT_HOME && scripts/run_by_cron.sh " + \
                tname + " " + z3_ubuntu + "PyEx_unsat" + tid + " -"
    elif "cvc" in tname:
        cmd1 = "cd $SCRIPT_HOME && scripts/run_by_cron.sh " + \
                tname + " " + cvc4_ubuntu + "Kaluza_unsat" + tid + " -"
        cmd2 = "cd $SCRIPT_HOME && scripts/run_by_cron.sh " + \
                tname + " " + cvc4_ubuntu + "PyEx_unsat" + tid + " -"
    else:
        cmd1 = "cd $SCRIPT_HOME && scripts/run_z3_branch_by_cron.sh " + \
                tname + "Kaluza_unsat" + tid
        cmd2 = "cd $SCRIPT_HOME && scripts/run_z3_branch_by_cron.sh " + \
                tname + "PyEx_unsat" + tid

    # Execute
    try:
        pid1 = os.fork()
    except:
        logging.warning("fork1 error for " + tname)
        return

    if pid1 == 0:
        # Child 1
        logging.info(cmd1)
        os.system(cmd1)
        exit()
    else:
        # Parent after child1 forks
        try:
            pid2 = os.fork()
            exit()
        except:
            logging.warning("fork2 error for " + tname)
            return

        if pid2 == 0:
            # Child 2
            logging.info(cmd2)
            os.system(cmd2)

    os.waitpid(0, 0)
    os.waitpid(0, 0)
    # After all child finish


def main():
    os.environ["PGPASSWORD"] = os.environ["CI_DB_PASSWORD"]
    os.environ["SCRIPT_HOME"] = "/home/deploy/ci_scripts/"
    os.environ["SCRIPT_HOME"] = "/home/deploy/output/"
    logging.basicConfig(filename='/home/deploy/ci.log',level=logging.INFO,format='%(asctime)s %(message)s')
    targets = get_targets().splitlines()

    for target in targets:
        run_target(target)


if __name__ == '__main__':
    main()
