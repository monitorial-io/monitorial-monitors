{% macro micro_transactions(query_types=["INSERT","UPDATE","DELETE","MERGE"], min_count=50, time_filter=1440) -%}

SELECT
    warehouse_name,
    user_name,
    query_type,
    COUNT(*) AS query_count,
    ROUND(AVG(total_elapsed_time), 0) AS avg_elapsed_ms,
    SUM(rows_produced) AS total_rows,
    ROUND(SUM(credits_used_cloud_services), 4) AS cloud_services_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND warehouse_size IS NOT NULL
  AND query_type IN (
    {%- for query_type in query_types -%}
    '{{ query_type }}'
    {% if not loop.last %},{% endif %}
    {% endfor %}
  )
  AND total_elapsed_time < 500
  AND rows_produced <= 10
GROUP BY warehouse_name, user_name, query_type
HAVING query_count > {{ min_count }}
ORDER BY query_count DESC

{%- endmacro %}
