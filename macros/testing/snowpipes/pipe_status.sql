{% macro pipe_status(database, schema, pipe_names, exception_list=["RUNNING", "PAUSED", "STOPPED_CLONED"]) -%}

{%- for pipe in pipe_names -%}
select
    parse_json(SYSTEM$PIPE_STATUS('{{ database }}.{{ schema }}.{{ pipe_name }}')):executionState::text as executionState
where executionState not in ({%- for state in exception_list -%}'{{state}}'{% if not loop.last %},{% endif %}{% endfor %})
{% if not loop.last %}UNION ALL{% endif %}
{%- endfor -%}
{%- endmacro %}