{% macro dangling_policies() -%}

WITH policy_refs AS (
    SELECT
        policy_name,
        policy_kind,
        ref_database_name,
        ref_schema_name,
        ref_entity_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
    WHERE policy_kind IN ('MASKING_POLICY', 'ROW_ACCESS_POLICY')
),
existing_tables AS (
    SELECT
        table_catalog AS database_name,
        table_schema AS schema_name,
        table_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
    WHERE deleted IS NULL
)
SELECT
    pr.policy_name,
    pr.policy_kind,
    pr.ref_database_name || '.' || pr.ref_schema_name || '.' || pr.ref_entity_name AS referenced_object
FROM policy_refs pr
LEFT JOIN existing_tables et
    ON pr.ref_database_name = et.database_name
    AND pr.ref_schema_name = et.schema_name
    AND pr.ref_entity_name = et.table_name
WHERE et.table_name IS NULL
ORDER BY pr.policy_kind, pr.policy_name

{%- endmacro %}
