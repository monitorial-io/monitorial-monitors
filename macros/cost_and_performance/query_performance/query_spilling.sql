{% macro query_spilling(time_filter=10080) -%}

SELECT
    i.query_id,
    q.warehouse_name,
    q.user_name,
    i.insight_type_id AS insight_code,
    ROUND(q.bytes_spilled_to_local_storage / POW(1024, 3), 2) AS local_spill_gb,
    ROUND(q.bytes_spilled_to_remote_storage / POW(1024, 3), 2) AS remote_spill_gb,
    ROUND(q.total_elapsed_time / 1000.0, 2) AS elapsed_seconds,
    SUBSTR(q.query_text, 1, 120) AS query_preview
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_INSIGHTS i
JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
    ON i.query_id = q.query_id
WHERE i.start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND i.insight_type_id ILIKE '%SPILL%'
ORDER BY q.bytes_spilled_to_remote_storage DESC, q.bytes_spilled_to_local_storage DESC
LIMIT 20

{%- endmacro %}
