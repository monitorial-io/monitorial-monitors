{% macro omnata_sync_failures(minutes=30) -%}

with data as (
    select
        sync_run.sync_id
        , sync_run.sync_run_id        
        , sync.sync_name
        , sync_run.run_start_datetime
        , sync_run.health_state
        , sync_run.global_error
        , message.KEY::string as stream_name
        , message.VALUE::string as error_message
    from omnata_sync_engine.data_views.sync_run
    inner join omnata_sync_engine.data_views.sync on sync.sync_id = sync_run.sync_id,
        lateral flatten(input => sync_run.inbound_global_error_by_stream, OUTER=> True) message
    where lower(sync_run.health_state) = 'failed'
    and sync_run.run_start_datetime > dateadd(minute, -{{ minutes }}, current_timestamp())
    and lower(sync.health_state) != 'healthy'
)
SELECT *
from data
pivot(
    max(error_message)
    for stream_name in (ANY)
)

{%- endmacro %}


