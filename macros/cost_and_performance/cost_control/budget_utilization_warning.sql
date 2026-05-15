{% macro budget_utilization_warning(budget_limit_credits=500, warning_pct=75) -%}

WITH current_month_spend AS (
    SELECT SUM(CREDITS_USED) AS month_to_date_credits
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE START_TIME >= DATE_TRUNC('month', CURRENT_TIMESTAMP())
),
daily_avg AS (
    SELECT AVG(daily_credits) AS avg_daily_spend
    FROM (
        SELECT DATE(START_TIME) AS d, SUM(CREDITS_USED) AS daily_credits
        FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
        WHERE START_TIME >= DATEADD('day', -30, CURRENT_DATE)
        GROUP BY d
    )
)
SELECT
    {{ budget_limit_credits }} AS budget_limit_credits,
    ROUND(s.month_to_date_credits, 2) AS current_spend_credits,
    ROUND((s.month_to_date_credits / {{ budget_limit_credits }}) * 100, 2) AS utilization_percent,
    ROUND({{ budget_limit_credits }} - s.month_to_date_credits, 2) AS remaining_credits,
    ROUND(d.avg_daily_spend, 2) AS avg_daily_spend,
    ROUND(({{ budget_limit_credits }} - s.month_to_date_credits) / NULLIF(d.avg_daily_spend, 0), 1) AS days_until_exhausted
FROM current_month_spend s
CROSS JOIN daily_avg d
WHERE (s.month_to_date_credits / {{ budget_limit_credits }}) * 100 > {{ warning_pct }}

{%- endmacro %}
