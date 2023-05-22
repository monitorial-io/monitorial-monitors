{% macro has_network_policy () -%}
--<prereq> show parameters like 'network_policy' in account;
select 
    * 
from 
    table(result_scan(last_query_id())) 
where "value" = ''
{%- endmacro %}

