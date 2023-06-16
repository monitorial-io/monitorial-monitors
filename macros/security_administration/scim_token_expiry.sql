{% macro scim_token_expiry(warn_after_days=175) -%}
select 
    datediff(day,max(start_time),current_timestamp) as days_since_last_scim_token_renewal
from snowflake.account_usage.query_history 
where query_text like 'select system$generate_scim_access_token%'
having days_since_last_scim_token_renewal > {{ warn_after_days }};
{%- endmacro %}