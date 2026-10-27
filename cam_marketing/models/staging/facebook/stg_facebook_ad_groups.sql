-- stg_facebook_ad_groups
-- Source: cam_raw_bronze.facebook.ad_groups
-- Grain:  one row per ad group

with source as (

    select * from {{ source('facebook', 'ad_groups') }}

),

renamed as (

    select
        cast(ad_group_id as string)                  as ad_group_id,
        cast(ad_group_name as string)                as ad_group_name,
        try_cast(ad_group_updated_at as timestamp)   as ad_group_updated_at

    from source

)

select * from renamed
