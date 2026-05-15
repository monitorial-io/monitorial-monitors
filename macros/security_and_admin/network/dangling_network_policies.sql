{% macro dangling_network_policies() -%}

WITH all_policies AS (
    SELECT
        policy_name,
        created
    FROM SNOWFLAKE.ACCOUNT_USAGE.NETWORK_POLICIES
    WHERE deleted IS NULL
),
assigned_policies AS (
    SELECT DISTINCT
        policy_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
    WHERE policy_kind = 'NETWORK_POLICY'
)
SELECT
    ap.policy_name,
    ap.created,
    DATEDIFF('day', ap.created, CURRENT_TIMESTAMP()) AS age_days
FROM all_policies ap
LEFT JOIN assigned_policies asgn ON ap.policy_name = asgn.policy_name
WHERE asgn.policy_name IS NULL
ORDER BY ap.created

{%- endmacro %}
