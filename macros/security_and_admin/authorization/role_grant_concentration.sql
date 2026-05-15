{% macro role_grant_concentration(grant_threshold=100) -%}

SELECT
    grantee_name AS role_name,
    COUNT(*) AS total_grants,
    COUNT(DISTINCT granted_on) AS distinct_object_types,
    COUNT(CASE WHEN privilege = 'OWNERSHIP' THEN 1 END) AS ownership_grants,
    COUNT(CASE WHEN privilege IN ('ALL', 'ALL PRIVILEGES') THEN 1 END) AS all_privilege_grants,
    CASE
        WHEN COUNT(*) > 500 THEN 'VERY_HIGH'
        WHEN COUNT(*) > 100 THEN 'HIGH'
        ELSE 'MODERATE'
    END AS grant_concentration,
    CASE
        WHEN COUNT(CASE WHEN privilege IN ('ALL', 'ALL PRIVILEGES') THEN 1 END) > 0 THEN 'Review ALL PRIVILEGES grants'
        WHEN COUNT(CASE WHEN privilege = 'OWNERSHIP' THEN 1 END) > 50 THEN 'Consider splitting role responsibilities'
        ELSE 'Consider more granular role structure'
    END AS recommendation
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE deleted_on IS NULL
  AND grantee_name NOT IN ('ACCOUNTADMIN', 'SYSADMIN', 'SECURITYADMIN', 'USERADMIN', 'PUBLIC')
GROUP BY grantee_name
HAVING COUNT(*) > {{ grant_threshold }}
ORDER BY total_grants DESC

{%- endmacro %}
