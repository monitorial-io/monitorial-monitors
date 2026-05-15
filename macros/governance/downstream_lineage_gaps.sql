{% macro downstream_lineage_gaps() -%}

WITH protected_sources AS (
    SELECT DISTINCT
        tr.object_database AS database_name,
        tr.object_schema AS schema_name,
        tr.object_name AS table_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tr
    WHERE tr.domain IN ('TABLE', 'COLUMN')
      AND (
          tr.tag_name ILIKE '%SENSITIVE%'
          OR tr.tag_name ILIKE '%PII%'
          OR tr.tag_name ILIKE '%PHI%'
          OR tr.tag_name ILIKE '%PCI%'
      )
),
downstream_objects AS (
    SELECT DISTINCT
        d.referencing_database_name AS database_name,
        d.referencing_schema_name AS schema_name,
        d.referencing_object_name AS object_name,
        d.referencing_object_domain AS object_type,
        d.referenced_database_name || '.' || d.referenced_schema_name || '.' || d.referenced_object_name AS source_object
    FROM SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES d
    INNER JOIN protected_sources ps
        ON d.referenced_database_name = ps.database_name
        AND d.referenced_schema_name = ps.schema_name
        AND d.referenced_object_name = ps.table_name
),
tagged_downstream AS (
    SELECT DISTINCT
        object_database AS database_name,
        object_schema AS schema_name,
        object_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
    WHERE domain IN ('TABLE', 'COLUMN')
)
SELECT
    do_obj.database_name,
    do_obj.schema_name,
    do_obj.object_name,
    do_obj.object_type,
    do_obj.source_object
FROM downstream_objects do_obj
LEFT JOIN tagged_downstream td
    ON do_obj.database_name = td.database_name
    AND do_obj.schema_name = td.schema_name
    AND do_obj.object_name = td.object_name
WHERE td.object_name IS NULL
ORDER BY do_obj.source_object, do_obj.object_name

{%- endmacro %}
