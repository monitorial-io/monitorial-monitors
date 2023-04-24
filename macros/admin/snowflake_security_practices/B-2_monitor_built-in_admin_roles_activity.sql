{% macro admin_roles_query_checks(hours, query_types = ["SELECT"]) -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
FROM snowflake.account_usage.query_history
WHERE execution_status = 'SUCCESS'
    AND role_name IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'USERADMIN', 'SYSADMIN')
    AND query_type IN (
        {%- for query_type in query_types -%}
        '{{query_type}}'
        {% if not loop.last %},{% endif %}
        {% endfor %}
        )
    and end_time >= dateadd(hour, -{{ hours }}, current_time)
order by end_time desc
{%- endmacro %}