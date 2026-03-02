-- Table t1, partitioned by month on created_at

CREATE TABLE IF NOT EXISTS t1 (
    id              BIGINT          GENERATED ALWAYS AS IDENTITY,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    amount          NUMERIC(18, 2)  NOT NULL,
    status          SMALLINT        NOT NULL DEFAULT 0,
    operation_guid  UUID            NOT NULL DEFAULT gen_random_uuid(),
    message         JSONB           NOT NULL,

    CONSTRAINT t1_pkey PRIMARY KEY (operation_guid, created_at)
) PARTITION BY RANGE (created_at);

ALTER TABLE t1 ADD CONSTRAINT t1_message_check CHECK (
    message ? 'account_number'
    AND message ? 'client_id'
    AND message ? 'operation_type'
    AND message->>'operation_type' IN ('online', 'offline')
);

CREATE TABLE IF NOT EXISTS t1_2025_11 PARTITION OF t1
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE IF NOT EXISTS t1_2025_12 PARTITION OF t1
    FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

CREATE TABLE IF NOT EXISTS t1_2026_01 PARTITION OF t1
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE IF NOT EXISTS t1_2026_02 PARTITION OF t1
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE TABLE IF NOT EXISTS t1_default PARTITION OF t1 DEFAULT;

-- partial index for unprocessed rows
CREATE INDEX IF NOT EXISTS idx_t1_status ON t1 (status) WHERE status = 0;

-- for the materialized view aggregation
CREATE INDEX IF NOT EXISTS idx_t1_client_type ON t1 (
    (message->>'client_id'),
    (message->>'operation_type')
);

CREATE INDEX IF NOT EXISTS idx_t1_id ON t1 (id);
