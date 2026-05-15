{% macro high_frequency_show_commands(min_execution_count=500, time_filter=43200) -%}

SELECT
    query_type,
    SUBSTR(query_text, 1, 80) AS command_preview,
    user_name,
    COUNT(*) AS execution_count,
    ROUND(SUM(credits_used_cloud_services), 4) AS cloud_services_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND query_type = 'SHOW'
GROUP BY query_type, SUBSTR(query_text, 1, 80), user_name
HAVING execution_count > {{ min_execution_count }}
ORDER BY execution_count DESC
LIMIT 20

{%- endmacro %}
