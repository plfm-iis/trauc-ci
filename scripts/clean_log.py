#!/usr/bin/python3
import sys
import os

def main(path, num_to_keep, split_by):
    traces_dir = os.environ["HOME"] + "/" + path
    os.chdir(traces_dir)
    dirs = os.listdir(".")

    while len(dirs) > 0:
        target = dirs.pop()

        if "xslt" in target:
            continue

        process_list = []
        process_list.append(target)
        keyword = target.split(split_by)[2]

        more_indexes = []
        for name in dirs:
            if keyword in name:
                process_list.append(name)
                dirs.remove(name)

        process_list = sorted(process_list, key=str.lower)

        while len(process_list) > num_to_keep:
            name = process_list.pop(0)
            print("rm " + name)
            os.popen("rm -rf " + name).read()

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("./clean_log.py <PATH> <# to keep> <split_by>")
        exit(1)
    main(sys.argv[1], int(sys.argv[2]), sys.argv[3])
