{% macro warehouse_oversizing(pct_oversized_threshold=50, time_filter=10080) -%}

WITH node_mapping AS (
    SELECT 'X-Small' AS size, 1 AS nodes UNION ALL
    SELECT 'Small', 2 UNION ALL SELECT 'Medium', 4 UNION ALL
    SELECT 'Large', 8 UNION ALL SELECT 'X-Large', 16 UNION ALL
    SELECT '2X-Large', 32 UNION ALL SELECT '3X-Large', 64 UNION ALL
    SELECT '4X-Large', 128 UNION ALL SELECT '5X-Large', 256 UNION ALL
    SELECT '6X-Large', 512
)
SELECT
    q.WAREHOUSE_NAME,
    q.WAREHOUSE_SIZE,
    COUNT(*) AS total_queries,
    COUNT(CASE WHEN q.PARTITIONS_SCANNED < n.nodes THEN 1 END) AS oversized_queries,
    ROUND(COUNT(CASE WHEN q.PARTITIONS_SCANNED < n.nodes THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1) AS pct_oversized
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
INNER JOIN node_mapping n ON q.WAREHOUSE_SIZE = n.size
WHERE q.START_TIME >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND q.WAREHOUSE_SIZE NOT IN ('X-Small', 'Small')
  AND q.PARTITIONS_SCANNED > 0
GROUP BY q.WAREHOUSE_NAME, q.WAREHOUSE_SIZE
HAVING pct_oversized >= {{ pct_oversized_threshold }}
ORDER BY pct_oversized DESC

{%- endmacro %}
