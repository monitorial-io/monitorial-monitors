{% macro expect_column_value_lengths_to_equal(table_or_view, column, length, row_condition) -%}
select
    '{{ table_or_view }}' as source,
    '{{ column|lower }}' as column_checked,
    min(length({{ column }})) as min_length,
    max(length({{ column }})) as max_length,
    count({{ column }}) as number_records_found
from {{ table_or_view }}
where length({{ column }}) != {{length}}
{% if row_condition %}
    and {{ row_condition }}
{% endif %}
{%- endmacro %}