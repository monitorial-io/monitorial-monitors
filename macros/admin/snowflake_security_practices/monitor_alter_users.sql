select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and query_type = 'ALTER_USER'
    and query_text ilike '%alter user%set rsa_public_key%'
order by end_time desc;