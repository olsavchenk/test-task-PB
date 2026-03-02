CREATE OR REPLACE PROCEDURE generate_t1_data(p_row_count INT DEFAULT 100000)
LANGUAGE plpgsql
AS $$
DECLARE
    v_batch  INT := 10000;
    v_done   INT := 0;
    v_chunk  INT;
BEGIN
    WHILE v_done < p_row_count LOOP
        v_chunk := LEAST(v_batch, p_row_count - v_done);

        INSERT INTO t1 (created_at, amount, status, operation_guid, message)
        SELECT
            '2025-11-01'::timestamptz
                + (random() * (EXTRACT(EPOCH FROM '2026-03-01'::timestamptz - '2025-11-01'::timestamptz)))
                  * interval '1 second',
            round((random() * 9999 + 1)::numeric, 2),
            1,   -- mark as already processed
            gen_random_uuid(),
            jsonb_build_object(
                'account_number', 'ACC-' || lpad((floor(random() * 1000000)::int)::text, 7, '0'),
                'client_id',      (floor(random() * 1000) + 1)::int,
                'operation_type', CASE WHEN random() < 0.5 THEN 'online' ELSE 'offline' END
            )
        FROM generate_series(1, v_chunk);

        v_done := v_done + v_chunk;
        COMMIT;

        RAISE NOTICE 'Inserted % / % rows', v_done, p_row_count;
    END LOOP;
END;
$$;

CALL generate_t1_data(100000);
