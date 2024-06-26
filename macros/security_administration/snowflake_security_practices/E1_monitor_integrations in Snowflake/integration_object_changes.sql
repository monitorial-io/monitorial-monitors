{% macro integration_object_changes(time_filter=1440) -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from 
    snowflake.account_usage.query_history 
where
    execution_status = 'SUCCESS'
    and query_type in ('CREATE', 'ALTER', 'DROP')
    and regexp_like(query_text, '^[[:space:]]*(create([[:space:]]*or[[:space:]]*replace)?|alter|drop)[[:space:]]*(api|storage|notification|catalog|external)[[:space:]]+(.*)', 'i')
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}