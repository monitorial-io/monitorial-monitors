{% macro enabled_user_previously_disabled(time_filter=1440) -%}
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
    and query_type = 'ALTER_USER'
    and query_text ilike '%alter user%set disabled = false%'
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}
