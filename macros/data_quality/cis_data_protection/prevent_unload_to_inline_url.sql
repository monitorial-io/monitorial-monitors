{% macro prevent_unload_to_inline_url() -%}
with scanner_entities as (
    select
        scanner_id,
        end_timestamp,
        array_agg(f.value:entity_name::varchar) as entity_names
    from
        snowflake.trust_center.findings,
        lateral flatten(input => at_risk_entities) as f
    group by scanner_id, end_timestamp
)

select
    snowflake.trust_center.findings.scanner_name,
    snowflake.trust_center.time_series_daily_findings.scanner_id,
    snowflake.trust_center.time_series_daily_findings.end_timestamp
        as last_scan_time,
    snowflake.trust_center.findings.total_at_risk_count,
    snowflake.trust_center.findings.scanner_type,
    snowflake.trust_center.findings.suggested_action,
    snowflake.trust_center.findings.impact,
    snowflake.trust_center.findings.severity,
    ARRAY_TO_STRING(scanner_entities.entity_names, ', ') as entity_names
from
    snowflake.trust_center.time_series_daily_findings
inner join snowflake.trust_center.findings
    on
        snowflake.trust_center.time_series_daily_findings.scanner_id
        = snowflake.trust_center.findings.scanner_id
        and snowflake.trust_center.time_series_daily_findings.end_timestamp = snowflake.trust_center.findings.end_timestamp
inner join scanner_entities
    on
        snowflake.trust_center.time_series_daily_findings.scanner_id
        = scanner_entities.scanner_id
        and snowflake.trust_center.time_series_daily_findings.end_timestamp = scanner_entities.end_timestamp
where
    snowflake.trust_center.time_series_daily_findings.scanner_id = 'CIS_BENCHMARKS_CIS4_8'
{%- endmacro %}
