{% macro has_key_pair_using_password(time_filter=1440) -%}
with key_pair_first_login as (
    select
        user_name,
        min(event_timestamp) as first_key_pair_auth_at
    from 
        snowflake.account_usage.login_history
    where
        first_authentication_factor = 'RSA_KEYPAIR'
    group by user_name
),
logins_last_time_period as (
    select
        user_name,
        first_authentication_factor,
        event_timestamp
    from 
        snowflake.account_usage.login_history
    where
        first_authentication_factor !=  'PASSWORD'
        and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
 ) 
select
    key_pair_first_login.user_name,
    key_pair_first_login.first_key_pair_auth_at,
    logins_last_time_period.first_authentication_factor,
    logins_last_time_period.event_timestamp as non_sso_auth_at
from 
    key_pair_first_login inner join 
    logins_last_time_period 
    on 
        key_pair_first_login.user_name = logins_last_time_period.username
order by 
    logins_last_time_period.event_timestamp desc
{%- endmacro %}
