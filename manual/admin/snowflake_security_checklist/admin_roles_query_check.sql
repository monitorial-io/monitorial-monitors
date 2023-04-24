SELECT
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
FROM snowflake.account_usage.query_history 
WHERE
    execution_status = 'SUCCESS'
    AND role_name IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'USERADMIN', 'SYSADMIN')
    AND query_type IN ('SELECT')
    AND end_time >= DATEADD(HOUR, -24, CURRENT_TIME)
ORDER BY end_time DESC;