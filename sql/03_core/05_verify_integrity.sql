-- ============================================================
-- 03_core / 05_verify_integrity.sql
-- Verify referential integrity and constraints
-- Phase 9 — Table and Constraint Creation
-- ============================================================

-- 1. Row counts
SELECT 'clients'   AS table_name, COUNT(*) FROM core.clients
UNION ALL SELECT 'contracts', COUNT(*) FROM core.contracts
UNION ALL SELECT 'claims',    COUNT(*) FROM core.claims
UNION ALL SELECT 'vehicles',  COUNT(*) FROM core.vehicles;

-- 2. Orphan checks
SELECT 'contracts -> clients'  AS relation, COUNT(*) AS orphans
FROM core.contracts c LEFT JOIN core.clients cl ON cl.client_id = c.client_id WHERE cl.client_id IS NULL
UNION ALL
SELECT 'claims -> contracts', COUNT(*)
FROM core.claims c LEFT JOIN core.contracts ct ON ct.contract_id = c.contract_id WHERE ct.contract_id IS NULL
UNION ALL
SELECT 'vehicles -> contracts', COUNT(*)
FROM core.vehicles v LEFT JOIN core.contracts ct ON ct.contract_id = v.contract_id WHERE ct.contract_id IS NULL;

-- 3. Foreign key counts (must all be > 0)
SELECT 'contracts.product_id'  AS fk, COUNT(*) AS null_fk FROM core.contracts WHERE product_id  IS NULL
UNION ALL SELECT 'contracts.channel_id', COUNT(*) FROM core.contracts WHERE channel_id  IS NULL
UNION ALL SELECT 'contracts.city_id',    COUNT(*) FROM core.contracts WHERE city_id     IS NULL
UNION ALL SELECT 'contracts.status_id',  COUNT(*) FROM core.contracts WHERE status_id   IS NULL
UNION ALL SELECT 'claims.claim_type_id', COUNT(*) FROM core.claims    WHERE claim_type_id IS NULL
UNION ALL SELECT 'claims.status_id',     COUNT(*) FROM core.claims    WHERE status_id    IS NULL;

-- 4. Constraint check results
SELECT 'invalid_gender'   AS check_name, COUNT(*) FROM core.clients WHERE gender NOT IN ('M','F') AND gender IS NOT NULL
UNION ALL SELECT 'invalid_age',     COUNT(*) FROM core.clients WHERE client_age < 0 OR client_age > 120
UNION ALL SELECT 'negative_premium', COUNT(*) FROM core.contracts WHERE annual_premium_eur < 0
UNION ALL SELECT 'dates_inverted',   COUNT(*) FROM core.contracts WHERE start_date > end_date;

-- 5. Sample data
SELECT contract_id, client_id, product_id, channel_id, city_id, status_id, annual_premium_eur
FROM core.contracts LIMIT 5;
