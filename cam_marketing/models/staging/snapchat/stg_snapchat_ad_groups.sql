-- stg_snapchat_ad_groups
-- Source: cam_raw_bronze.snapchat.ad_groups
-- Grain:  one row per ad group (the latest version)
-- Does:   the raw table holds history: 3 ad groups appear twice with
--         different updated_at values. Joining to it as-is would count their
--         spend twice, so only the most recent version is kept.

with source as (

    select * from {{ source('snapchat', 'ad_groups') }}

),

renamed as (

    select
        cast(ad_group_id as string)                  as ad_group_id,
        cast(campaign_id as string)                  as campaign_id,
        cast(ad_group_name as string)                as ad_group_name,
        try_cast(ad_group_updated_at as timestamp)   as ad_group_updated_at

    from source

),

latest_version as (

    select *
    from renamed
    -- number each ad group's versions from newest (1) to oldest; keep 1
    qualify row_number() over (
        partition by ad_group_id
        order by ad_group_updated_at desc
    ) = 1

)

select * from latest_version
