{% macro accountadmin_role_grants() -%}
select
    user_name,
    role_name,
    query_text,
    end_time
FROM snowflake.account_usage.query_history
WHERE
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
    and query_text ilike '%grant%accountadmin%to%'
order by end_time desc
{%- endmacro %}
