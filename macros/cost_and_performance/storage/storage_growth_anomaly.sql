{% macro storage_growth_anomaly(growth_pct_threshold=20) -%}

WITH monthly_storage AS (
    SELECT
        DATE_TRUNC('month', usage_date) AS month,
        AVG(storage_bytes + stage_bytes + failsafe_bytes) / POW(1024, 4) AS avg_storage_tb
    FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
    WHERE usage_date >= DATEADD('month', -3, CURRENT_DATE)
    GROUP BY DATE_TRUNC('month', usage_date)
),
with_lag AS (
    SELECT
        month,
        avg_storage_tb,
        LAG(avg_storage_tb) OVER (ORDER BY month) AS prev_month_tb
    FROM monthly_storage
)
SELECT
    month,
    ROUND(avg_storage_tb, 4) AS current_storage_tb,
    ROUND(prev_month_tb, 4) AS previous_month_tb,
    ROUND((avg_storage_tb - prev_month_tb) / NULLIF(prev_month_tb, 0) * 100, 2) AS growth_pct
FROM with_lag
WHERE prev_month_tb IS NOT NULL
  AND (avg_storage_tb - prev_month_tb) / NULLIF(prev_month_tb, 0) * 100 > {{ growth_pct_threshold }}
ORDER BY month DESC

{%- endmacro %}
