{% macro periodic_rekey_enabled(time_filter=1440) -%}
--<prereq> show parameters like 'periodic_data_rekeying' in account;
select 
    * 
from 
    table(result_scan(last_query_id())) 
where "value" = false
{%- endmacro %}
