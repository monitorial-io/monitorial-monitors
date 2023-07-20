{% macro pipe_channel_error(pipe) -%}

select
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):channelErrorMessage::text as channelErrorMessage,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):executionState::text as executionState,
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data
where channelErrorMessage is not null
{%- endmacro %}