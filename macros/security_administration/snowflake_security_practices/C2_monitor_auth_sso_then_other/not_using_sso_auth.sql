{% macro not_using_sso_auth(time_filter=1440) -%}
with sso_first_login as (
    select
        user_name,
        min(event_timestamp) as first_sso_auth_at
    from 
        snowflake.account_usage.login_history
    where
        first_authentication_factor in ('SAML2_ASSERTION', 'OAUTH_ACCESS_TOKEN')
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
        first_authentication_factor not in ('SAML2_ASSERTION', 'OAUTH_ACCESS_TOKEN')
        and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
 ) 
select
    sso_first_login.user_name,
    sso_first_login.first_sso_auth_at,
    logins_last_time_period.first_authentication_factor,
    logins_last_time_period.event_timestamp as non_sso_auth_at
from 
    sso_first_login inner join 
    logins_last_time_period 
    on 
        sso_first_login.user_name = logins_last_time_period.user_name
order by 
    logins_last_time_period.event_timestamp desc
{%- endmacro %}
