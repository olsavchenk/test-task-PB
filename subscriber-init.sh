#!/bin/bash
set -e

CONN_STRING="host=pg_publisher port=5432 dbname=testdb user=replicator password=replicator_pass"

psql -v ON_ERROR_STOP=1 \
     -v conn_string="$CONN_STRING" \
     --username "$POSTGRES_USER" \
     --dbname "$POSTGRES_DB" \
     -f /sql/07_replication_subscriber.sql
