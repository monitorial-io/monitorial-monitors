select
    user_name,
    first_authentication_factor,
    second_authentication_factor,
    count(*)
from snowflake.account_usage.login_history
where is_success = 'YES'
group by
    user_name, first_authentication_factor,
    second_authentication_factor
order by user_name, count(*) desc;