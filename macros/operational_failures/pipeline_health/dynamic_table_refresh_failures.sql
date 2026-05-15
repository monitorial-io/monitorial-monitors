{% macro dynamic_table_refresh_failures(time_filter=1440) -%}

SELECT
    database_name,
    schema_name,
    name AS dynamic_table_name,
    state,
    state_message,
    last_completed_refresh_time,
    DATEDIFF('minute', last_completed_refresh_time, CURRENT_TIMESTAMP()) AS minutes_since_last_refresh,
    target_lag,
    scheduling_state
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLES
WHERE deleted IS NULL
  AND (
      state IN ('FAILING', 'SUSPENDED')
      OR scheduling_state = 'UPSTREAM_FAILED'
      OR (
          last_completed_refresh_time IS NOT NULL
          AND DATEDIFF('minute', last_completed_refresh_time, CURRENT_TIMESTAMP()) > {{ time_filter }}
      )
  )
ORDER BY
    CASE state
        WHEN 'FAILING' THEN 1
        WHEN 'SUSPENDED' THEN 2
        ELSE 3
    END,
    minutes_since_last_refresh DESC

{%- endmacro %}
