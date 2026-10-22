-- 01_create_dev_catalog.sql
-- Purpose: create the personal development space that dbt's `dev` target builds into.
-- Where to run: Databricks SQL Editor, once, before the first dbt run.
-- Safe to re-run: IF NOT EXISTS means it won't fail if these already exist.

CREATE CATALOG IF NOT EXISTS cam_dev;
CREATE SCHEMA IF NOT EXISTS cam_dev.dbt_josephine;