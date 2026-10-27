{# Lets Elementary record test results (required from dbt 1.8 onwards). #}
{% materialization test, default %}
  {{ return(elementary.materialization_test_default()) }}
{% endmaterialization %}
