{% macro login_from_blocked_ip_address (time_filter=1440) -%}
select 
    event_timestamp, 
    user_name, client_ip, 
    reported_client_type,
    reported_client_version,
    first_authentication_factor,
    second_authentication_factor
from 
    snowflake.account_usage.login_history 
where error_message = 'INCOMING_IP_BLOCKED'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_time)
order by event_timestamp desc
{%- endmacro %}

{% macro login_failures (time_filter=1440) -%}
select distinct 
    client_ip, 
    count(client_ip) as count_of_failured_logins
from snowflake.account_usage.login_history
where is_success='NO'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_time)
group by client_ip
{%- endmacro %}

{% macro most_blocked_ip_addresses (time_filter=1440) -%}
select distinct 
    client_ip as blocked_source_ip,
    count (client_ip), 
    user_name,
    reported_client_type as driver,
    first_authentication_factor as authn_type
from 
    snowflake.account_usage.login_history
where error_message = 'INCOMING_IP_BLOCKED'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_time)
group by 
    user_name, 
    client_ip, 
    reported_client_type, 
    first_authentication_factor
order by 
    count (client_ip) desc
{%- endmacro %}

