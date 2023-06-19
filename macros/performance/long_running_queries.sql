{% macro long_running_queries(minutes=5) -%}

SELECT
    query_id,
    query_text,
    database_name,
    schema_name,
    execution_status,
    error_code,
    user_name,
    warehouse_name,
    start_time,
    DATEDIFF(MINUTES, start_time, CURRENT_TIMESTAMP) AS total_lapsed_time
FROM TABLE(snowflake.information_schema.query_history(end_time_range_start => DATEADD(MINUTE, -{{ minutes }}, CURRENT_TIMESTAMP())))
WHERE
    (
        execution_status != 'SUCCESS'
        AND execution_status NOT LIKE 'FAILED%'
    )
    AND start_time < DATEADD(MINUTE, -{{ minutes }}, CURRENT_TIMESTAMP())

{%- endmacro %}