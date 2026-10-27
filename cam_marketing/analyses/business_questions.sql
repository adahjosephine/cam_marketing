-- Example queries answering the brief's business questions.
-- Compile with: uv run dbt compile --select business_questions
-- then copy a query from target/compiled/ into the Databricks SQL Editor.
-- Rates are always calculated from totals (sum first, then divide).

-- 1. Total spend, and spend by platform (EUR)
select
    platform,
    sum(spend_eur)                                     as spend_eur,
    sum(impressions)                                   as impressions,
    sum(clicks)                                        as clicks,
    sum(clicks) / nullif(sum(impressions), 0)          as ctr,
    sum(spend_eur) / nullif(sum(clicks), 0)            as cpc_eur,
    sum(spend_eur) * 1000 / nullif(sum(impressions), 0) as cpm_eur
from {{ ref('fct_ad_performance_daily') }}
group by rollup (platform)   -- the NULL platform row is the grand total
order by platform;

-- 2. Spend, impressions and clicks by campaign (top 10 by impressions)
-- select
--     platform, campaign_name,
--     sum(spend_eur) as spend_eur, sum(impressions) as impressions, sum(clicks) as clicks,
--     sum(clicks) / nullif(sum(impressions), 0) as ctr
-- from {{ ref('agg_campaign_performance_daily') }}
-- group by platform, campaign_name
-- order by impressions desc
-- limit 10;

-- 3. Campaign performance over time (monthly)
-- select
--     platform, campaign_name, date_trunc('month', ad_date) as month,
--     sum(spend_eur) as spend_eur, sum(clicks) as clicks,
--     sum(spend_eur) / nullif(sum(clicks), 0) as cpc_eur
-- from {{ ref('agg_campaign_performance_daily') }}
-- group by all
-- order by month;
