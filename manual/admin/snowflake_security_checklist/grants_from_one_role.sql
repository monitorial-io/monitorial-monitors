select
    user_name,
    role_name,
    query_text
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
order by end_time desc