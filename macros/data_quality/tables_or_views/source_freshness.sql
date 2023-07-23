{% macro source_freshness(table_or_view, column, datepart="minute", freshness_threshold=60) -%}
select
    '{{ table_or_view }}' as source,
    '{{ column|lower }}' as column_checked,
    max({{ column }}) as last_record_dated,
    convert_timezone('UTC', current_timestamp()) as snapshotted_at
from {{ table_or_view }}
where datediff({{datepart}},{{ column }},current_timestamp) >  {{ freshness_threshold }}
{%- endmacro %}
