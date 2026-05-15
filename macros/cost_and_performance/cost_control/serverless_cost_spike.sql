{% macro serverless_cost_spike(credit_threshold=10, time_filter=43200) -%}

SELECT
    service_type,
    ROUND(total_credits, 2) AS total_credits,
    databases_using,
    executions
FROM (
    SELECT 'AUTO_CLUSTERING' AS service_type,
           SUM(credits_used) AS total_credits,
           COUNT(DISTINCT database_name) AS databases_using,
           COUNT(*) AS executions
    FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    UNION ALL
    SELECT 'SERVERLESS_TASK',
           SUM(credits_used),
           COUNT(DISTINCT database_name),
           COUNT(*)
    FROM SNOWFLAKE.ACCOUNT_USAGE.SERVERLESS_TASK_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    UNION ALL
    SELECT 'MATERIALIZED_VIEWS',
           SUM(credits_used),
           COUNT(DISTINCT database_name),
           COUNT(*)
    FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    UNION ALL
    SELECT 'SEARCH_OPTIMIZATION',
           SUM(credits_used),
           COUNT(DISTINCT database_name),
           COUNT(*)
    FROM SNOWFLAKE.ACCOUNT_USAGE.SEARCH_OPTIMIZATION_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
) s
WHERE total_credits > {{ credit_threshold }}
ORDER BY total_credits DESC

{%- endmacro %}
