-- 02_create_raw_catalog.sql
-- Purpose: create the raw (bronze) catalog that holds the source data
--          exactly as received. dbt reads from it but never writes to it.
-- Where to run: Databricks SQL Editor, once, before loading the CSV files.
-- Safe to re-run: IF NOT EXISTS means it won't fail if these already exist.

CREATE CATALOG IF NOT EXISTS cam_raw_bronze;

-- One schema per source system, so each platform's tables stay together.
CREATE SCHEMA IF NOT EXISTS cam_raw_bronze.facebook;
CREATE SCHEMA IF NOT EXISTS cam_raw_bronze.snapchat;