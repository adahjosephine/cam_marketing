-- stg_snapchat_campaigns
-- Source: cam_raw_bronze.snapchat.campaigns
-- Grain:  one row per campaign

with source as (

    select * from {{ source('snapchat', 'campaigns') }}

),

renamed as (

    select
        cast(campaign_id as string)     as campaign_id,
        cast(account_id as string)      as account_id,
        cast(campaign_name as string)   as campaign_name

    from source

)

select * from renamed
