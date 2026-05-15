{% macro warehouse_cost_spike(percent_change_threshold=50, min_credits=10) -%}

WITH weekly_data AS (
    SELECT
        warehouse_name,
        SUM(CASE WHEN start_time >= DATEADD('day', -7, CURRENT_DATE) THEN credits_used ELSE 0 END) AS current_credits,
        SUM(CASE WHEN start_time >= DATEADD('day', -14, CURRENT_DATE) AND start_time < DATEADD('day', -7, CURRENT_DATE)
                 THEN credits_used ELSE 0 END) AS previous_credits
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE start_time >= DATEADD('day', -14, CURRENT_DATE)
    GROUP BY warehouse_name
)
SELECT
    warehouse_name,
    ROUND(previous_credits, 2) AS previous_week_credits,
    ROUND(current_credits, 2) AS current_week_credits,
    ROUND(current_credits - previous_credits, 2) AS credit_change,
    ROUND((current_credits - previous_credits) / NULLIF(previous_credits, 0) * 100, 2) AS percent_change
FROM weekly_data
WHERE (current_credits > {{ min_credits }} OR previous_credits > {{ min_credits }})
  AND (current_credits - previous_credits) / NULLIF(previous_credits, 0) * 100 > {{ percent_change_threshold }}
ORDER BY credit_change DESC

{%- endmacro %}
