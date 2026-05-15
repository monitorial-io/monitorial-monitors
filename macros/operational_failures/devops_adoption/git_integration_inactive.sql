{#
  Limitation: Git repository names are extracted from query_text via regex because
  ACCOUNT_USAGE does not expose a structured Git repository inventory view.
  The regex handles unquoted identifiers (alphanumeric, dots, underscores).
  Quoted identifiers (e.g., "My Repo") will not be captured.
#}
{% macro git_integration_inactive(days_inactive=30) -%}

WITH git_activity AS (
    -- Search the full ACCOUNT_USAGE retention window for any Git activity
    SELECT
        REGEXP_SUBSTR(query_text, '(ALTER|CREATE)\\s+GIT\\s+REPOSITORY\\s+([a-zA-Z0-9_.]+)', 1, 1, 'i', 2) AS repo_name,
        MAX(start_time) AS last_activity
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE (
          query_text ILIKE '%GIT%FETCH%'
          OR query_text ILIKE '%EXECUTE IMMEDIATE FROM%'
          OR query_text ILIKE '%ALTER GIT REPOSITORY%FETCH%'
      )
      AND execution_status = 'SUCCESS'
    GROUP BY repo_name
),
all_git_repos AS (
    SELECT
        REGEXP_SUBSTR(query_text, 'CREATE\\s+(OR\\s+REPLACE\\s+)?GIT\\s+REPOSITORY\\s+([a-zA-Z0-9_.]+)', 1, 1, 'i', 2) AS repo_name,
        MAX(start_time) AS created_at
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    WHERE query_text ILIKE '%CREATE%GIT%REPOSITORY%'
      AND execution_status = 'SUCCESS'
    GROUP BY repo_name
)
SELECT
    agr.repo_name,
    agr.created_at,
    ga.last_activity,
    DATEDIFF('day', COALESCE(ga.last_activity, agr.created_at), CURRENT_TIMESTAMP()) AS days_since_activity
FROM all_git_repos agr
LEFT JOIN git_activity ga ON agr.repo_name = ga.repo_name
WHERE DATEDIFF('day', COALESCE(ga.last_activity, agr.created_at), CURRENT_TIMESTAMP()) > {{ days_inactive }}
ORDER BY days_since_activity DESC

{%- endmacro %}
