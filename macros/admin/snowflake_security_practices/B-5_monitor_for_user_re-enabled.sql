{% macro enabled_user_previously_disabled() -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
FROM snowflake.account_usage.query_history 
WHERE
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_USER'
    and query_text ilike '%alter user%set disabled = false%'
order by end_time desc
{%- endmacro %}
