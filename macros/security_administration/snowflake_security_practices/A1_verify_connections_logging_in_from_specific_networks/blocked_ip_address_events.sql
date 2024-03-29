{% macro blocked_ip_address_events (time_filter=1440) -%}
select 
    event_timestamp,
    user_name, client_ip,
    reported_client_type,
    reported_client_version,
    first_authentication_factor,
    second_authentication_factor
from
    snowflake.account_usage.login_history
where
    error_message = 'INCOMING_IP_BLOCKED'
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by event_timestamp desc
{%- endmacro %}
