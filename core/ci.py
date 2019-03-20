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
    [tname, cycle, command, repo_url, branch_name, build_everytime] = \
            run_sql("SELECT \
            name, \
            test_cycle, \
            command, \
            repo_url, \
            branch_name, \
            build_everytime \
            FROM tools WHERE id=" + tid).split(",")

    print(tname)


def main():
    os.environ["PGPASSWORD"] = os.environ["CI_DB_PASSWORD"]
    targets = get_targets().splitlines()

    for target in targets:
        run_target(target)


if __name__ == '__main__':
    main()
