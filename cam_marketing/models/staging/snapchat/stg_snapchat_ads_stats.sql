-- stg_snapchat_ads_stats
-- Source: cam_raw_bronze.snapchat.ads_stats
-- Grain:  one row per ad per day per country
-- Does:   renames ad_detail_id to ad_id (it matches the ad_id in the ads table),
--         converts types, and turns missing impressions/clicks into 0.
--         try_cast is used throughout because this table was loaded with
--         Databricks' guessed types.

with source as (

    select * from {{ source('snapchat', 'ads_stats') }}

),

renamed as (

    select
        cast(ad_detail_id as string)                       as ad_id,
        upper(cast(ad_country as string))                  as country_code,
        upper(cast(ad_currency_code as string))            as currency_code,
        try_cast(ad_date as date)                          as ad_date,
        try_cast(ad_spend as decimal(18, 6))               as ad_spend,

        coalesce(try_cast(ad_impressions as bigint), 0)    as ad_impressions,
        coalesce(try_cast(ad_clicks as bigint), 0)         as ad_clicks,

        try_cast(ad_impressions as bigint) is not null     as is_impressions_reported,
        try_cast(ad_clicks as bigint) is not null          as is_clicks_reported

    from source

)

select * from renamed
