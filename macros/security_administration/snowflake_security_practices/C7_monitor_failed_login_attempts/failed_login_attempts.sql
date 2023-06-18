{% macro failed_login_attempts(number_of_failures = 3, time_filter=1440) -%}
select distinct
    user_name,
    first_authentication_factor,
    count(user_name) as failed_logins_count
from 
    snowflake.account_usage.login_history
where 
    is_success = 'NO'
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by 
    user_name, 
    first_authentication_factor
having 
    count(*) > {{ number_of_failures }}
order by 
    count(user_name) desc
{%- endmacro %}