{% macro altered_client_sessions) -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
FROM snowflake.account_usage.query_history
WHERE
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_SESSION' and query_text ilike '%client_session%'
order by end_time desc
{%- endmacro %}
