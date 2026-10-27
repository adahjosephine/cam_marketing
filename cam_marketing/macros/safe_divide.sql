{#
  Divides without failing on zero. Returns NULL when the denominator is 0
  or NULL, because a rate such as CTR has no meaning without impressions.
  Usage: {{ safe_divide('clicks', 'impressions') }}
#}
{% macro safe_divide(numerator, denominator) -%}
    ({{ numerator }}) / nullif(({{ denominator }}), 0)
{%- endmacro %}
