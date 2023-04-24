{% macro altered_client_sessions (time_filter=1440) -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history
where
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_SESSION' and query_text ilike '%client_session%'
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_time)
order by end_time desc
{%- endmacro %}
