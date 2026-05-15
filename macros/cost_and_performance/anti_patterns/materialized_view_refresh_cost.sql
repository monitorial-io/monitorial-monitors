{% macro materialized_view_refresh_cost(credit_threshold=1, time_filter=43200) -%}

SELECT
    database_name,
    schema_name,
    table_name AS materialized_view_name,
    COUNT(*) AS refresh_count,
    ROUND(SUM(credits_used), 4) AS total_credits,
    ROUND(AVG(credits_used), 6) AS avg_credits_per_refresh,
    ROUND(SUM(credits_used) / 30.0, 4) AS avg_daily_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
GROUP BY database_name, schema_name, table_name
HAVING total_credits > {{ credit_threshold }}
ORDER BY total_credits DESC

{%- endmacro %}
