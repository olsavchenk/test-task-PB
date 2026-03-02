-- new operation every 5 sec
SELECT cron.schedule(
    'insert_operation_job',
    '5 seconds',
    $$SELECT insert_new_operation()$$
);

-- process pending rows every 3 sec
SELECT cron.schedule(
    'update_status_job',
    '3 seconds',
    $$SELECT update_status_to_processed()$$
);

-- clean up old cron logs once a day at 3am
SELECT cron.schedule(
    'cleanup_cron_history',
    '0 3 * * *',
    $$DELETE FROM cron.job_run_details WHERE end_time < now() - interval '7 days'$$
);
