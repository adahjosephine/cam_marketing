-- fct_ad_performance_daily
-- Grain: one row per platform per ad per day
-- The unified marketing model. Combines both platforms, converts spend to EUR,
-- and carries the ad, ad group, campaign and account names, so analysts can
-- answer questions without further joins.
--
-- Incremental: after the first build, each run only reprocesses the last
-- 3 days per platform (late-arriving data) and merges them in by key.
-- The look-back is per platform because the platforms cover different periods.

{{
    config(
        materialized='incremental',
        unique_key='ad_performance_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

with unioned as (

    select * from {{ ref('int_facebook_ad_performance') }}
    union all
    select * from {{ ref('int_snapchat_ad_performance') }}

),

exchange_rates as (
    select * from {{ ref('exchange_rates') }}
),

{% if is_incremental() %}
watermarks as (
    -- the latest date already loaded, for each platform
    select platform, max(ad_date) as max_ad_date
    from {{ this }}
    group by platform
),
{% endif %}

final as (

    select
        -- surrogate key: one value per platform + ad + day
        md5(concat_ws('|', u.platform, u.ad_id, cast(u.ad_date as string)))
                                                    as ad_performance_id,
        u.platform,
        u.ad_date,
        u.account_id,
        u.account_name,
        u.campaign_id,
        u.campaign_name,
        u.ad_group_id,
        u.ad_group_name,
        u.ad_id,
        u.ad_name,

        -- spend in the original currency, and converted to EUR
        u.currency_code,
        u.ad_spend                                  as spend_local,
        cast(u.ad_spend / fx.units_per_eur as decimal(18, 6))
                                                    as spend_eur,
        u.ad_impressions                            as impressions,
        u.ad_clicks                                 as clicks,
        u.is_impressions_reported,
        u.is_clicks_reported,

        -- row-level rates (NULL when the denominator is 0).
        -- To compare campaigns or platforms, SUM the parts first and then
        -- divide; never average these columns.
        {{ safe_divide('u.ad_clicks', 'u.ad_impressions') }}       as ctr,
        {{ safe_divide('u.ad_spend / fx.units_per_eur', 'u.ad_clicks') }}
                                                    as cpc_eur,
        {{ safe_divide('u.ad_spend / fx.units_per_eur * 1000', 'u.ad_impressions') }}
                                                    as cpm_eur

    from unioned as u
    left join exchange_rates as fx
        on  u.currency_code = fx.currency_code
        and year(u.ad_date) = fx.rate_year

    {% if is_incremental() %}
    left join watermarks as w
        on u.platform = w.platform
    where w.max_ad_date is null
       or u.ad_date >= date_sub(w.max_ad_date, 3)
    {% endif %}

)

select * from final
