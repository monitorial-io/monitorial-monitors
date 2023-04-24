{% macro scim_api(minutes,number_requests) -%}
select *
from
    table(snowflake.information_schema.rest_event_history(
        'scim',
        --change units and/or number
        dateadd('minutes', -{{ minutes }}, current_timestamp()),
        current_timestamp(),
        {{ number_requests }}
    ))
order by event_timestamp desc
{%- endmacro %}
