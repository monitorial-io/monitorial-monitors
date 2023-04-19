SELECT
    user_name,
    role_name,
    query_text,
    end_time
FROM snowflake.account_usage.query_history
WHERE
    execution_status = 'SUCCESS'
    AND query_type = 'GRANT'
    AND query_text ILIKE '%grant%accountadmin%to%'
ORDER BY end_time DESC;