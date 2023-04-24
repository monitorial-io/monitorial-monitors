SELECT
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
FROM snowflake.account_usage.query_history
WHERE
    execution_status = 'SUCCESS'
    AND query_type = 'ALTER_SESSION'
    AND query_text ilike '%client_session%'
ORDER BY end_time DESC;