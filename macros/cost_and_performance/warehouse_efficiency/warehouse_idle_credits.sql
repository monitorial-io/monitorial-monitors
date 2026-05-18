{% macro warehouse_idle_credits(idle_percent_threshold=30, time_filter=10080) -%}

SELECT
    warehouse_name,
    ROUND(SUM(credits_used_compute), 2) AS total_compute_credits,
    ROUND(SUM(credits_attributed_compute_queries), 2) AS query_credits,
    ROUND(SUM(credits_used_compute) - SUM(credits_attributed_compute_queries), 2) AS idle_credits,
    ROUND((SUM(credits_used_compute) - SUM(credits_attributed_compute_queries)) /
          NULLIF(SUM(credits_used_compute), 0) * 100, 2) AS idle_percent
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND credits_attributed_compute_queries IS NOT NULL
GROUP BY warehouse_name
HAVING idle_percent > {{ idle_percent_threshold }}
   AND SUM(credits_used_compute) - SUM(credits_attributed_compute_queries) > 0
ORDER BY idle_credits DESC

{%- endmacro %}
