{% macro snowpipe_idle_credits(idle_credit_threshold=0.5, time_filter=43200) -%}

WITH pipe_costs AS (
    SELECT
        pipe_name,
        SUM(credits_used) AS credits_30d,
        SUM(bytes_inserted) / POW(1024, 3) AS gb_loaded,
        SUM(files_inserted) AS files_inserted
    FROM SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY
    WHERE start_time >= DATEADD(minutes, -{{ time_filter }}, CURRENT_TIMESTAMP())
    GROUP BY pipe_name
)
SELECT
    pipe_name,
    ROUND(credits_30d, 4) AS total_credits,
    ROUND(gb_loaded, 2) AS gb_loaded,
    files_inserted,
    ROUND(credits_30d / NULLIF(gb_loaded, 0), 4) AS credits_per_gb,
    CASE
        WHEN files_inserted = 0 AND credits_30d > 0 THEN 'IDLE_PIPE_BURNING_CREDITS'
        WHEN credits_30d / NULLIF(gb_loaded, 0) > 2 THEN 'HIGH_COST_PER_GB'
        ELSE 'INVESTIGATE'
    END AS issue_type
FROM pipe_costs
WHERE (files_inserted = 0 AND credits_30d > {{ idle_credit_threshold }})
   OR (credits_30d / NULLIF(gb_loaded, 0) > 2 AND credits_30d > {{ idle_credit_threshold }})
ORDER BY credits_30d DESC

{%- endmacro %}
