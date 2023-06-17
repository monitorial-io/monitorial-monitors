{% macro admin_roles_query_check(query_types = ["SELECT", "DELETE", "INSERT", "UPDATE"], admin_roles = ["ACCOUNTADMIN", "SECURITYADMIN", "USERADMIN", "SYSADMIN"], time_filter=1440) -%}
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
    and role_name in (
        {%- for admin_role in admin_roles -%}
        '{{admin_role}}'
        {% if not loop.last %},{% endif %}
        {% endfor %}
    )
    and query_type in (
        {%- for query_type in query_types -%}
        '{{query_type}}'
        {% if not loop.last %},{% endif %}
        {% endfor %}
        )
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}