-- 03_load_raw_data.sql
-- Purpose: record how the source CSV files were loaded into cam_raw_bronze.
-- Where to run: Databricks SQL Editor.
--
-- Facebook: loaded with read_files from a volume, every column as STRING.
-- Snapchat: loaded through the Databricks upload screen
--           (+ New > Add or upload data > Create or modify table),
--           with default settings, so Databricks chose the column types.
-- Either way, all type conversion is done in the dbt staging models.


-- =========================================================================
-- Volume (folder) holding the uploaded Facebook CSV files
-- =========================================================================

CREATE VOLUME IF NOT EXISTS cam_raw_bronze.facebook.landing;


-- =========================================================================
-- Facebook tables (run after uploading the 5 CSVs to the volume)
-- =========================================================================

CREATE OR REPLACE TABLE cam_raw_bronze.facebook.ads_stats AS
SELECT * FROM read_files(
  '/Volumes/cam_raw_bronze/facebook/landing/ads_stats.csv',
  format => 'csv', header => true,
  schema => 'ad_id STRING, account_id STRING, ad_spend STRING,
             ad_impressions STRING, ad_clicks STRING, ad_date STRING'
);

CREATE OR REPLACE TABLE cam_raw_bronze.facebook.ads AS
SELECT * FROM read_files(
  '/Volumes/cam_raw_bronze/facebook/landing/new_ads_de_randomized.csv',
  format => 'csv', header => true,
  schema => 'ad_id STRING, campaign_id STRING, ad_group_id STRING,
             account_id STRING, ad_name STRING, ad_status STRING,
             ad_updated_at STRING'
);

CREATE OR REPLACE TABLE cam_raw_bronze.facebook.ad_groups AS
SELECT * FROM read_files(
  '/Volumes/cam_raw_bronze/facebook/landing/new_adgroup_de_randomized.csv',
  format => 'csv', header => true,
  schema => 'ad_group_id STRING, ad_group_name STRING, ad_group_updated_at STRING'
);

CREATE OR REPLACE TABLE cam_raw_bronze.facebook.campaigns AS
SELECT * FROM read_files(
  '/Volumes/cam_raw_bronze/facebook/landing/new_campaign_de_randomized.csv',
  format => 'csv', header => true,
  schema => 'campaign_id STRING, campaign_name STRING, campaign_updated_at STRING'
);

-- The source file name has three c's ("acccount"); kept as received.
CREATE OR REPLACE TABLE cam_raw_bronze.facebook.accounts AS
SELECT * FROM read_files(
  '/Volumes/cam_raw_bronze/facebook/landing/new_acccount_de_randomized.csv',
  format => 'csv', header => true,
  schema => 'account_id STRING, account_name STRING, ad_currency_code STRING,
             account_created_at STRING, account_updated_at STRING'
);


-- =========================================================================
-- Snapchat tables: loaded through the upload screen (no SQL)
-- =========================================================================
--   snapchat_ads_stats.csv                               -> cam_raw_bronze.snapchat.ads_stats
--   snapchat_ads_ad_history_new_ad_names.csv             -> cam_raw_bronze.snapchat.ads
--   snapchat_ads_adgroup_history_new_ad_group_names.csv  -> cam_raw_bronze.snapchat.ad_groups
--   snapchat_ads_campaign_history_new_campaign_names.csv -> cam_raw_bronze.snapchat.campaigns

-- Fix: the first upload loaded all four Snapchat files into snapchat.ads.
  -- Corrected by keeping only the ads file's rows and columns:
  -- CREATE OR REPLACE TABLE cam_raw_bronze.snapchat.ads AS
  -- SELECT ad_id, ad_group_id, ad_name, ad_detail_updated_at
  -- FROM cam_raw_bronze.snapchat.ads WHERE ad_id IS NOT NULL;
-- =========================================================================
-- Check: both should list their tables
-- =========================================================================

SHOW TABLES IN cam_raw_bronze.facebook;
SHOW TABLES IN cam_raw_bronze.snapchat;