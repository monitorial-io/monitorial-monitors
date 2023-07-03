{% macro pipe_freshness(database, schema, pipe_names, freshness_threshold=5) -%}

{%- for pipe in pipe_names -%}
select
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ database }}.{{ schema }}.{{ pipe_name }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data
where minutes_since_last_data > {{ freshness_threshold }} or minutes_since_last_data is null
{% if not loop.last %}UNION ALL{% endif %}
{%- endfor -%}
{%- endmacro %}