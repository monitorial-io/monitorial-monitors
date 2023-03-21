select 
    query_id,
    query_text,
    database_name,
    schema_name,
    execution_status,
    error_code,
    user_name, 
    warehouse_name,
    start_time, 
    datediff(minutes, start_time, current_timestamp) as total_lapsed_time
from table(snowflake.information_schema.query_history(end_time_range_start=>dateadd(minute, -5, current_timestamp())))
where
    (execution_status <> 'SUCCESS' and execution_status not like 'FAILED%')
    and start_time < dateadd(minute, -5, current_timestamp());