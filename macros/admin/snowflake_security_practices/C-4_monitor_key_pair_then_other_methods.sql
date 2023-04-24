{% macro key_pair_and_password(time_filter=1440) -%}
select * 
from snowflake.account_usage.users
where
    has_rsa_public_key = 'true'
    and has_password = 'true'
{%- endmacro %}

{% macro has_key_pair_not_using(time_filter=1440) -%}
select
    u.name,
    first_authentication_factor,
    second_authentication_factor,
    count(*)
from snowflake.account_usage.login_history as l
inner join
    snowflake.account_usage.users as u
    on l.user_name = u.name and has_rsa_public_key = 'true'
where is_success = 'YES' and first_authentication_factor != 'RSA_KEYPAIR'
group by
    name, first_authentication_factor,
    second_authentication_factor
order by count(*) desc
{%- endmacro %}
