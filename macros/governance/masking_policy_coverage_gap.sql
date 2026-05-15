{% macro masking_policy_coverage_gap() -%}

WITH sensitive_tagged AS (
    SELECT DISTINCT
        tr.object_database AS database_name,
        tr.object_schema AS schema_name,
        tr.object_name AS table_name,
        tr.column_name,
        tr.tag_name,
        tr.tag_value
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tr
    WHERE tr.domain = 'COLUMN'
      AND {{ dbt_monitorialio_monitors._sensitive_tag_filter('tr.tag_name', 'tr.tag_value') }}
),
masked_columns AS (
    SELECT DISTINCT
        ref_database_name AS database_name,
        ref_schema_name AS schema_name,
        ref_entity_name AS table_name,
        ref_column_name AS column_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
    WHERE policy_kind = 'MASKING_POLICY'
)
SELECT
    st.database_name,
    st.schema_name,
    st.table_name,
    st.column_name,
    st.tag_name,
    st.tag_value
FROM sensitive_tagged st
LEFT JOIN masked_columns mc
    ON st.database_name = mc.database_name
    AND st.schema_name = mc.schema_name
    AND st.table_name = mc.table_name
    AND st.column_name = mc.column_name
WHERE mc.column_name IS NULL
ORDER BY st.database_name, st.table_name, st.column_name

{%- endmacro %}
