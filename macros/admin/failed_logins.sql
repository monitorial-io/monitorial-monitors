{% macro failed_logins(hours) -%}

SELECT
    event_timestamp,
    event_type,
    client_ip,
    user_name,
    error_message,
    error_code,
    reported_client_type,
    first_authentication_factor,
    second_authentication_factor
FROM snowflake.account_usage.login_history
WHERE
    (is_success = 'NO' OR error_message = 'INCOMING_IP_BLOCKED') AND
    event_timestamp > DATEADD(HOUR, -{{ hours }}, CURRENT_TIMESTAMP)
ORDER BY event_timestamp DESC

{%- endmacro %}