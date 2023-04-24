{% macro by_key_pair() -%}
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
order by event_timestamp desc
{%- endmacro %}

{% macro key_pair_and_password() -%}
select * 
from snowflake.account_usage.users
where
    has_rsa_public_key = 'true'
    and has_password = 'true'
{%- endmacro %}

