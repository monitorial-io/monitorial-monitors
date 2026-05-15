{% macro warehouse_spilling(remote_spill_threshold=0, local_spill_gb_threshold=1, time_filter=10080) -%}

SELECT
    WAREHOUSE_NAME,
    COUNT(CASE WHEN BYTES_SPILLED_TO_REMOTE_STORAGE > 0 THEN 1 END) AS remote_spill_count,
    COUNT(CASE WHEN BYTES_SPILLED_TO_LOCAL_STORAGE > 0 THEN 1 END) AS local_spill_count,
    ROUND(SUM(BYTES_SPILLED_TO_REMOTE_STORAGE) / POW(1024, 3), 2) AS total_remote_spill_gb,
    ROUND(SUM(BYTES_SPILLED_TO_LOCAL_STORAGE) / POW(1024, 3), 2) AS total_local_spill_gb,
    CASE
        WHEN COUNT(CASE WHEN BYTES_SPILLED_TO_REMOTE_STORAGE > 0 THEN 1 END) > {{ remote_spill_threshold }} THEN 'CRITICAL'
        WHEN SUM(BYTES_SPILLED_TO_LOCAL_STORAGE) / POW(1024, 3) > {{ local_spill_gb_threshold }} THEN 'HIGH'
        ELSE 'MODERATE'
    END AS severity
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND WAREHOUSE_NAME IS NOT NULL
GROUP BY WAREHOUSE_NAME
HAVING remote_spill_count > {{ remote_spill_threshold }}
    OR total_local_spill_gb > {{ local_spill_gb_threshold }}
ORDER BY total_remote_spill_gb DESC, total_local_spill_gb DESC

{%- endmacro %}
