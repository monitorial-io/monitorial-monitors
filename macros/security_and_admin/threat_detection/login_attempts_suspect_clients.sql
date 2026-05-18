{% macro login_attempts_suspect_clients (time_filter=1440) -%}
select
    *
from
    snowflake.account_usage.sessions
where
    parse_json(client_environment):application = 'rapeflake'
    or
    (
        parse_json(client_environment):application = 'dbeaver_dbeaverultimate'
        and
        parse_json(client_environment):os = 'windows server 2022'
    )
    and 
        created_on > dateadd(minutes, -{{ time_filter }}, current_timestamp)
order by created_on
{%- endmacro %}
