-- 05_grants.sql
-- Purpose: give each identity only the access it needs (least privilege).
-- Where to run: Databricks SQL Editor, as the catalog owner (you).
--
-- BEFORE RUNNING, replace:
--  <service-principal-application-id> -- with your service principal's                                     Application ID (a UUID)
--   <your-email>                   -- with your Databricks login email
--
-- Also, in the Databricks UI: SQL Warehouses -> your warehouse ->
-- Permissions -> add the service principal with "Can use".


-- -------------------------------------------------------------------------
-- Production service principal
-- -------------------------------------------------------------------------

-- Raw data: READ ONLY. dbt reads sources but can never change them.
GRANT USE CATALOG ON CATALOG cam_raw_bronze TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;
GRANT USE SCHEMA  ON CATALOG cam_raw_bronze TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;
GRANT SELECT      ON CATALOG cam_raw_bronze TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;

-- Production catalog: may create schemas and tables, and read/write them.
GRANT USE CATALOG   ON CATALOG cam_prod TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;
GRANT USE SCHEMA    ON CATALOG cam_prod TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;
GRANT CREATE SCHEMA ON CATALOG cam_prod TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;
GRANT CREATE TABLE  ON CATALOG cam_prod TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;
GRANT SELECT        ON CATALOG cam_prod TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;
GRANT MODIFY        ON CATALOG cam_prod TO `b6ed2c3c-fa0e-43c8-a2ba-d1d621ee7298`;

-- Not granted on purpose: CREATE CATALOG on the metastore. The catalogs are
-- created once by a person (04_create_environment_catalogs.sql), so the
-- service principal does not need that power.


-- -------------------------------------------------------------------------
-- CI (runs with your personal access token, as in the brief)
-- You own cam_ci because you created it; these grants make the access explicit.
-- -------------------------------------------------------------------------

GRANT USE CATALOG   ON CATALOG cam_ci TO `josephine.adah6@gmail.com`;
GRANT USE SCHEMA    ON CATALOG cam_ci TO `josephine.adah6@gmail.com`;
GRANT CREATE SCHEMA ON CATALOG cam_ci TO `josephine.adah6@gmail.com`;
GRANT CREATE TABLE  ON CATALOG cam_ci TO `josephine.adah6@gmail.com`;
GRANT SELECT        ON CATALOG cam_ci TO `josephine.adah6@gmail.com`;
GRANT MODIFY        ON CATALOG cam_ci TO `josephine.adah6@gmail.com`;


-- -------------------------------------------------------------------------
-- Check what was granted
-- -------------------------------------------------------------------------
SHOW GRANTS ON CATALOG cam_raw_bronze;
SHOW GRANTS ON CATALOG cam_prod;
SHOW GRANTS ON CATALOG cam_ci;
