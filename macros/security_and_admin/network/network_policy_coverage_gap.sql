{% macro network_policy_coverage_gap() -%}

WITH users_with_policies AS (
    SELECT DISTINCT
        p.ref_entity_name AS user_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES p
    WHERE p.policy_kind = 'NETWORK_POLICY'
      AND p.ref_entity_domain = 'USER'
),
account_policy AS (
    SELECT COUNT(*) AS has_account_policy
    FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
    WHERE policy_kind = 'NETWORK_POLICY'
      AND ref_entity_domain = 'ACCOUNT'
)
SELECT
    u.name AS user_name,
    u.type AS user_type,
    u.default_role,
    u.last_success_login,
    CASE
        WHEN gu.role IN ('ACCOUNTADMIN', 'SECURITYADMIN') THEN 'CRITICAL'
        WHEN u.type = 'SERVICE' THEN 'HIGH'
        ELSE 'MODERATE'
    END AS risk_level
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS u
LEFT JOIN users_with_policies uwp ON u.name = uwp.user_name
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS gu
    ON u.name = gu.grantee_name
    AND gu.role IN ('ACCOUNTADMIN', 'SECURITYADMIN')
    AND gu.deleted_on IS NULL
CROSS JOIN account_policy ap
WHERE u.deleted_on IS NULL
  AND uwp.user_name IS NULL
  AND ap.has_account_policy = 0
ORDER BY risk_level, u.name

{%- endmacro %}
