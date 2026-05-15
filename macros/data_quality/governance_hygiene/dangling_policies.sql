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
existing_objects AS (
    -- Tables (including materialized views which have table_type entries)
    SELECT
        table_catalog AS database_name,
        table_schema AS schema_name,
        table_name AS object_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
    WHERE deleted IS NULL
    UNION
    -- Views
    SELECT
        table_catalog AS database_name,
        table_schema AS schema_name,
        table_name AS object_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.VIEWS
    WHERE deleted IS NULL
)
SELECT
    pr.policy_name,
    pr.policy_kind,
    pr.ref_database_name || '.' || pr.ref_schema_name || '.' || pr.ref_entity_name AS referenced_object
FROM policy_refs pr
LEFT JOIN existing_objects eo
    ON pr.ref_database_name = eo.database_name
    AND pr.ref_schema_name = eo.schema_name
    AND pr.ref_entity_name = eo.object_name
WHERE eo.object_name IS NULL
ORDER BY pr.policy_kind, pr.policy_name

{%- endmacro %}
