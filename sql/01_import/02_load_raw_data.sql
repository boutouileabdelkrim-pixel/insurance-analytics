-- ============================================================
-- 01_import / 02_load_raw_data.sql
-- Import des CSV dans les tables raw via COPY
-- Phase 4 — Importation des données
-- ============================================================
--
-- Prérequis :
--   1. Les fichiers CSV doivent être accessibles par l'utilisateur
--      système 'postgres'. Copier les fichiers dans /tmp/raw_import/
--      puis : sudo chown postgres:postgres /tmp/raw_import/*.csv
--   2. Se connecter à la base : psql -d insurance_analytics

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
