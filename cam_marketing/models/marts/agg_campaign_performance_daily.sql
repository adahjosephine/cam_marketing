-- agg_campaign_performance_daily
-- Grain: one row per platform per campaign per day
-- Campaign-level totals with CTR, CPC and CPM calculated correctly: the parts
-- are summed first, then divided. Built from fct_ad_performance_daily, so both
-- models always agree.

with fct as (
    select * from {{ ref('fct_ad_performance_daily') }}
),

totals as (

    select
        platform,
        ad_date,
        campaign_id,
        campaign_name,
        sum(spend_eur)      as spend_eur,
        sum(impressions)    as impressions,
        sum(clicks)         as clicks,
        count(distinct ad_id) as active_ads
    from fct
    group by platform, ad_date, campaign_id, campaign_name

)

select
    md5(concat_ws('|', platform, campaign_id, cast(ad_date as string)))
                                                         as campaign_day_id,
    platform,
    ad_date,
    campaign_id,
    campaign_name,
    spend_eur,
    impressions,
    clicks,
    active_ads,
    {{ safe_divide('clicks', 'impressions') }}           as ctr,
    {{ safe_divide('spend_eur', 'clicks') }}             as cpc_eur,
    {{ safe_divide('spend_eur * 1000', 'impressions') }} as cpm_eur

from totals
