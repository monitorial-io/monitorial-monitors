{% macro mfa_auth_stats(time_filter=1440) -%}
select
    first_authentication_factor,
    second_authentication_factor,
    count(*) as count_of_authentication
from 
    snowflake.account_usage.login_history 
where 
    is_success = 'YES'
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by
    first_authentication_factor,
    second_authentication_factor
order by 
    count(*) desc
{%- endmacro %}
