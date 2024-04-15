{% macro omnata_failures(minutes=30) -%}

select
    run.sync_id
    , sync.sync_name
    , run.run_start_datetime
    , run.health_state
    , run.inbound_global_error_by_stream
from omnata_sync_engine.data_views.sync_run run
inner join omnata_sync_engine.data_views.sync on sync.sync_id = run.sync_id
where lower(run.health_state) = 'failed'
and run.run_start_datetime > dateadd(minute, -{{ minutes }}, current_timestamp())
and lower(sync.health_state) != 'healthy'

{%- endmacro %}