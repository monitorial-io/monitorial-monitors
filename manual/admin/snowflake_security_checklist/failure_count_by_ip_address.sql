SELECT
    client_ip,
    count(client_ip) AS count_of_failured_logins
FROM snowflake.account_usage.login_history
WHERE is_success = 'NO'
GROUP BY client_ip
