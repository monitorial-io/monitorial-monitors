{% macro has_key_pair_and_password(time_filter=1440) -%}
select * 
from 
    snowflake.account_usage.users
where
    has_rsa_public_key = 'true'
    and has_password = 'true'
    and created_on >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
{%- endmacro %}

