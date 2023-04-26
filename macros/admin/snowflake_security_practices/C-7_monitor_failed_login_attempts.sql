{% macro failed_login_attempts_concurrent(number_of_failures = 3, seconds_between_failures = 5, time_filter=1440) -%}
select user_name,
count(*) as failed_logins,
avg(seconds_between_login_attempts) as
average_seconds_between_login_attempts
from (select user_name,
timediff(seconds, event_timestamp, lead(event_timestamp)
over(partition by user_name order by event_timestamp)) as
seconds_between_login_attempts
from snowflake.account_usage.login_history
where is_success = 'NO'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
)
group by 1
having count(*) > {{ number_of_failures }}
and avg(seconds_between_login_attempts) < {{ seconds_between_failures }}
adjust as needed
order by avg(seconds_between_login_attempts) desc
{%- endmacro %}

{% macro failed_login_attempts(time_filter=1440) -%}
select distinct
    user_name,
    first_authentication_factor,
    count(user_name)
from snowflake.account_usage.login_history
where is_success = 'NO'
and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by user_name, first_authentication_factor
order by count(user_name) desc
{%- endmacro %}