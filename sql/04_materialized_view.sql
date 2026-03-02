CREATE MATERIALIZED VIEW mv_client_operation_sum AS
SELECT
    (message->>'client_id')::int       AS client_id,
    message->>'operation_type'         AS operation_type,
    SUM(amount)                        AS total_amount,
    COUNT(*)                           AS operation_count
FROM t1
WHERE status = 1
GROUP BY
    (message->>'client_id')::int,
    message->>'operation_type'
WITH DATA;

CREATE UNIQUE INDEX idx_mv_client_op_sum_uniq
    ON mv_client_operation_sum (client_id, operation_type);
