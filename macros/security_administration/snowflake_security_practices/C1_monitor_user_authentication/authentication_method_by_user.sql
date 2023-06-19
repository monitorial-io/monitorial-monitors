{% macro authentication_method_by_user(time_filter=1440) -%}
select
    user_name,
    first_authentication_factor,
    second_authentication_factor,
    COUNT(*) AS login_count
from 
    snowflake.account_usage.login_history
where 
    is_success = 'YES'
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by
    user_name, 
    first_authentication_factor,
    second_authentication_factor
order by 
    user_name, 
    count(*) desc
{%- endmacro %}
