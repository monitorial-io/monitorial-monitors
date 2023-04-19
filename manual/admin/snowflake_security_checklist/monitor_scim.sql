SELECT *
FROM
    TABLE(snowflake.information_schema.rest_event_history(
        'scim',
        --change units and/or number
        DATEADD('minutes', -5, CURRENT_TIMESTAMP()),
        CURRENT_TIMESTAMP(),
        200
    ))
ORDER BY event_timestamp DESC;