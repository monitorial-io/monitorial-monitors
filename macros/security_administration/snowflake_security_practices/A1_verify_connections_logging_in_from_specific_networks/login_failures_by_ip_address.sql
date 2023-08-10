{% macro login_failures_by_ip_address (time_filter=1440) -%}
select distinct 
    client_ip, 
    count(client_ip) as count_of_failured_logins
from 
    snowflake.account_usage.login_history
where 
    is_success='NO'
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by client_ip
{%- endmacro %}
