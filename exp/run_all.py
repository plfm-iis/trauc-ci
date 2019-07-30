#!/usr/bin/env python3

import sys
import os
from subprocess import Popen, PIPE, STDOUT

def main(targets, benchmarks):

    os.system("mkdir -p results")

    for target in targets:
        for benchmark in benchmarks:
        cmd = "./run_target.sh %s %s" % (target, benchmark)
        print(cmd)
        try:
            process = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
        except subprocess.CalledProcessError as e:
            print(e.output)
        
        process.communicate()


def parse_results(targets, benchmarks):
    logs = os.popen("ls results")
    from prettytable import PrettyTable
    for benchmark in benchmarks:
        print(benchmark)
        table = PrettyTable(["Solver", "unsat", "sat", 
                             "timeout", "unknown", "exception/error"])
        for target in targets:
            log = "results/%s-%s" % (target, benchmark)
            with open(log, 'r') as fp:
                results = fp.read().splitlines()[-1]
                x.add_row(results.split(", ")[1:6])
        print(x)

if __name__ == "__main__":
    targets = ["trauc", "cvc4", "z3seq", "z3str"]
    benchmarks = ["filtered_str_int", "full_str_int"]
    main(targets, benchmarks)
    parse_results(targets, benchmarks)
