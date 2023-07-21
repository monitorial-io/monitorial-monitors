{% macro source_freshness(table_or_view, column, freshness_threshold=60) -%}
select
    '{{ table_or_view }}' as source,
    {{ column }},
    datediff(minute,{{ column }},current_timestamp) as minutes_since_last_data
from {{ table_or_view }}
where minutes_since_last_data > {{ freshness_threshold }}
{%- endmacro %}