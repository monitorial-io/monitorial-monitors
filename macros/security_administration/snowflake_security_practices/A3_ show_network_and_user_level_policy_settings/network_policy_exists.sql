{% macro network_policy_exists () -%}
--<prereq> show parameters like 'network_policy' in account;
select 
    * 
from 
    table(result_scan(last_query_id())) 
where "value" = ''
{%- endmacro %}

