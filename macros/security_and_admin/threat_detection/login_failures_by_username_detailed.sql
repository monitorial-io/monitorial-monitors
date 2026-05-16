{% macro login_failures_by_username_detailed (time_filter=1440,first_authentication_factor_exception_list=["ID_TOKEN"]) -%}
with exception_list as (
  select first_authentication_factors.value::string AS first_authentication_factor_exception
  from table(flatten(input => parse_json('["{{ '","'.join(first_authentication_factor_exception_list) }}"]'))) first_authentication_factors
)
select
    max(event_timestamp) as last_attempt_date,
    user_name,
    listagg(distinct client_ip, ', ') as client_ip,
    listagg(distinct reported_client_type, ', ') as reported_client_type,
    first_authentication_factor,
    error_message,
    sum(case when is_success = 'NO' then 1 else 0 end) as count_failed_logins,
    sum(case when is_success = 'YES' then 1 else 0 end) as count_successful_logins
from
    snowflake.account_usage.login_history
where
    event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
    and first_authentication_factor != ALL (
        SELECT exception_list.first_authentication_factor_exception
        FROM exception_list
    )
group by
    user_name,
    first_authentication_factor,
    error_message
having count_failed_logins > 0
order by user_name, last_attempt_date desc
{%- endmacro %}
