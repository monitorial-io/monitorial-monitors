{% macro high_data_churn(churn_ratio_threshold=2.0) -%}

SELECT
    table_catalog AS database_name,
    table_schema AS schema_name,
    table_name,
    ROUND(active_bytes / POW(1024, 3), 2) AS active_gb,
    ROUND(time_travel_bytes / POW(1024, 3), 2) AS time_travel_gb,
    ROUND(failsafe_bytes / POW(1024, 3), 2) AS failsafe_gb,
    ROUND((time_travel_bytes + failsafe_bytes) / NULLIF(active_bytes, 0), 2) AS churn_ratio,
    CASE
        WHEN table_type = 'BASE TABLE' AND is_transient = 'NO' THEN 'PERMANENT'
        WHEN is_transient = 'YES' THEN 'TRANSIENT'
        ELSE table_type
    END AS table_classification
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS tsm
JOIN SNOWFLAKE.ACCOUNT_USAGE.TABLES t
    ON tsm.id = t.table_id
WHERE tsm.deleted = FALSE
  AND active_bytes > 0
  AND (time_travel_bytes + failsafe_bytes) / NULLIF(active_bytes, 0) > {{ churn_ratio_threshold }}
ORDER BY churn_ratio DESC
LIMIT 20

{%- endmacro %}
