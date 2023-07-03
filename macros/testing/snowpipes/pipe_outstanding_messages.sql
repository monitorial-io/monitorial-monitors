{% macro pipe_outstanding_messages(database, schema, pipe_names, freshness_threshold=5,max_outstanding_messages=1) -%}

{%- for pipe in pipe_names -%}
select
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ database }}.{{ schema }}.{{ pipe_name }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data
    parse_json(SYSTEM$PIPE_STATUS('{{ database }}.{{ schema }}.{{ pipe_name }}')):pendingFileCount::number(38,0) as pendingFileCount,
    parse_json(SYSTEM$PIPE_STATUS('{{ database }}.{{ schema }}.{{ pipe_name }}')):numOutstandingMessagesOnChannel::number(38,0) as numOutstandingMessagesOnChannel
where minutes_since_last_data > {{ freshness_threshold }} and outstaning_count >= {{ max_outstanding_messages }}
{% if not loop.last %}UNION ALL{% endif %}
{%- endfor -%}
{%- endmacro %}