select * from snowflake.account_usage.users
where
    has_rsa_public_key = 'true'
    and has_password = 'true';