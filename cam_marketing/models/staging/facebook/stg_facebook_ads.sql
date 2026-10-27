-- stg_facebook_ads
-- Source: cam_raw_bronze.facebook.ads
-- Grain:  one row per ad
-- Does:   types and tidies columns. This table links each ad to its
--         ad group, campaign and account.

with source as (

    select * from {{ source('facebook', 'ads') }}

),

renamed as (

    select
        cast(ad_id as string)                  as ad_id,
        cast(ad_group_id as string)            as ad_group_id,
        cast(campaign_id as string)            as campaign_id,
        cast(account_id as string)             as account_id,
        cast(ad_name as string)                as ad_name,
        lower(cast(ad_status as string))       as ad_status,
        try_cast(ad_updated_at as timestamp)   as ad_updated_at

    from source

)

select * from renamed
