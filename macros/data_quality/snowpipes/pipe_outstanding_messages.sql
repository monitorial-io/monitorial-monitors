{% macro pipe_outstanding_messages(pipe, max_outstanding_messages=1) -%}
select
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):pendingFileCount::number(38,0) as pendingFileCount,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):numOutstandingMessagesOnChannel::number(38,0) as numOutstandingMessagesOnChannel
where outstaning_count >= {{ max_outstanding_messages }}
{%- endmacro %}