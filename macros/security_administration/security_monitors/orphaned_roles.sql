{% macro orphaned_roles(exception_list=["ACCOUNTADMIN", "ORGADMIN", "PUBLIC"]) -%}

with exception_list as (
  select role_names.value::string AS role_exception
  from table(flatten(input => parse_json('["{{ '","'.join(exception_list) }}"]'))) role_names
),
active_roles AS (

    select name
    from snowflake.account_usage.roles
    where snowflake.account_usage.roles.name != ALL (
        select exception_list.role_exception
        from exception_list) and
        deleted_on is null
),
role_grants AS (

    select distinct name
    from
        snowflake.account_usage.grants_to_roles
    where
        granted_on = 'ROLE' and
        granted_to = 'ROLE' and
        deleted_on is null and
        privilege = 'USAGE'
)
select active_roles.name
from
    active_roles
    left outer join role_grants on active_roles.name = role_grants.name
where role_grants.name is null
{%- endmacro %}