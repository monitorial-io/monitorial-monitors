select
    user_name,
    role_name,
    query_text
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'GRANT'
    and query_text ilike '%grant%accountadmin%to%'
order by end_time desc;