{% macro expect_column_values_to_be_between(table_or_view, column, min_value, max_value) -%}
select
    '{{ table_or_view }}' as source,
    {{ column }},
    min({{ column }}) as min_value,
    max({{ column }}) as min_value,
    count({{ column }}) as number_records_found
from {{ table_or_view }}
where {{ column }} < {{min_value}}
or {{ column }} > {{max_value}}
{%- endmacro %}