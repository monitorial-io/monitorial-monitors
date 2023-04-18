select
    end_time,
    query_type,
    query_text,
    user_name,
    role_name
from
    snowflake.account_usage.query_history
where
    execution_status = 'SUCCESS'
    and query_type in (
        'CREATE_NETWORK_POLICY', 'ALTER_NETWORK_POLICY', 'DROP_NETWORK_POLICY'
    )
    or (
        query_text ilike '% set network_policy%'
        or query_text ilike '% unset network_policy%'
    )
order by end_time desc;