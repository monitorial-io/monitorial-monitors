SELECT
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
FROM
    snowflake.account_usage.query_history
WHERE
    execution_status = 'SUCCESS'
    AND query_type IN (
        'CREATE_NETWORK_POLICY', 'ALTER_NETWORK_POLICY', 'DROP_NETWORK_POLICY'
    )
    OR (
        query_text ILIKE '% set network_policy%'
        OR query_text ILIKE '% unset network_policy%'
    )
ORDER BY end_time DESC
