SELECT * 
FROM snowflake.account_usage.users
WHERE
    has_rsa_public_key = 'true'
    AND has_password = 'true'
