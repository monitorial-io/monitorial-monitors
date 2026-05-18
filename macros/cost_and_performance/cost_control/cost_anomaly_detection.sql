{% macro cost_anomaly_detection(percent_change_threshold=50, time_filter=43200) -%}

WITH daily_credits AS (
    SELECT
        DATE(start_time) AS usage_date,
        SUM(credits_used) AS daily_credits
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    GROUP BY DATE(start_time)
),
stats AS (
    SELECT
        AVG(daily_credits) AS avg_daily,
        STDDEV(daily_credits) AS stddev_daily
    FROM daily_credits
    WHERE usage_date < CURRENT_DATE()
)
SELECT
    d.usage_date,
    ROUND(d.daily_credits, 2) AS daily_credits,
    ROUND(s.avg_daily, 2) AS avg_daily_credits,
    ROUND(d.daily_credits - s.avg_daily, 2) AS deviation,
    ROUND((d.daily_credits - s.avg_daily) / NULLIF(s.stddev_daily, 0), 2) AS z_score,
    ROUND((d.daily_credits - s.avg_daily) / NULLIF(s.avg_daily, 0) * 100, 2) AS percent_above_avg
FROM daily_credits d
CROSS JOIN stats s
WHERE (d.daily_credits - s.avg_daily) / NULLIF(s.avg_daily, 0) * 100 > {{ percent_change_threshold }}
ORDER BY d.usage_date DESC

{%- endmacro %}
