{% macro pipe_freshness(database, schema, pipe_names) -%}

{%- for pipe in pipe_names -%}
select
    parse_json(SYSTEM$PIPE_STATUS('{{ database }}.{{ schema }}.{{ pipe_name }}')):channelErrorMessage::text as channelErrorMessage
where channelErrorMessage is not null
{% if not loop.last %}UNION ALL{% endif %}
{%- endfor -%}
{%- endmacro %}