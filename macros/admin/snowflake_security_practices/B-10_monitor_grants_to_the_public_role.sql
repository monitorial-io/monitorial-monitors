{% macro public_role_grants() -%}
select
    user_name,
    role_name,
    query_text,
    end_time
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
    and query_text ilike '%to%public%'
order by end_time desc
{%- endmacro %}

