{% macro user_altered(time_filter=1440) -%}
select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_USER'
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}

{% macro user_altered_key_pair(time_filter=1440) -%}
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
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}

{% macro user_altered_mfa_bypass(time_filter=1440) -%}
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
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}