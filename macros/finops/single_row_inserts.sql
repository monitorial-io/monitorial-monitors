{% macro single_row_inserts(min_insert_count=100, time_filter=43200) -%}

SELECT
    REGEXP_SUBSTR(query_text, 'INSERT INTO ([a-zA-Z0-9_.]+)', 1, 1, 'i', 1) AS target_table,
    user_name,
    COUNT(*) AS insert_count,
    SUM(rows_produced) AS total_rows_loaded,
    ROUND(SUM(credits_used_cloud_services), 4) AS cloud_services_credits,
    CASE
        WHEN COUNT(*) > 1000 THEN 'CRITICAL'
        WHEN COUNT(*) > 500 THEN 'HIGH'
        WHEN COUNT(*) > {{ min_insert_count }} THEN 'MODERATE'
    END AS severity
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND query_type = 'INSERT'
  AND rows_produced = 1
GROUP BY REGEXP_SUBSTR(query_text, 'INSERT INTO ([a-zA-Z0-9_.]+)', 1, 1, 'i', 1), user_name
HAVING insert_count > {{ min_insert_count }}
ORDER BY insert_count DESC

{%- endmacro %}
