select *
from
    table(snowflake.information_schema.rest_event_history(
        'scim',
        --change units and/or number
        dateadd('minutes', -5, current_timestamp()),
        current_timestamp(),
        200
    ))
order by event_timestamp desc;