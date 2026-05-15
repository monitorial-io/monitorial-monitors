{#
  Identifies tables with significant storage that have not been accessed within the
  lookback window defined by days_inactive.

  Note: ACCESS_HISTORY is only searched within the days_inactive window.  Objects that
  appear here had NO access during that window.  The column days_since_creation shows
  the object age (not last-access time) because ACCESS_HISTORY does not retain events
  older than the lookback period.
#}
{% macro unused_objects(days_inactive=90) -%}

WITH object_access AS (
    SELECT
        OBJECT_DATABASE AS database_name,
        OBJECT_SCHEMA AS schema_name,
        OBJECT_NAME AS object_name,
        MAX(QUERY_START_TIME) AS last_accessed
    FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY,
         LATERAL FLATTEN(input => BASE_OBJECTS_ACCESSED) f
    WHERE QUERY_START_TIME >= DATEADD('day', -{{ days_inactive }}, CURRENT_TIMESTAMP())
    GROUP BY 1, 2, 3
),
all_tables AS (
    SELECT
        table_catalog AS database_name,
        table_schema AS schema_name,
        table_name AS object_name,
        ROUND(active_bytes / POW(1024, 3), 2) AS storage_gb,
        created
    FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS tsm
    JOIN SNOWFLAKE.ACCOUNT_USAGE.TABLES t ON tsm.id = t.table_id
    WHERE tsm.deleted = FALSE
      AND t.deleted IS NULL
      AND t.table_schema != 'INFORMATION_SCHEMA'
      AND tsm.active_bytes > 104857600
)
SELECT
    at.database_name,
    at.schema_name,
    at.object_name,
    at.storage_gb,
    at.created,
    DATEDIFF('day', at.created, CURRENT_TIMESTAMP()) AS days_since_creation
FROM all_tables at
LEFT JOIN object_access oa
    ON at.database_name = oa.database_name
    AND at.schema_name = oa.schema_name
    AND at.object_name = oa.object_name
WHERE oa.last_accessed IS NULL
ORDER BY at.storage_gb DESC
LIMIT 30

{%- endmacro %}
