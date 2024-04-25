{% macro unique_check(table_or_view, column) -%}
select
    '{{ table_or_view }}' as source,
    {{ column }},
    count({{ column }}) as number_records_found
from {{ table_or_view }}
group by {{ column }}
having count({{ column }}) > 1
{%- endmacro %}