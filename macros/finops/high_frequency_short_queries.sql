{% macro high_frequency_short_queries(min_execution_count=1000, time_filter=43200) -%}

SELECT
    SUBSTR(REGEXP_REPLACE(query_text, '\\b\\d+\\b', '?'), 1, 80) AS query_template,
    user_name,
    COUNT(*) AS execution_count,
    ROUND(SUM(credits_used_cloud_services), 4) AS cloud_services_credits,
    ROUND(AVG(total_elapsed_time), 0) AS avg_elapsed_ms
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND total_elapsed_time < 100
  AND query_type = 'SELECT'
GROUP BY SUBSTR(REGEXP_REPLACE(query_text, '\\b\\d+\\b', '?'), 1, 80), user_name
HAVING execution_count > {{ min_execution_count }}
ORDER BY execution_count DESC
LIMIT 20

{%- endmacro %}
