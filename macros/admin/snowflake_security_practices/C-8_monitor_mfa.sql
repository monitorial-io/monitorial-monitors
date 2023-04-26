{% macro mfa_auth_stats(time_filter=1440) -%}
select
    first_authentication_factor,
    second_authentication_factor,
    count(*)
from snowflake.account_usage.login_history 
where is_success = 'YES'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by
    first_authentication_factor,
    second_authentication_factor
order by count(*) desc
{%- endmacro %}

{% macro password_login_when_mfa(time_filter=1440) -%}
select
    event_timestamp,
    user_name,
    client_ip,
    reported_client_type
        as reported_client_version,
    first_authentication_factor,
    second_authentication_factor
from snowflake.account_usage.login_history
where
    first_authentication_factor = 'PASSWORD'
    and second_authentication_factor is null
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by event_timestamp desc
{%- endmacro %}