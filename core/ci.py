#!/usr/bin/python3

import os
import sys
import logging
_base_dir = os.path.dirname(os.path.realpath(__file__))

def run_sql(sql):
    logging.info(sql)
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

def update_sql(sql):
    logging.info(sql)
    return os.popen("psql \
            -U pguser \
            -d ci \
            -c" + "\"" + sql + "\"").read()

def get_targets():
    return run_sql("SELECT id FROM tools")

def run_target(tid):
    [tname, cycle, command, repo_url, branch_name, days_to_run] = \
            run_sql("SELECT name, test_cycle, command, repo_url, branch_name, days_to_run FROM tools WHERE id=" + tid).split(",")

    if len(days_to_run) == 0:
        logging.info(update_sql("UPDATE tools SET days_to_run = 0 WHERE id=" + tid))
    else:
        days_to_run = int(days_to_run) - 1

    cycle = int(cycle)
    
    # Check the execution cycle
    if days_to_run == 0:
        days_to_run = cycle
        logging.info("Running ci for" + tname)
        update_sql("UPDATE tools SET days_to_run = " + str(cycle) +" WHERE id=" + tid)
    else:
        logging.info(str(days_to_run) + "/" + str(cycle) + " days for " + tname)
        update_sql("UPDATE tools SET days_to_run = " + str(cycle) +" WHERE id=" + tid)
        return

    # set commands
    if "z3" in tname:
        cmd1 = "cd $SCRIPT_HOME && ./scripts/run_by_cron.sh " + \
                tname + " z3_ubuntu Kaluza_unsat " + tid + " -" + " > /dev/null 2&>1"
        cmd2 = "cd $SCRIPT_HOME && ./scripts/run_by_cron.sh " + \
                tname + " z3_ubuntu PyEx_unsat " + tid + " -" + " > /dev/null 2&>1"
    elif "cvc" in tname:
        cmd1 = "cd $SCRIPT_HOME && ./scripts/run_by_cron.sh " + \
                tname + " cvc4_ubuntu Kaluza_unsat " + tid + " -" + " > /dev/null 2&>1"
        cmd2 = "cd $SCRIPT_HOME && ./scripts/run_by_cron.sh " + \
                tname + " cvc4_ubuntu PyEx_unsat " + tid + " -" + " > /dev/null 2&>1"
    else:
        cmd1 = "cd $SCRIPT_HOME && ./scripts/run_z3_branch_by_cron.sh " + \
                tname + " Kaluza_unsat " + tid + " > /dev/null 2&>1"
        cmd2 = "cd $SCRIPT_HOME && ./scripts/run_z3_branch_by_cron.sh " + \
                tname + " PyEx_unsat " + tid + " > /dev/null 2&>1"

    # Execute
    os.popen(cmd1).read()
    os.popen(cmd2).read()


def main():
    os.environ["PGPASSWORD"] = os.environ["CI_DB_PASSWORD"]
    os.environ["SCRIPT_HOME"] = "/home/deploy/ci_scripts/"
    targets = get_targets().splitlines()

    children = []
    for target in targets:
        child = os.fork()
        if child:
            children.append(child)
        else:
            run_target(target)

    for child in children:
        os.waitpid(child, 0)


if __name__ == '__main__':
    logging.basicConfig(filename='/home/deploy/str_ci.log',\
            level=logging.INFO,\
            format='%(asctime)s %(message)s')

    main()
    logging.info("=== All for today !!===")
