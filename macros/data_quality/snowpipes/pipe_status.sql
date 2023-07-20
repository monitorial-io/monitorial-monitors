{% macro pipe_status(status_exception_list=["RUNNING", "PAUSED", "STOPPED_CLONED"], pipe) -%}
select
    datediff(minute,parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):lastIngestedTimestamp::timestamp,current_timestamp) as minutes_since_last_data,
    parse_json(SYSTEM$PIPE_STATUS('{{ pipe }}')):executionState::text as executionState
where executionState not in ({%- for state in status_exception_list -%}'{{state}}'{% if not loop.last %},{% endif %}{% endfor %})
{%- endmacro %}