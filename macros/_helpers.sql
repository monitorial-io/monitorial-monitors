{#
  Shared helper: Warehouse size to node count mapping.
  Used by warehouse_oversizing and warehouse_scaling_efficiency macros.
  Centralised here so threshold/size changes only need updating in one place.
#}
{% macro _node_mapping() -%}
SELECT 'X-Small' AS size, 1 AS nodes UNION ALL
SELECT 'Small', 2 UNION ALL SELECT 'Medium', 4 UNION ALL
SELECT 'Large', 8 UNION ALL SELECT 'X-Large', 16 UNION ALL
SELECT '2X-Large', 32 UNION ALL SELECT '3X-Large', 64 UNION ALL
SELECT '4X-Large', 128 UNION ALL SELECT '5X-Large', 256 UNION ALL
SELECT '6X-Large', 512
{%- endmacro %}

{#
  Shared helper: Filter predicate for sensitive governance tags.
  Used by masking_policy_coverage_gap, row_access_policy_gap, downstream_lineage_gaps,
  and untagged_sensitive_columns macros.
  Add or remove patterns here to adjust what is considered "sensitive" across all monitors.
#}
{% macro _sensitive_tag_filter(tag_name_col='tr.tag_name', tag_value_col='tr.tag_value') -%}
(
    {{ tag_name_col }} ILIKE '%SENSITIVE%'
    OR {{ tag_name_col }} ILIKE '%PII%'
    OR {{ tag_name_col }} ILIKE '%PHI%'
    OR {{ tag_name_col }} ILIKE '%PCI%'
    OR {{ tag_name_col }} ILIKE '%GDPR%'
    OR {{ tag_name_col }} ILIKE '%PRIVACY%'
    OR {{ tag_value_col }} ILIKE '%SENSITIVE%'
    OR {{ tag_value_col }} ILIKE '%IDENTIFIER%'
)
{%- endmacro %}
