{% macro warehouse_scaling_efficiency(time_filter=10080) -%}

WITH node_mapping AS (
    {{ dbt_monitorialio_monitors._node_mapping() }}
),
oversizing AS (
    SELECT
        q.WAREHOUSE_NAME,
        q.WAREHOUSE_SIZE,
        COUNT(*) AS total_queries,
        ROUND(COUNT(CASE WHEN q.PARTITIONS_SCANNED < n.nodes THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1) AS pct_oversized_for_data,
        n.nodes AS node_count
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
    INNER JOIN node_mapping n ON q.WAREHOUSE_SIZE = n.size
    WHERE q.START_TIME >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
      AND q.PARTITIONS_SCANNED > 0
    GROUP BY q.WAREHOUSE_NAME, q.WAREHOUSE_SIZE, n.nodes
    HAVING total_queries >= 10
),
idle AS (
    SELECT
        WAREHOUSE_NAME,
        ROUND(SUM(CASE WHEN AVG_RUNNING < 0.1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 1) AS pct_idle_time
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY
    WHERE START_TIME >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    GROUP BY WAREHOUSE_NAME
)
SELECT
    COALESCE(o.WAREHOUSE_NAME, i.WAREHOUSE_NAME) AS warehouse_name,
    COALESCE(o.WAREHOUSE_SIZE, 'Unknown') AS warehouse_size,
    COALESCE(o.total_queries, 0) AS total_queries,
    COALESCE(o.pct_oversized_for_data, 0) AS pct_oversized_for_data,
    COALESCE(i.pct_idle_time, 0) AS pct_idle_time,
    CASE
        WHEN COALESCE(o.pct_oversized_for_data, 0) > 50 AND COALESCE(i.pct_idle_time, 0) > 50 THEN 'CRITICAL - Downsize + Reduce Auto-Suspend'
        WHEN COALESCE(o.pct_oversized_for_data, 0) > 50 THEN 'HIGH - Downsize Candidate'
        WHEN COALESCE(i.pct_idle_time, 0) > 50 THEN 'HIGH - Reduce Auto-Suspend'
        WHEN COALESCE(o.pct_oversized_for_data, 0) > 20 OR COALESCE(i.pct_idle_time, 0) > 30 THEN 'MODERATE - Review Configuration'
        ELSE 'OK'
    END AS recommendation
FROM oversizing o
FULL OUTER JOIN idle i ON o.WAREHOUSE_NAME = i.WAREHOUSE_NAME
WHERE COALESCE(o.pct_oversized_for_data, 0) > 20 OR COALESCE(i.pct_idle_time, 0) > 30
ORDER BY pct_oversized_for_data DESC, pct_idle_time DESC

{%- endmacro %}
