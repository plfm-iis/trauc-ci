#!/usr/bin/python3

import os
import sys
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

    
    if days_to_run == 0:
        days_to_run = cycle
    else:
        return

    if "z3" in tname:
        cmd1 = "cd ../scripts/ && run_by_cron.sh " + \
                tname + " " + z3_ubuntu + "Kaluza_unsat"
        cmd2 = "cd ../scripts/ && run_by_cron.sh " + \
                tname + " " + z3_ubuntu + "PyEx_unsat"
    elif "cvc" in tname:
        cmd1 = "cd ../scripts/ && run_by_cron.sh " + \
                tname + " " + cvc4_ubuntu + "Kaluza_unsat"
        cmd2 = "cd ../scripts/ && run_by_cron.sh " + \
                tname + " " + cvc4_ubuntu + "PyEx_unsat"
    else:
        cmd1 = "cd ../scripts/ && run_z3_branch_by_cron.sh " + \
                tname + "Kaluza_unsat"
        cmd2 = "cd ../scripts/ && run_z3_branch_by_cron.sh " + \
                tname + "PyEx_unsat"

    process = subprocess.Popen(cmd1, shell=True)
    process = subprocess.Popen(cmd2, shell=True)

def main():
    os.environ["PGPASSWORD"] = os.environ["CI_DB_PASSWORD"]
    targets = get_targets().splitlines()

    for target in targets:
        run_target(target)


if __name__ == '__main__':
    main()
