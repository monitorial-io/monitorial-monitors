{% macro pipe_channel_error(pipe) -%}

select
    '{{ pipe }}' as pipe,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):channelErrorMessage::text as channel_error_message,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):executionState::text as execution_state,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastReceivedMessageTimestamp::timestamp as last_received_message_timestamp,
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data
where channel_error_message is not null
{%- endmacro %}