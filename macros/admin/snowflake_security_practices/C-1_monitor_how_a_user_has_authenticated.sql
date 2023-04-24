{% macro authentication_by_user(time_filter=1440) -%}
select
    user_name,
    first_authentication_factor,
    second_authentication_factor,
    COUNT(*) AS login_count
from snowflake.account_usage.login_history
where is_success = 'YES'
and end_time >= dateadd(minutes, -{{ time_filter }}, current_time)
group by
    user_name, first_authentication_factor,
    second_authentication_factor
order by user_name, count(*) desc
{%- endmacro %}
