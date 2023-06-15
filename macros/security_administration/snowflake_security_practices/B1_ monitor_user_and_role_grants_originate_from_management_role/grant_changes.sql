{% macro grant_changes (role_name = "SECURITYADMIN", time_filter=1440) -%}
select
    user_name,
    role_name,
    query_text,
    end_time
from snowflake.account_usage.query_history
where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
    and role_name = '{{ role_name }}'
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}
