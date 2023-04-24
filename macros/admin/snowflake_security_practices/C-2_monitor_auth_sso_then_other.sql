{% macro not_using_sso(time_filter=1440) -%}
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
