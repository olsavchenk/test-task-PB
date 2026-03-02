#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    GRANT USAGE ON SCHEMA cron TO postgres;
EOSQL

for f in /docker-entrypoint-initdb.d/sql/0[1-5]*.sql; do
    echo "Running $f"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
done

echo "Running 06_replication_publisher.sql"
psql -v ON_ERROR_STOP=1 \
     -v repl_password="replicator_pass" \
     --username "$POSTGRES_USER" \
     --dbname "$POSTGRES_DB" \
     -f /docker-entrypoint-initdb.d/sql/06_replication_publisher.sql
