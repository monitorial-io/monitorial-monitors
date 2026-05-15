{% macro complex_query_compilation(compilation_time_ms=10000, time_filter=10080) -%}

SELECT
    query_id,
    query_type,
    user_name,
    warehouse_name,
    ROUND(compilation_time, 0) AS compilation_time_ms,
    ROUND(execution_time, 0) AS execution_time_ms,
    ROUND(compilation_time * 100.0 / NULLIF(total_elapsed_time, 0), 1) AS compile_pct_of_total,
    SUBSTR(query_text, 1, 120) AS query_preview
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND compilation_time > {{ compilation_time_ms }}
  AND execution_status = 'SUCCESS'
ORDER BY compilation_time DESC
LIMIT 20

{%- endmacro %}
