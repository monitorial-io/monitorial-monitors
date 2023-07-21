{% macro pipe_status(pipe, pipe_status_exception_list=["RUNNING", "PAUSED", "STOPPED_CLONED"]) -%}
select
    '{{ pipe }}' as pipe,
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):pendingFileCount::number(38,0) as pending_file_count,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):numOutstandingMessagesOnChannel::number(38,0) as num_outstanding_messages_on_channel,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):executionState::text as execution_state
where execution_state not in ({%- for state in pipe_status_exception_list -%}'{{state}}'{% if not loop.last %},{% endif %}{% endfor %})
{%- endmacro %}