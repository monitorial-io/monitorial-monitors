{% macro privileged_users_no_mfa() -%}

WITH privileged_users AS (
    SELECT DISTINCT
        gu.grantee_name AS user_name,
        gu.role AS privileged_role
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS gu
    WHERE gu.role IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN', 'USERADMIN')
      AND gu.deleted_on IS NULL
),
user_details AS (
    SELECT
        name,
        type,
        default_role,
        last_success_login,
        has_password,
        ext_authn_duo,
        has_rsa_public_key
    FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
    WHERE deleted_on IS NULL
)
SELECT
    pu.user_name,
    pu.privileged_role,
    ud.type AS user_type,
    ud.default_role,
    ud.last_success_login,
    DATEDIFF('day', ud.last_success_login, CURRENT_TIMESTAMP()) AS days_since_login
FROM privileged_users pu
INNER JOIN user_details ud ON pu.user_name = ud.name
WHERE ud.has_password = 'true'
  AND COALESCE(ud.ext_authn_duo, 'false') = 'false'
ORDER BY pu.privileged_role, pu.user_name

{%- endmacro %}
