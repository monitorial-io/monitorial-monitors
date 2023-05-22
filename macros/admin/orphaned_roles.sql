{% macro orphan_roles(exception_list=["ACCOUNTADMIN", "ORGADMIN", "PUBLIC"]) -%}

WITH exception_list AS (

  SELECT role_names.value::string AS role_exception
  FROM TABLE(flatten(input => parse_json('["{{ '","'.join(exception_list) }}"]'))) role_names 
),
active_roles AS (

    SELECT name
    FROM snowflake.account_usage.roles
    WHERE snowflake.account_usage.roles.name != ALL (
        SELECT exception_list.role_exception
        FROM exception_list) AND
        deleted_on IS NULL
),
role_grants AS (

    SELECT DISTINCT NAME
    FROM
        snowflake.account_usage.grants_to_roles
    WHERE
        granted_on = 'ROLE' AND
        granted_to = 'ROLE' AND
        deleted_on IS NULL AND
        privilege = 'USAGE'
)
SELECT active_roles.name
FROM
    active_roles
    LEFT OUTER JOIN role_grants ON active_roles.name = role_grants.name
WHERE role_grants.name IS NULL
{%- endmacro %}