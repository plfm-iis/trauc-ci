#!/bin/bash

export PGPASSWORD=$CI_DB_PASSWORD
psql \
    -X \
    -t \
    -U pguser \
    --set ON_ERROR_STOP=on \
    --set AUTOCOMMIT=off \
    -d ci \
    --field-separator , \
    --quiet \
    --no-align \
    -c "$1"
