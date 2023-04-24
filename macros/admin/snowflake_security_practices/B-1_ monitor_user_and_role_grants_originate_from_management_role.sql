{% macro grant_changes) -%}
select
    user_name,
    role_name,
    query_text,
    end_time
FROM snowflake.account_usage.query_history
WHERE
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
order by end_time desc
{%- endmacro %}
