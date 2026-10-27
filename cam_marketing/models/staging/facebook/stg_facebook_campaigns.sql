-- stg_facebook_campaigns
-- Source: cam_raw_bronze.facebook.campaigns
-- Grain:  one row per campaign

with source as (

    select * from {{ source('facebook', 'campaigns') }}

),

renamed as (

    select
        cast(campaign_id as string)                  as campaign_id,
        cast(campaign_name as string)                as campaign_name,
        try_cast(campaign_updated_at as timestamp)   as campaign_updated_at

    from source

)

select * from renamed
