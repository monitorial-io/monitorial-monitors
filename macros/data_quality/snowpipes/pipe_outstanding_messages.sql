{% macro pipe_outstanding_messages(pipe, max_outstanding_messages=1) -%}
select
    '{{ pipe }}' as pipe,
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastReceivedMessageTimestamp::timestamp as last_received_message_timestamp,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):pendingFileCount::number(38,0) as pending_file_count,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):numOutstandingMessagesOnChannel::number(38,0) as num_outstanding_messages_on_channel
where pending_file_count >= {{ max_outstanding_messages }} or num_outstanding_messages_on_channel > {{ max_outstanding_messages }}
{%- endmacro %}