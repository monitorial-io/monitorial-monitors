{% macro rbar_detection(query_types = ["INSERT","UPDATE","DELETE","MERGE"], query_count_greater_than = 10, time_filter=1440) -%}

select 
    query_text, 
    session_id, 
    user_name, 
    count(*) as query_count
from 
    snowflake.account_usage.query_history
where 
    warehouse_size is not null
    and   query_type in (
        {%- for query_type in query_types -%}
        '{{ query_type }}'
        {% if not loop.last %},{% endif %}
        {% endfor %}
        )
    and rows_produced = 1
    and end_time >= dateadd(minutes, -{{ time_filter }}, current_timestamp)
group by 
    query_text, 
    session_id, 
    user_name
having 
    count(*) > {{ query_count_greater_than }}
order by 
    user_name desc
{%- endmacro %}