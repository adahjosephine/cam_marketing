-- stg_facebook_accounts
-- Source: cam_raw_bronze.facebook.accounts
-- Grain:  one row per ad account
-- Note:   Facebook stores the currency on the account, not on the stats rows.

with source as (

    select * from {{ source('facebook', 'accounts') }}

),

renamed as (

    select
        cast(account_id as string)                  as account_id,
        cast(account_name as string)                as account_name,
        upper(cast(ad_currency_code as string))     as currency_code,
        try_cast(account_created_at as timestamp)   as account_created_at,
        try_cast(account_updated_at as timestamp)   as account_updated_at

    from source

)

select * from renamed
