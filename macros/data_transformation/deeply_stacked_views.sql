{% macro deeply_stacked_views(max_depth=5) -%}

WITH RECURSIVE view_deps AS (
    SELECT
        referenced_database_name AS source_db,
        referenced_schema_name AS source_schema,
        referenced_object_name AS source_object,
        referencing_database_name AS dependent_db,
        referencing_schema_name AS dependent_schema,
        referencing_object_name AS dependent_object,
        1 AS depth
    FROM SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
    WHERE referenced_object_domain = 'VIEW'
      AND referencing_object_domain = 'VIEW'

    UNION ALL

    SELECT
        d.referenced_database_name,
        d.referenced_schema_name,
        d.referenced_object_name,
        vd.dependent_db,
        vd.dependent_schema,
        vd.dependent_object,
        vd.depth + 1
    FROM view_deps vd
    JOIN SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES d
        ON vd.source_db = d.referencing_database_name
        AND vd.source_schema = d.referencing_schema_name
        AND vd.source_object = d.referencing_object_name
    WHERE d.referenced_object_domain = 'VIEW'
      AND vd.depth < 10
)
SELECT
    dependent_db || '.' || dependent_schema || '.' || dependent_object AS view_name,
    MAX(depth) AS max_depth,
    COUNT(DISTINCT source_db || '.' || source_schema || '.' || source_object) AS upstream_view_count
FROM view_deps
GROUP BY 1
HAVING max_depth > {{ max_depth }}
ORDER BY max_depth DESC

{%- endmacro %}
