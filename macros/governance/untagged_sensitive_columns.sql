{% macro untagged_sensitive_columns() -%}

WITH sensitive_patterns AS (
    SELECT
        c.table_catalog AS database_name,
        c.table_schema AS schema_name,
        c.table_name,
        c.column_name,
        CASE
            WHEN c.column_name ILIKE '%EMAIL%' THEN 'EMAIL'
            WHEN c.column_name ILIKE '%SSN%' OR c.column_name ILIKE '%SOCIAL_SECURITY%' THEN 'SSN'
            WHEN c.column_name ILIKE '%PHONE%' OR c.column_name ILIKE '%MOBILE%' THEN 'PHONE'
            WHEN c.column_name ILIKE '%CREDIT_CARD%' OR c.column_name ILIKE '%CARD_NUMBER%' THEN 'CREDIT_CARD'
            WHEN c.column_name ILIKE '%DOB%' OR c.column_name ILIKE '%DATE_OF_BIRTH%' OR c.column_name ILIKE '%BIRTH_DATE%' THEN 'DOB'
            WHEN c.column_name ILIKE '%SALARY%' OR c.column_name ILIKE '%COMPENSATION%' THEN 'COMPENSATION'
            WHEN c.column_name ILIKE '%ADDRESS%' OR c.column_name ILIKE '%STREET%' THEN 'ADDRESS'
            WHEN c.column_name ILIKE '%PASSPORT%' THEN 'PASSPORT'
            WHEN c.column_name ILIKE '%LICENSE%' AND c.column_name ILIKE '%DRIVER%' THEN 'DRIVERS_LICENSE'
        END AS detected_category
    FROM SNOWFLAKE.ACCOUNT_USAGE.COLUMNS c
    JOIN SNOWFLAKE.ACCOUNT_USAGE.TABLES t ON c.table_id = t.table_id
    WHERE t.deleted IS NULL
      AND c.deleted IS NULL
      AND t.table_schema != 'INFORMATION_SCHEMA'
),
tagged_columns AS (
    SELECT DISTINCT
        object_database AS database_name,
        object_schema AS schema_name,
        object_name AS table_name,
        column_name
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
    WHERE domain = 'COLUMN'
)
SELECT
    sp.database_name,
    sp.schema_name,
    sp.table_name,
    sp.column_name,
    sp.detected_category
FROM sensitive_patterns sp
LEFT JOIN tagged_columns tc
    ON sp.database_name = tc.database_name
    AND sp.schema_name = tc.schema_name
    AND sp.table_name = tc.table_name
    AND sp.column_name = tc.column_name
WHERE sp.detected_category IS NOT NULL
  AND tc.column_name IS NULL
ORDER BY sp.detected_category, sp.database_name

{%- endmacro %}
