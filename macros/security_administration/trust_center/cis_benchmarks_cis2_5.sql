{% macro cis_benchmarks_cis2_5() -%}
select
  scanner_id,
  end_timestamp as last_run_timestamp,
  case 
    when critical_risk_count > 0 then 'critical'
    when high_risk_count > 0 then 'high'
    when medium_risk_count > 0 then 'medium'
    when low_risk_count > 0 then 'low'
  end as severity
from
  snowflake.trust_center.time_series_daily_findings
where
  scanner_id = 'cis_benchmarks_cis2_5' and 
  none_risk_count != 1 and
  (critical_risk_count + high_risk_count + medium_risk_count + low_risk_count) > 0
{%- endmacro %}
