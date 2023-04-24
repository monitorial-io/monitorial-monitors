{% macro login_from_blocked_ip_address) -%}
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
order by event_timestamp desc
{%- endmacro %}

{% macro login_failures) -%}
select distinct 
    client_ip, 
    count(client_ip) as count_of_failured_logins
from snowflake.account_usage.login_history
where is_success='NO'
group by client_ip
{%- endmacro %}

{% macro most_blocked_ip_addresses) -%}
select distinct 
    client_ip as blocked_source_ip,
    count (client_ip), 
    user_name,
    reported_client_type as driver,
    first_authentication_factor as authn_type
from 
    snowflake.account_usage.login_history
where error_message = 'INCOMING_IP_BLOCKED'
group by 
    user_name, 
    client_ip, 
    reported_client_type, 
    first_authentication_factor
order by 
    count (client_ip) desc
{%- endmacro %}

