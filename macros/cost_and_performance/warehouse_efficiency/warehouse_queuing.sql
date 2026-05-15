{% macro warehouse_queuing(avg_queue_threshold=0.1, time_filter=10080) -%}

WITH load_stats AS (
    SELECT
        WAREHOUSE_NAME,
        AVG(AVG_RUNNING) AS avg_running_threads,
        AVG(AVG_QUEUED_LOAD) AS avg_queued_load,
        MAX(AVG_QUEUED_LOAD) AS max_queued_load
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY
    WHERE START_TIME >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    GROUP BY WAREHOUSE_NAME
)
SELECT
    WAREHOUSE_NAME,
    ROUND(avg_running_threads, 2) AS avg_running_threads,
    ROUND(avg_queued_load, 4) AS avg_queued_load,
    ROUND(max_queued_load, 4) AS max_queued_load
FROM load_stats
WHERE avg_queued_load > {{ avg_queue_threshold }}
ORDER BY avg_queued_load DESC

{%- endmacro %}
