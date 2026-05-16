{% macro accountadmin_role_grants(time_filter=1440) -%}
select
    user_name,
    role_name,
    query_text,
    end_time
from 
    snowflake.account_usage.query_history
where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
    and query_text ilike '%grant%accountadmin%to%'
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}
