SELECT
    event_timestamp,
    user_name,
    client_ip,
    reported_client_type,
    reported_client_version,
    first_authentication_factor,
    second_authentication_factor
FROM
    snowflake.account_usage.login_history
WHERE error_message = 'INCOMING_IP_BLOCKED'
ORDER BY event_timestamp DESC;