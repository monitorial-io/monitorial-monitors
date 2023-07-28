{% macro pipe_freshness(pipe, freshness_threshold=5) -%}
select
    '{{ pipe }}' as pipe,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp as last_ingested_timestamp,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedFilePath::varchar as lastI_ingested_file_path,
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):pendingFileCount::number(38,0) as pending_file_count,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):numOutstandingMessagesOnChannel::number(38,0) as num_outstanding_messages_on_channel
where minutes_since_last_data > {{ freshness_threshold }}
{%- endmacro %}