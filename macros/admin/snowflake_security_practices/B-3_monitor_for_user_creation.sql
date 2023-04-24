{% macro user_creation() -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'CREATE_USER' and query_text ilike '%create%user%'
order by end_time desc
{%- endmacro %}

{% macro user_creation_non_admin(executing_role_names = ["USERADMIN"]) -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'CREATE_USER' and query_text ilike '%create%user%'
    and role_name not in (
    {% for executing_role_name in executing_role_names %}
        '{{executing_role_name}}'
        {% if not loop.last %},{% endif %}
    {% endfor %}
    )
order by end_time desc
{%- endmacro %}
