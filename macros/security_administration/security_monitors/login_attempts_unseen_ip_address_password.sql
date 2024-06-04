{% macro login_attempts_unseen_ip_address_password (time_filter=1440) -%}
with recent_logins as (
    select
        snowflake.account_usage.login_history.user_name, 
        snowflake.account_usage.login_history.client_ip, 
        snowflake.account_usage.login_history.event_timestamp
    from 
        snowflake.account_usage.login_history
    where 
        snowflake.account_usage.login_history.event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp) and
        snowflake.account_usage.login_history.first_authentication_factor = 'password'
),
previous_logins as (
    select distinct
        snowflake.account_usage.login_history.client_ip
    from 
        snowflake.account_usage.login_history
    where 
        snowflake.account_usage.login_history.event_timestamp < dateadd(minutes, -{{ time_filter }}, current_timestamp)
)
select distinct
    recent_logins.user_name, 
    recent_logins.client_ip, 
    recent_logins.event_timestamp
from 
    recent_logins
left join 
    previous_logins 
on 
    recent_logins.client_ip = previous_logins.client_ip
where 
    previous_logins.client_ip is null
order by 
    recent_logins.event_timestamp
{%- endmacro %}
