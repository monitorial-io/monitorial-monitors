{% macro authentication_by_user() -%}
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
order by user_name, count(*) desc
{%- endmacro %}

{% macro not_using_sso() -%}
with sso as (
    select
        user_name as user_has_used_sso,
        min(event_timestamp) as firstsso
    from snowflake.account_usage.login_history
    where
        first_authentication_factor in ('SAML2_ASSERTION', 'OAUTH_ACCESS_TOKEN')
    group by user_name
)
select
    sso.*,
    event_timestamp,
    user_name,
    first_authentication_factor,
    second_authentication_factor,
    client_ip,
    reported_client_type
        as reported_client_version
from snowflake.account_usage.login_history as l
{%- endmacro %}

{% macro by_key_pair() -%}
select
    event_timestamp,
    user_name,
    client_ip,
    reported_client_type
        as reported_client_version,
    first_authentication_factor,
    second_authentication_factor
from snowflake.account_usage.login_history
where first_authentication_factor = 'RSA_KEYPAIR'
order by event_timestamp desc
{%- endmacro %}

{% macro key_pair_and_password() -%}
select * 
from snowflake.account_usage.users
where
    has_rsa_public_key = 'true'
    and has_password = 'true'
{%- endmacro %}

{% macro has_key_pair_not_using() -%}
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

