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
inner join sso
    on sso.user_has_used_sso = l.user_name
where
    first_authentication_factor not in ('SAML2_ASSERTION', 'OAUTH_ACCESS_TOKEN')
    and l.event_timestamp > firstsso
order by l.event_timestamp desc;
