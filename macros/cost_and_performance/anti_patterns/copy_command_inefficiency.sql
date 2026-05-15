{% macro copy_command_inefficiency(min_execution_count=10, time_filter=43200) -%}

SELECT
    SUBSTR(query_text, 1, 120) AS query_pattern,
    COUNT(*) AS execution_count,
    SUM(rows_produced) AS total_rows_loaded,
    ROUND(AVG(compilation_time), 0) AS avg_compile_ms,
    ROUND(AVG(execution_time), 0) AS avg_execution_ms,
    ROUND(SUM(credits_used_cloud_services), 4) AS cloud_services_credits,
    CASE
        WHEN AVG(compilation_time) > 5000 THEN 'HIGH_FILE_LISTING_OVERHEAD'
        WHEN COUNT(*) > 100 AND SUM(rows_produced) < 1000 THEN 'REDUNDANT_PATTERN'
        ELSE 'INVESTIGATE'
    END AS issue_type
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND query_type = 'COPY'
  AND execution_time > 1000
  AND rows_produced < 100
GROUP BY SUBSTR(query_text, 1, 120)
HAVING execution_count > {{ min_execution_count }}
ORDER BY execution_count DESC
LIMIT 10

{%- endmacro %}
