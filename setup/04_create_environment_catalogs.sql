-- 04_create_environment_catalogs.sql
-- Purpose: create one catalog per environment that dbt builds into.
--   cam_dev   development (created in 01_create_dev_catalog.sql)
--   cam_ci    CI builds on pull requests (one throwaway schema per PR)
--   cam_prod  production, built only by the service principal
-- dbt creates the schemas inside them (staging, intermediate, marts...)
-- automatically on the first run.
-- Where to run: Databricks SQL Editor, once, as yourself.
-- Safe to re-run: IF NOT EXISTS.

CREATE CATALOG IF NOT EXISTS cam_ci;
CREATE CATALOG IF NOT EXISTS cam_prod;
