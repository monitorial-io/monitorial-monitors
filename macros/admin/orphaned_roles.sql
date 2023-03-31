{% macro orphan_roles(exception_list) -%}

with exception_list as (
  select role_names.value::string AS role_exception from table(flatten(input => parse_json('{{ exception_list }}'))) role_names
),
active_roles as (
    select 
        name
    from snowflake.account_usage.roles
    where snowflake.account_usage.roles.name != ALL (SELECT exception_list.role_exception
                              FROM exception_list) and
        deleted_on is null
),
role_grants as (
    select 
        distinct  name
    from     
        snowflake.account_usage.grants_to_roles
    where 
        granted_on = 'ROLE' and 
        granted_to = 'ROLE' and 
        deleted_on is null and 
        privilege = 'USAGE'
)
select 
    active_roles.name
from
    active_roles left outer join role_grants on active_roles.name = role_grants.name
where role_grants.name is null

{%- endmacro %}