{% macro inactive_privileged_users(days_inactive=90) -%}

WITH privileged_users AS (
    SELECT DISTINCT
        gu.grantee_name AS user_name,
        gu.role AS privileged_role
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS gu
    WHERE gu.role IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN')
      AND gu.deleted_on IS NULL
),
user_details AS (
    SELECT name, type, last_success_login
    FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
    WHERE deleted_on IS NULL
)
SELECT
    pu.user_name,
    pu.privileged_role,
    ud.type AS user_type,
    ud.last_success_login,
    DATEDIFF('day', ud.last_success_login, CURRENT_TIMESTAMP()) AS days_since_login
FROM privileged_users pu
INNER JOIN user_details ud ON pu.user_name = ud.name
WHERE (ud.last_success_login <= DATEADD('day', -{{ days_inactive }}, CURRENT_TIMESTAMP())
       OR ud.last_success_login IS NULL)
ORDER BY days_since_login DESC

{%- endmacro %}
