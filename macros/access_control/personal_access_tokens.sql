{% macro personal_access_tokens() -%}

SELECT
    user_name,
    COUNT(*) AS token_count,
    MIN(created_on) AS earliest_token_created,
    MAX(created_on) AS latest_token_created,
    MAX(last_used_on) AS last_used
FROM SNOWFLAKE.ACCOUNT_USAGE.PERSONAL_ACCESS_TOKENS
WHERE deleted_on IS NULL
GROUP BY user_name
ORDER BY token_count DESC

{%- endmacro %}
