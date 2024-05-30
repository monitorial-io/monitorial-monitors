{% macro unauthorized_privilege_grants (authorized_role_names = ["SECURITYADMIN"], time_filter=1440) -%}
select
    user_name,
    role_name,
    query_text,
    end_time
from snowflake.account_usage.query_history
where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
    and role_name not in  (
       'SNOWFLAKE',
        {%- for authorized_role_name in authorized_role_names -%}
        '{{ authorized_role_name }}'
        {% if not loop.last %},{% endif %}
        {% endfor %}
        )
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}
