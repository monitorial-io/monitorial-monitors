{% macro not_null(table_or_view, column) -%}
select
    '{{ table_or_view }}' as source,
    {{ column }},
    count({{ column }}) as number_records_found
from {{ table_or_view }}
where {{ column }} is null
group by {{ column }}
{%- endmacro %}