{% macro cloud_services_overhead(time_filter=43200) -%}

WITH pattern_summary AS (
    SELECT 'SHOW Commands' AS pattern, SUM(credits_used_cloud_services) AS credits
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
      AND query_type = 'SHOW'
    UNION ALL
    SELECT 'Short Queries (<100ms)', SUM(credits_used_cloud_services)
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
      AND total_elapsed_time < 100
    UNION ALL
    SELECT 'Metadata Scans', SUM(credits_used_cloud_services)
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
      AND (schema_name = 'INFORMATION_SCHEMA' OR query_text ILIKE '%INFORMATION_SCHEMA%')
    UNION ALL
    SELECT 'Single-Row Inserts', SUM(credits_used_cloud_services)
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
      AND query_type = 'INSERT' AND rows_produced = 1
)
SELECT
    pattern,
    ROUND(credits, 4) AS cloud_services_credits,
    ROUND(RATIO_TO_REPORT(credits) OVER () * 100, 1) AS pct_of_overhead
FROM pattern_summary
WHERE credits > 0
ORDER BY credits DESC

{%- endmacro %}
