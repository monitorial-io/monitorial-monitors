{% macro has_key_pair_using_other(time_filter=1440) -%}
select
    u.name,
    first_authentication_factor,
    second_authentication_factor,
    count(*)
from snowflake.account_usage.login_history as l
inner join
    snowflake.account_usage.users as u
    on l.user_name = u.name and has_rsa_public_key = 'true'
where 
    is_success = 'YES' 
    and first_authentication_factor != 'RSA_KEYPAIR'
    and event_timestamp >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by
    name, first_authentication_factor,
    second_authentication_factor
order by count(*) desc
{%- endmacro %}
