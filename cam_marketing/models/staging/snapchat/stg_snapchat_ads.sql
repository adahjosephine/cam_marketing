-- stg_snapchat_ads
-- Source: cam_raw_bronze.snapchat.ads
-- Grain:  one row per ad

with source as (

    select * from {{ source('snapchat', 'ads') }}

),

renamed as (

    select
        cast(ad_id as string)                         as ad_id,
        cast(ad_group_id as string)                   as ad_group_id,
        cast(ad_name as string)                       as ad_name,
        try_cast(ad_detail_updated_at as timestamp)   as ad_updated_at

    from source

)

select * from renamed
