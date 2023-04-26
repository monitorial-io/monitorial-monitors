{% macro admin_roles_query_checks(query_types = ["SELECT"], time_filter=1440) -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history
where execution_status = 'SUCCESS'
    and role_name IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'USERADMIN', 'SYSADMIN')
    and query_type IN (
        {%- for query_type in query_types -%}
        '{{query_type}}'
        {% if not loop.last %},{% endif %}
        {% endfor %}
        )
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}