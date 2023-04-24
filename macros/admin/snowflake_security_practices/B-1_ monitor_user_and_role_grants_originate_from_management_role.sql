{% macro grant_changes (time_filter=1440) -%}
select
    user_name,
    role_name,
    query_text,
    end_time
from snowflake.account_usage.query_history
where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_time)
order by end_time desc
{%- endmacro %}
