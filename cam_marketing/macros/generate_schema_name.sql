{#
  Decides which schema each model is built in.
  - No custom schema set         -> the target's base schema
  - prod                         -> the custom schema on its own (staging, marts)
  - dev / ci                     -> base schema + custom schema
                                    (dbt_josephine_staging, dbt_ci_pr_7_marts)
  Personal prefixes stop developers overwriting each other; production
  has one owner, so it gets clean names.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
