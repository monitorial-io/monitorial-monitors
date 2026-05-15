{% macro bulk_load_small_files(avg_file_mb_threshold=10, min_files=100, time_filter=43200) -%}

SELECT
    table_name,
    pipe_name,
    COUNT(*) AS file_count,
    ROUND(AVG(file_size) / POW(1024, 2), 2) AS avg_file_mb,
    ROUND(MIN(file_size) / POW(1024, 2), 2) AS min_file_mb,
    ROUND(MAX(file_size) / POW(1024, 2), 2) AS max_file_mb,
    SUM(row_count) AS total_rows,
    CASE
        WHEN AVG(file_size) / POW(1024, 2) < 1 THEN 'CRITICAL - Files < 1MB'
        WHEN AVG(file_size) / POW(1024, 2) < 5 THEN 'HIGH - Files < 5MB'
        WHEN AVG(file_size) / POW(1024, 2) < {{ avg_file_mb_threshold }} THEN 'MODERATE'
        ELSE 'OK'
    END AS file_size_health
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE last_load_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
  AND status = 'Loaded'
GROUP BY table_name, pipe_name
HAVING file_count >= {{ min_files }}
  AND AVG(file_size) / POW(1024, 2) < {{ avg_file_mb_threshold }}
ORDER BY file_count DESC

{%- endmacro %}
