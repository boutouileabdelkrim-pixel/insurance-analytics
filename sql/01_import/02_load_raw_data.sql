-- ============================================================
-- 01_import / 02_load_raw_data.sql
-- Import CSV files into raw tables via COPY
-- Phase 4 — Data import
-- ============================================================
--
-- Prerequisites:
--   1. CSV files must be accessible by the 'postgres' system user.
--      Copy them to /tmp/raw_import/ then:
--        sudo chown postgres:postgres /tmp/raw_import/*.csv
--   2. Connect to the database: psql -d insurance_analytics
COPY raw.contracts
FROM '/tmp/raw_import/contracts.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

COPY raw.claims
FROM '/tmp/raw_import/claims.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

COPY raw.vehicles
FROM '/tmp/raw_import/vehicles.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

-- Vérification
SELECT 'contracts' AS table_name, COUNT(*) FROM raw.contracts
UNION ALL
SELECT 'claims',    COUNT(*) FROM raw.claims
UNION ALL
SELECT 'vehicles',  COUNT(*) FROM raw.vehicles;
