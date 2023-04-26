{% macro changes_to_network_policies (time_filter=1440) -%}
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

    and query_type IN (
        'CREATE_NETWORK_POLICY', 'ALTER_NETWORK_POLICY', 'DROP_NETWORK_POLICY'
    )
    or (
        query_text ILIKE '% set network_policy%'
        or query_text ILIKE '% unset network_policy%'
    )
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by end_time desc
{%- endmacro %}
