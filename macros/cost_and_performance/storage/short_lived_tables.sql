{% macro short_lived_tables(lifespan_hours=24, time_filter=43200) -%}

SELECT
    table_catalog AS database_name,
    table_schema AS schema_name,
    table_name,
    table_owner AS owner,
    created AS created_at,
    deleted AS deleted_at,
    DATEDIFF('hour', created, deleted) AS lifespan_hours,
    CASE
        WHEN is_transient = 'YES' THEN 'TRANSIENT'
        ELSE 'PERMANENT'
    END AS table_type
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE deleted IS NOT NULL
  AND created >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND DATEDIFF('hour', created, deleted) <= {{ lifespan_hours }}
ORDER BY created DESC
LIMIT 50

{%- endmacro %}
