{% macro high_priviledge_account(minutes,number_requests) -%}
select
    user_name,
    role_name,
    query_text
FROM snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT' and (
        query_text ilike '%create user%'
        or query_text ilike '%create role%'
        or query_text ilike '%manage grants%'
        or query_text ilike '%create integration%'
        or query_text ilike '%create share%'
        or query_text ilike '%create account%'
        or query_text ilike '%monitor usage%'
        or query_text ilike '%ownership%'
    )
order by end_time desc
{%- endmacro %}
