{% macro low_declarative_ddl_adoption(min_declarative_pct=10, time_filter=43200) -%}

WITH ddl_patterns AS (
    SELECT
        CASE
            WHEN query_text ILIKE '%CREATE OR ALTER%' THEN 'Declarative'
            WHEN query_text ILIKE '%EXECUTE IMMEDIATE FROM%' THEN 'Declarative'
            ELSE 'Imperative'
        END AS ddl_category,
        COUNT(*) AS execution_count
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
      AND query_type IN ('CREATE_TABLE', 'ALTER_TABLE', 'EXECUTE_IMMEDIATE', 'CREATE_VIEW', 'ALTER_VIEW')
      AND execution_status = 'SUCCESS'
    GROUP BY ddl_category
),
totals AS (
    SELECT
        SUM(execution_count) AS total_ddl,
        SUM(CASE WHEN ddl_category = 'Declarative' THEN execution_count ELSE 0 END) AS declarative_ddl
    FROM ddl_patterns
)
SELECT
    total_ddl,
    declarative_ddl,
    total_ddl - declarative_ddl AS imperative_ddl,
    ROUND(declarative_ddl * 100.0 / NULLIF(total_ddl, 0), 1) AS declarative_pct
FROM totals
WHERE declarative_ddl * 100.0 / NULLIF(total_ddl, 0) < {{ min_declarative_pct }}
  AND total_ddl > 0

{%- endmacro %}
