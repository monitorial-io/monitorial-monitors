{% macro scim_api_calls(number_requests, time_filter=1440) -%}
select *
from
    table(snowflake.information_schema.rest_event_history(
        'scim',
        dateadd('minutes', -{{ time_filter }}, current_timestamp),
        current_timestamp(),
        {{ number_requests }}
    ))
order by event_timestamp desc
{%- endmacro %}
