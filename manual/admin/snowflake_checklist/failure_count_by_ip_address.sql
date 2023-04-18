select distinct 
    client_ip, 
    count(client_ip) as count_of_failured_logins
from snowflake.account_usage.login_history
where is_success='NO'
group by client_ip;