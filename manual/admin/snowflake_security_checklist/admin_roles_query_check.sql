select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from snowflake.account_usage.query_history where
    execution_status = 'SUCCESS'
    and role_name in ('ACCOUNTADMIN', 'SECURITYADMIN', 'USERADMIN', 'SYSADMIN')
    and query_type in ('SELECT')
    and end_time >= dateadd(hour, -24, current_time)
order by end_time desc;