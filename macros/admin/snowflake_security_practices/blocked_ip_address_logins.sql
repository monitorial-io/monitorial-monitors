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
