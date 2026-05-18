{% macro resource_monitor_coverage_gap(min_monthly_credits=100) -%}

WITH warehouse_spend AS (
    SELECT
        warehouse_name,
        SUM(credits_used) AS monthly_credits
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE start_time >= DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY warehouse_name
),
monitored_warehouses AS (
    SELECT DISTINCT
        TRIM(w.value::string) AS warehouse_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS rm,
         LATERAL FLATTEN(input => SPLIT(rm.warehouses, ',')) w
    WHERE rm.deleted IS NULL
      AND rm.warehouses IS NOT NULL
      AND rm.warehouses != ''
)
SELECT
    ws.warehouse_name,
    ROUND(ws.monthly_credits, 2) AS monthly_credits_mtd
FROM warehouse_spend ws
LEFT JOIN monitored_warehouses mw ON ws.warehouse_name = mw.warehouse_name
WHERE mw.warehouse_name IS NULL
  AND ws.monthly_credits > {{ min_monthly_credits }}
ORDER BY ws.monthly_credits DESC

{%- endmacro %}
