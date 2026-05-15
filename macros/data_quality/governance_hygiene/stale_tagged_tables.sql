{% macro stale_tagged_tables(days_stale=90) -%}

WITH tagged_tables AS (
    SELECT DISTINCT
        tr.object_database AS database_name,
        tr.object_schema AS schema_name,
        tr.object_name AS table_name,
        tr.tag_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tr
    WHERE tr.domain IN ('TABLE', 'COLUMN')
),
table_metadata AS (
    SELECT
        table_catalog AS database_name,
        table_schema AS schema_name,
        table_name,
        last_altered
    FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
    WHERE deleted IS NULL
)
SELECT
    tt.database_name,
    tt.schema_name,
    tt.table_name,
    tm.last_altered,
    DATEDIFF('day', tm.last_altered, CURRENT_TIMESTAMP()) AS days_since_modified,
    LISTAGG(DISTINCT tt.tag_name, ', ') WITHIN GROUP (ORDER BY tt.tag_name) AS applied_tags
FROM tagged_tables tt
JOIN table_metadata tm
    ON tt.database_name = tm.database_name
    AND tt.schema_name = tm.schema_name
    AND tt.table_name = tm.table_name
WHERE DATEDIFF('day', tm.last_altered, CURRENT_TIMESTAMP()) > {{ days_stale }}
GROUP BY tt.database_name, tt.schema_name, tt.table_name, tm.last_altered
ORDER BY days_since_modified DESC

{%- endmacro %}
