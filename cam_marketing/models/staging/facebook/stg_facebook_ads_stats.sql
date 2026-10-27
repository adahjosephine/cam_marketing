-- stg_facebook_ads_stats
-- Source: cam_raw_bronze.facebook.ads_stats
-- Grain:  one row per ad per day
-- Does:   converts each column from text to its correct type and turns the
--         text 'null' in impressions/clicks into 0 (see decisions.md).
--         No joins and no business logic.

with source as (

    select * from {{ source('facebook', 'ads_stats') }}

),

renamed as (

    select
        cast(ad_id as string)                              as ad_id,
        cast(account_id as string)                         as account_id,
        cast(ad_date as date)                              as ad_date,
        cast(ad_spend as decimal(18, 6))                   as ad_spend,

        -- try_cast turns the text 'null' into a real NULL; coalesce makes it 0
        coalesce(try_cast(ad_impressions as bigint), 0)    as ad_impressions,
        coalesce(try_cast(ad_clicks as bigint), 0)         as ad_clicks,

        -- flags so analysts can tell a reported 0 from an assumed 0
        try_cast(ad_impressions as bigint) is not null     as is_impressions_reported,
        try_cast(ad_clicks as bigint) is not null          as is_clicks_reported

    from source

)

select * from renamed
