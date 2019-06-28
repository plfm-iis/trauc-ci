#!/usr/bin/python3
import sys
import os

def run_sql(sql):
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

def insert_sql(sql):
    return os.popen("psql \
            -X \
            -U pguser \
            -h trauc-db -p 5432 \
            -d ci \
            -c" + "\"" + sql + "\"").read()

def main():
    os.environ["PGPASSWORD"] = os.environ["CI_DB_PASSWORD"]
    type_name = os.environ["CI_BENCHMARK_TYPE"]
    type_id = run_sql("SELECT id FROM benchmark_types WHERE name=\'%s\';" % type_name).splitlines()[0]
    tool_ids = run_sql("SELECT id FROM tools;").splitlines()

    datetime = run_sql("SELECT now()").replace("\n", "")
    sql = "INSERT INTO days_to_runs"
    sql = sql + "(tool_id, "
    sql = sql + "benchmark_type_id, "
    sql = sql + "days, "
    sql = sql + "created_at, "
    sql = sql + "updated_at) "
    sql = sql + "VALUES (%s," 
    sql = sql + type_id + ","
    sql = sql + "%s,\'"
    sql = sql + datetime + "\',\'"
    sql = sql + datetime + "\');"

    cnt = 1
    for tool_id in tool_ids:
        print("Insert tool_id %s" % tool_id)
        insert_sql(sql % (tool_id, cnt))
        cnt += 1


if __name__ == "__main__":
    main()
