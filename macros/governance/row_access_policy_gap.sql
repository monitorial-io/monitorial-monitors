{% macro row_access_policy_gap() -%}

WITH tables_with_sensitive_tags AS (
    SELECT DISTINCT
        tr.object_database AS database_name,
        tr.object_schema AS schema_name,
        tr.object_name AS table_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tr
    WHERE tr.domain = 'COLUMN'
      AND (
          tr.tag_name ILIKE '%SENSITIVE%'
          OR tr.tag_name ILIKE '%PII%'
          OR tr.tag_name ILIKE '%PHI%'
          OR tr.tag_name ILIKE '%PCI%'
          OR tr.tag_name ILIKE '%GDPR%'
          OR tr.tag_value ILIKE '%SENSITIVE%'
          OR tr.tag_value ILIKE '%IDENTIFIER%'
      )
),
tables_with_rap AS (
    SELECT DISTINCT
        ref_database_name AS database_name,
        ref_schema_name AS schema_name,
        ref_entity_name AS table_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
    WHERE policy_kind = 'ROW_ACCESS_POLICY'
)
SELECT
    ts.database_name,
    ts.schema_name,
    ts.table_name
FROM tables_with_sensitive_tags ts
LEFT JOIN tables_with_rap rap
    ON ts.database_name = rap.database_name
    AND ts.schema_name = rap.schema_name
    AND ts.table_name = rap.table_name
WHERE rap.table_name IS NULL
ORDER BY ts.database_name, ts.schema_name, ts.table_name

{%- endmacro %}
