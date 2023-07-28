{% macro streams_gone_stale (databases) -%}
--<prereq> show streams in account;
select 
    concat("database_name",'.',"schema_name",'.',"name") as stream_name,
    "table_name" as table_name,
    "source_type" as source_type,
    "mode" as insert_mode,
    "stale" as is_stale,
    "invalid_reason" as invalid_reason
from
    table(result_scan(last_query_id())) 
where "stale" = true
and "database_name" in ({%- for database in databases -%}'{{database}}'{% if not loop.last %},{% endif %}{% endfor %})
{%- endmacro %}
