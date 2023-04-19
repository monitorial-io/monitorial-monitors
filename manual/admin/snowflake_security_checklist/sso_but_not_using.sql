WITH sso AS (
    SELECT
        user_name AS user_has_used_sso,
        min(event_timestamp) AS firstsso
    FROM snowflake.account_usage.login_history
    WHERE
        first_authentication_factor IN (
            'SAML2_ASSERTION',
            'OAUTH_ACCESS_TOKEN'
        )
    GROUP BY user_name
),

login_history AS (

    SELECT
        event_timestamp,
        user_name,
        first_authentication_factor,
        second_authentication_factor,
        client_ip,
        reported_client_type AS reported_client_version
    FROM snowflake.account_usage.login_history
    WHERE
        first_authentication_factor NOT IN (
            'SAML2_ASSERTION',
            'OAUTH_ACCESS_TOKEN'
        )
)

SELECT
    sso.user_has_used_sso,
    sso.firstsso,
    login_history.event_timestamp,
    login_history.user_name,
    login_history.first_authentication_factor,
    login_history.second_authentication_factor,
    login_history.client_ip,
    login_history.reported_client_type AS reported_client_version
FROM login_history
INNER JOIN sso
    ON sso.user_has_used_sso = login_history.user_name
WHERE login_history.event_timestamp > sso.firstsso
ORDER BY login_history.event_timestamp DESC;
