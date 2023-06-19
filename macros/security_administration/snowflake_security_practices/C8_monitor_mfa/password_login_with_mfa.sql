{% macro password_login_with_mfa(time_filter=1440) -%}
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
    first_authentication_factor = 'PASSWORD'
    and second_authentication_factor is null
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by event_timestamp desc
{%- endmacro %}