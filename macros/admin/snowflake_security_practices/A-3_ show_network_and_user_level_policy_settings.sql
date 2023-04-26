{% macro has_network_policy () -%}
--execute_immediate=show parameters like 'network_policy' in account

select * 
from 
    table(result_scan(last_query_id()) 
where "value" = ''
{%- endmacro %}

