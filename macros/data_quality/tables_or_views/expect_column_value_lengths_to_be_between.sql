{% macro expect_column_value_lengths_to_be_between(table_or_view, column, min_length, max_length) -%}
select
    '{{ table_or_view }}' as source,
    '{{ column|lower }}' as column_checked,
    min(length({{ column }})) as min_length,
    max(length({{ column }})) as max_length,
    count({{ column }}) as number_records_found
from {{ table_or_view }}
where length({{ column }}) < {{min_length}}
or length{{ column }}) > {{max_length}}
{%- endmacro %}