{% macro user_altered() -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_USER'
order by end_time desc
{%- endmacro %}

{% macro user_altered_key_pair() -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_USER'
    and query_text ilike '%alter user%set rsa_public_key%'
order by end_time desc
{%- endmacro %}

{% macro user_altered_mfa_bypass() -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_USER'
    and query_text ilike '%alter user%set mins_to_bypass_mfa%'
order by end_time desc
{%- endmacro %}