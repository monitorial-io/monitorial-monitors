{% macro is_not_null(table_or_view, column) -%}
select
    '{{ table_or_view }}' as source,
    {{ column }},
    count(*) as no_null_records
from {{ table_or_view }}
where no_null_records > 0
group by {{ column }}
{%- endmacro %}