-- inserts one new operation with status=0 (unprocessed)
CREATE OR REPLACE FUNCTION insert_new_operation()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO t1 (created_at, amount, status, operation_guid, message)
    VALUES (
        now(),
        round((random() * 9999 + 1)::numeric, 2),
        0,
        gen_random_uuid(),
        jsonb_build_object(
            'account_number', 'ACC-' || lpad((floor(random() * 1000000)::int)::text, 7, '0'),
            'client_id',      (floor(random() * 1000) + 1)::int,
            'operation_type', CASE WHEN random() < 0.5 THEN 'online' ELSE 'offline' END
        )
    );
END;
$$;


-- flips status 0 -> 1 for rows matching current-second parity:
--   even second => even ids, odd second => odd ids
-- also refreshes the mat view if anything changed
CREATE OR REPLACE FUNCTION update_status_to_processed()
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE
    v_sec    INT;
    v_parity INT;
    v_cnt    INT;
BEGIN
    v_sec    := EXTRACT(SECOND FROM now())::int;
    v_parity := v_sec % 2;

    UPDATE t1
       SET status = 1
     WHERE status = 0
       AND id % 2 = v_parity;

    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    IF v_cnt > 0 THEN
        REFRESH MATERIALIZED VIEW CONCURRENTLY mv_client_operation_sum;
    END IF;

    RETURN v_cnt;
END;
$$;
