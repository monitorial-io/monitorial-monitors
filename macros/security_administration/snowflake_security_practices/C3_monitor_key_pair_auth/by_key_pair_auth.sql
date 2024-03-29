{% macro by_key_pair_auth(time_filter=1440) -%}
select
    event_timestamp,
    user_name,
    client_ip,
    reported_client_type as reported_client_version,
    first_authentication_factor,
    second_authentication_factor
from 
    snowflake.account_usage.login_history
where 
    first_authentication_factor = 'RSA_KEYPAIR'
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by 
    event_timestamp desc
{%- endmacro %}

