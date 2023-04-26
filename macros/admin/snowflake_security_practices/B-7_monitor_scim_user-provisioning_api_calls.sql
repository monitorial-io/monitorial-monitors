{% macro scim_api(number_requests, time_filter=1440) -%}
select *
from
    table(snowflake.information_schema.rest_event_history(
        'scim',
        --change units and/or number
        dateadd('minutes', -{{ time_filter }}, current_timestamp),
        current_timestamp(),
        {{ number_requests }}
    ))
order by event_timestamp desc
{%- endmacro %}
