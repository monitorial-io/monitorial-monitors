{% macro most_blocked_ip_addresses (time_filter=1440) -%}
select distinct 
    client_ip as blocked_source_ip,
    count (client_ip), 
    user_name,
    reported_client_type as driver,
    first_authentication_factor as auth_type
from 
    snowflake.account_usage.login_history
where error_message = 'INCOMING_IP_BLOCKED'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by 
    user_name, 
    client_ip, 
    reported_client_type, 
    first_authentication_factor
order by 
    count (client_ip) desc
{%- endmacro %}

