-- int_facebook_ad_performance
-- Grain: one row per ad per day
-- Does:  attaches names and currency to each Facebook stats row by climbing
--        the hierarchy: stats -> ad -> ad group / campaign, and stats -> account.
--        Left joins keep every stats row, so no spend is lost if a link is missing.

with stats as (
    select * from {{ ref('stg_facebook_ads_stats') }}
),

ads as (
    select * from {{ ref('stg_facebook_ads') }}
),

ad_groups as (
    select * from {{ ref('stg_facebook_ad_groups') }}
),

campaigns as (
    select * from {{ ref('stg_facebook_campaigns') }}
),

accounts as (
    select * from {{ ref('stg_facebook_accounts') }}
)

select
    'facebook'                  as platform,
    stats.ad_date,
    stats.account_id,
    accounts.account_name,
    ads.campaign_id,
    campaigns.campaign_name,
    ads.ad_group_id,
    ad_groups.ad_group_name,
    stats.ad_id,
    ads.ad_name,
    accounts.currency_code,
    stats.ad_spend,
    stats.ad_impressions,
    stats.ad_clicks,
    stats.is_impressions_reported,
    stats.is_clicks_reported

from stats
left join ads       on stats.ad_id = ads.ad_id
left join ad_groups on ads.ad_group_id = ad_groups.ad_group_id
left join campaigns on ads.campaign_id = campaigns.campaign_id
left join accounts  on stats.account_id = accounts.account_id
