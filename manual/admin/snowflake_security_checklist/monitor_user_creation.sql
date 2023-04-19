SELECT
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
FROM snowflake.account_usage.query_history
WHERE
    execution_status = 'SUCCESS'
    AND query_type = 'CREATE_USER' 
    AND query_text ilike '%create%user%'
ORDER BY end_time DESC;