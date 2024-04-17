{% macro omnata_sync_incomplete(minutes=30) -%}

select
    sync_run.sync_id
    , sync.sync_name
    , sync_run.run_start_datetime
    , sync_run.health_state
    , sync_run.inbound_global_error_by_stream
from omnata_sync_engine.data_views.sync_run
inner join omnata_sync_engine.data_views.sync on sync.sync_id = sync_run.sync_id
where lower(sync_run.health_state) = 'incomplete'
and sync_run.run_start_datetime > dateadd(minute, -{{ minutes }}, current_timestamp())
and lower(sync.health_state) != 'healthy'

{%- endmacro %}