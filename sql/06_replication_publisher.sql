-- Logical replication setup (publisher side)

-- create replication user if it doesn't exist yet
-- password comes from psql variable set in publisher-init.sh
SELECT NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'replicator') AS should_create \gset
\if :should_create
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD :'repl_password';
\endif

GRANT USAGE  ON SCHEMA public TO replicator;
GRANT SELECT ON t1 TO replicator;

ALTER TABLE t1 REPLICA IDENTITY USING INDEX t1_pkey;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT c.relname AS part, i.relname AS idx
        FROM pg_inherits inh
        JOIN pg_class c      ON c.oid = inh.inhrelid
        JOIN pg_class parent ON parent.oid = inh.inhparent
        JOIN pg_index pidx   ON pidx.indrelid = c.oid AND pidx.indisprimary
        JOIN pg_class i      ON i.oid = pidx.indexrelid
        WHERE parent.relname = 't1'
    LOOP
        EXECUTE format('ALTER TABLE %I REPLICA IDENTITY USING INDEX %I',
                       r.part, r.idx);
    END LOOP;
END;
$$;

CREATE PUBLICATION t1_pub
    FOR TABLE t1
    WITH (publish_via_partition_root = true);
