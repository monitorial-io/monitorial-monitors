SELECT
    client_ip AS blocked_source_ip,
    COUNT(client_ip) AS count_of_client_ip,
    user_name,
    reported_client_type AS driver,
    first_authentication_factor AS authn_type
FROM
    snowflake.account_usage.login_history
WHERE error_message = 'INCOMING_IP_BLOCKED'
GROUP BY
    user_name,
    client_ip,
    reported_client_type,
    first_authentication_factor
ORDER BY
    COUNT(client_ip) DESC
