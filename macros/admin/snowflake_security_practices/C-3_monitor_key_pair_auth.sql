{% macro by_key_pair_auth(time_filter=1440) -%}
select
    event_timestamp,
    user_name,
    client_ip,
    reported_client_type
        as reported_client_version,
    first_authentication_factor,
    second_authentication_factor
from snowflake.account_usage.login_history
where first_authentication_factor = 'RSA_KEYPAIR'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)

order by event_timestamp desc
{%- endmacro %}

{% macro key_pair_and_password(time_filter=1440) -%}
select * 
from snowflake.account_usage.users
where
    has_rsa_public_key = 'true'
    and has_password = 'true'
    and created_on >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
{%- endmacro %}

