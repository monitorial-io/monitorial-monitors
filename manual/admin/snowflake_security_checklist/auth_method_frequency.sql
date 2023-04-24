SELECT
    user_name,
    first_authentication_factor,
    second_authentication_factor,
    COUNT(*) AS login_count
FROM snowflake.account_usage.login_history
WHERE is_success = 'YES'
GROUP BY
    user_name, first_authentication_factor,
    second_authentication_factor
ORDER BY user_name, COUNT(*) DESC