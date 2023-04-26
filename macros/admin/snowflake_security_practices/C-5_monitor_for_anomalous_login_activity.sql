{% macro frequently_authenticated_users(time_filter=1440) -%}
select distinct
    user_name,
    first_authentication_factor,
    count(user_name)
from snowflake.account_usage.login_history
where is_success = 'YES'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by user_name, first_authentication_factor
order by count(user_name) desc
{%- endmacro %}



