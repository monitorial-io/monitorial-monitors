{% macro ingestion_method_cost_comparison(time_filter=43200) -%}

WITH snowpipe_cost AS (
    SELECT
        'SNOWPIPE' AS method,
        ROUND(SUM(credits_used), 4) AS total_credits,
        ROUND(SUM(bytes_inserted) / POW(1024, 4), 6) AS tb_loaded,
        SUM(files_inserted) AS files_processed
    FROM SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
),
copy_cost AS (
    SELECT
        'BULK_COPY' AS method,
        ROUND(SUM(q.credits_used_cloud_services), 4) AS total_credits,
        ROUND(SUM(c.file_size) / POW(1024, 4), 6) AS tb_loaded,
        COUNT(*) AS files_processed
    FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY c
    JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
        ON c.last_load_time BETWEEN q.start_time AND q.end_time
        AND q.query_type = 'COPY'
    WHERE c.last_load_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
      AND c.pipe_name IS NULL
      AND c.status = 'Loaded'
),
streaming_cost AS (
    SELECT
        'STREAMING' AS method,
        ROUND(SUM(credits_used), 4) AS total_credits,
        0 AS tb_loaded,
        0 AS files_processed
    FROM SNOWFLAKE.ACCOUNT_USAGE.SNOWPIPE_STREAMING_FILE_MIGRATION_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
)
SELECT
    method,
    total_credits,
    tb_loaded,
    files_processed,
    ROUND(total_credits / NULLIF(tb_loaded, 0), 2) AS credits_per_tb
FROM (
    SELECT * FROM snowpipe_cost
    UNION ALL SELECT * FROM copy_cost
    UNION ALL SELECT * FROM streaming_cost
)
WHERE total_credits > 0
ORDER BY total_credits DESC

{%- endmacro %}
