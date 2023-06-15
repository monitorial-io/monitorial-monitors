{% macro scim_token_creation(time_filter=1440) -%}
select *
from
    snowflake.account_usage.query_history 
where execution_status = 'SUCCESS'
and query_text ilike '%system$generate_scim_access_token%'
and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
{%- endmacro %}

