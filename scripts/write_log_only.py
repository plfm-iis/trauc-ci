#!/usr/bin/python3
import sys
import os


# Usage ./write_log_only.py <Target id> <Target> <Benchmark> <commit>
def main(tool_id, target, benchmark, commit):
    # Parse log to ci_logs_full
    log_dir = os.environ["HOME"] + "/output/"
    log = log_dir + target + "." + benchmark + ".log"

    data = os.popen("cat " + log + " | tail -n 1").read().replace(" ", "")
    data = data.split("(")[1].split(")")[0]
    tool_check_date, sat, unsat, timeout, unknown, exception, misc = data.split(",")
    check_date = tool_check_date.replace(target, "").replace("-", "")

    full_log_dir = os.environ["HOME"] + "/ci_logs_full/"
    output = full_log_dir + benchmark + "." + check_date + "." + target + ".log"

    os.system("rm -f " + output) # remove existing log
    os.system("touch " + output)
    with open(log, "r") as source:
        lines = source.read().splitlines()
        for line in lines:
            if "LOG.ERR" in line:
                output = full_log_dir + benchmark + "." + check_date + "." + target + ".log.err"
                os.system("rm -f " + output) # remove existing log
                os.system("touch " + output)
            elif "LOG.END" in line:
                break
            else:
                os.system("echo \"" + line + "\" >> " + output)
    # ip_address = os.popen("hostname -i").read()
    # if "10.32.0.207" not in ip_address:
    #    os.system("scp -r " + full_log_dir + " deploy@10.32.0.207:/home/deploy/ci_logs_full/")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("./write_log_to_db.py <Target id> <Target> <Benchmark> <commit>")
        exit(1)

    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])

