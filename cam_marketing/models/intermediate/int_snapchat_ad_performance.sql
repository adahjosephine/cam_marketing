-- int_snapchat_ad_performance
-- Grain: one row per ad per day (same as Facebook)
-- Does:  1. sums the country-level stats to ad x day, so both platforms share
--           one grain (see decisions.md, "Unified model grain")
--        2. attaches names by climbing: ad -> ad group -> campaign.
--        Snapchat has no account table, so account_name is NULL.
--        Country detail remains available in stg_snapchat_ads_stats.

with stats_by_country as (
    select * from {{ ref('stg_snapchat_ads_stats') }}
),

stats as (

    select
        ad_id,
        ad_date,
        currency_code,
        sum(ad_spend)                     as ad_spend,
        sum(ad_impressions)               as ad_impressions,
        sum(ad_clicks)                    as ad_clicks,
        -- reported only if every country row for that ad-day was reported
        bool_and(is_impressions_reported) as is_impressions_reported,
        bool_and(is_clicks_reported)      as is_clicks_reported
    from stats_by_country
    group by ad_id, ad_date, currency_code

),

ads as (
    select * from {{ ref('stg_snapchat_ads') }}
),

ad_groups as (
    select * from {{ ref('stg_snapchat_ad_groups') }}
),

campaigns as (
    select * from {{ ref('stg_snapchat_campaigns') }}
)

select
    'snapchat'                  as platform,
    stats.ad_date,
    campaigns.account_id,
    cast(null as string)        as account_name,
    ad_groups.campaign_id,
    campaigns.campaign_name,
    ads.ad_group_id,
    ad_groups.ad_group_name,
    stats.ad_id,
    ads.ad_name,
    stats.currency_code,
    stats.ad_spend,
    stats.ad_impressions,
    stats.ad_clicks,
    stats.is_impressions_reported,
    stats.is_clicks_reported

from stats
left join ads       on stats.ad_id = ads.ad_id
left join ad_groups on ads.ad_group_id = ad_groups.ad_group_id
left join campaigns on ad_groups.campaign_id = campaigns.campaign_id
