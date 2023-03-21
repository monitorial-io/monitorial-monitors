select 
    event_timestamp,
    event_type,
    client_ip,
    user_name,
    error_message,
    error_code,
    reported_client_type,
    first_authentication_factor,
    second_authentication_factor
from snowflake.account_usage.login_history 
where 
    (is_success = 'NO' or error_message = 'INCOMING_IP_BLOCKED') and 
    event_timestamp > dateadd(day, -1, current_timestamp)  -- beginning of this month
order by event_timestamp desc;