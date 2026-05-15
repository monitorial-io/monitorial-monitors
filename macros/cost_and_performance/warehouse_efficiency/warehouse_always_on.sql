{% macro warehouse_always_on(avg_hours_threshold=20, time_filter=10080) -%}

WITH daily_usage AS (
    SELECT
        warehouse_name,
        DATE(start_time) AS usage_date,
        COUNT(DISTINCT HOUR(start_time)) AS hours_running_per_day
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    GROUP BY warehouse_name, DATE(start_time)
)
SELECT
    warehouse_name,
    ROUND(AVG(hours_running_per_day), 1) AS avg_hours_per_day,
    MAX(hours_running_per_day) AS max_hours_per_day,
    COUNT(*) AS days_tracked
FROM daily_usage
GROUP BY warehouse_name
HAVING AVG(hours_running_per_day) >= {{ avg_hours_threshold }}
ORDER BY avg_hours_per_day DESC

{%- endmacro %}
