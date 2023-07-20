{% macro pipe_freshness(pipe, freshness_threshold=5) -%}
select
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):pendingFileCount::number(38,0) as pendingFileCount,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):numOutstandingMessagesOnChannel::number(38,0) as numOutstandingMessagesOnChannel
where minutes_since_last_data > {{ freshness_threshold }}
{%- endmacro %}