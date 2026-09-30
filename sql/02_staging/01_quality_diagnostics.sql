-- ============================================================
-- 02_staging / 01_quality_diagnostics.sql
-- Data quality diagnostics on raw schema
-- Phase 6 — Data Quality and Cleaning
-- ============================================================
--
-- Purpose: identify all quality issues before any cleaning.
-- Run: psql -d insurance_analytics -f sql/02_staging/01_quality_diagnostics.sql
-- ============================================================


-- ------------------------------------------------------------
-- SECTION 1 — MISSING VALUES (completeness)
-- ------------------------------------------------------------

-- 1.1 Missing values in raw.contracts
SELECT 'contracts' AS table_name, 'contract_id'    AS column_name, COUNT(*) FILTER (WHERE contract_id    IS NULL OR contract_id    = '') AS nb_missing, COUNT(*) AS total FROM raw.contracts
UNION ALL SELECT 'contracts', 'client_id',    COUNT(*) FILTER (WHERE client_id    IS NULL OR client_id    = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'client_name',  COUNT(*) FILTER (WHERE client_name  IS NULL OR client_name  = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'product',      COUNT(*) FILTER (WHERE product      IS NULL OR product      = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'start_date',   COUNT(*) FILTER (WHERE start_date   IS NULL OR start_date   = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'end_date',     COUNT(*) FILTER (WHERE end_date     IS NULL OR end_date     = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'annual_premium', COUNT(*) FILTER (WHERE annual_premium IS NULL OR annual_premium = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'status',       COUNT(*) FILTER (WHERE status       IS NULL OR status       = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'city_postal',  COUNT(*) FILTER (WHERE city_postal  IS NULL OR city_postal  = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'risk_zone',    COUNT(*) FILTER (WHERE risk_zone    IS NULL OR risk_zone    = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'client_age',   COUNT(*) FILTER (WHERE client_age   IS NULL OR client_age   = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'channel',      COUNT(*) FILTER (WHERE channel      IS NULL OR channel      = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'csp',          COUNT(*) FILTER (WHERE csp          IS NULL OR csp          = ''), COUNT(*) FROM raw.contracts
UNION ALL SELECT 'contracts', 'gender',       COUNT(*) FILTER (WHERE gender       IS NULL OR gender       = ''), COUNT(*) FROM raw.contracts
ORDER BY table_name, column_name;

-- 1.2 Missing values in raw.claims
SELECT 'claims' AS table_name, 'claim_id'           AS column_name, COUNT(*) FILTER (WHERE claim_id           IS NULL OR claim_id           = '') AS nb_missing, COUNT(*) AS total FROM raw.claims
UNION ALL SELECT 'claims', 'contract_id',        COUNT(*) FILTER (WHERE contract_id        IS NULL OR contract_id        = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'occurrence_date',    COUNT(*) FILTER (WHERE occurrence_date    IS NULL OR occurrence_date    = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'declaration_date',   COUNT(*) FILTER (WHERE declaration_date   IS NULL OR declaration_date   = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'claim_type',         COUNT(*) FILTER (WHERE claim_type         IS NULL OR claim_type         = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'damage_amount',      COUNT(*) FILTER (WHERE damage_amount      IS NULL OR damage_amount      = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'indemnified_amount', COUNT(*) FILTER (WHERE indemnified_amount IS NULL OR indemnified_amount = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'status',             COUNT(*) FILTER (WHERE status             IS NULL OR status             = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'expert_id',          COUNT(*) FILTER (WHERE expert_id          IS NULL OR expert_id          = ''), COUNT(*) FROM raw.claims
UNION ALL SELECT 'claims', 'liability',          COUNT(*) FILTER (WHERE liability          IS NULL OR liability          = ''), COUNT(*) FROM raw.claims
ORDER BY table_name, column_name;

-- 1.3 Missing values in raw.vehicles
SELECT 'vehicles' AS table_name, 'contract_id'     AS column_name, COUNT(*) FILTER (WHERE contract_id     IS NULL OR contract_id     = '') AS nb_missing, COUNT(*) AS total FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'brand',           COUNT(*) FILTER (WHERE brand           IS NULL OR brand           = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'model',           COUNT(*) FILTER (WHERE model           IS NULL OR model           = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'year',            COUNT(*) FILTER (WHERE year            IS NULL OR year            = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'power',           COUNT(*) FILTER (WHERE power           IS NULL OR power           = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'fuel_type',       COUNT(*) FILTER (WHERE fuel_type       IS NULL OR fuel_type       = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'current_value',   COUNT(*) FILTER (WHERE current_value   IS NULL OR current_value   = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'color',           COUNT(*) FILTER (WHERE color           IS NULL OR color           = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'usage',           COUNT(*) FILTER (WHERE usage           IS NULL OR usage           = ''), COUNT(*) FROM raw.vehicles
UNION ALL SELECT 'vehicles', 'previous_claims', COUNT(*) FILTER (WHERE previous_claims IS NULL OR previous_claims = ''), COUNT(*) FROM raw.vehicles
ORDER BY table_name, column_name;


-- ------------------------------------------------------------
-- SECTION 2 — INVESTIGATE 'year' IN vehicles
-- ------------------------------------------------------------

-- 2.1 Show distinct non-empty raw values of year (first 30)
SELECT year, COUNT(*) AS nb
FROM raw.vehicles
WHERE year IS NOT NULL AND year <> ''
GROUP BY year
ORDER BY nb DESC
LIMIT 30;


-- ------------------------------------------------------------
-- SECTION 3 — INVESTIGATE 'previous_claims' IN vehicles
-- ------------------------------------------------------------

-- 3.1 Show distinct non-empty raw values of previous_claims (first 30)
SELECT previous_claims, COUNT(*) AS nb
FROM raw.vehicles
WHERE previous_claims IS NOT NULL AND previous_claims <> ''
GROUP BY previous_claims
ORDER BY nb DESC
LIMIT 30;


-- ------------------------------------------------------------
-- SECTION 4 — INVESTIGATE 'autre' in annual_premium
-- ------------------------------------------------------------

-- 4.1 Show 30 sample values that were classified 'autre'
SELECT annual_premium
FROM raw.contracts
WHERE annual_premium NOT LIKE '€%'
  AND annual_premium NOT LIKE '%€'
  AND annual_premium NOT LIKE '%EUR%'
  AND annual_premium NOT LIKE '%$%'
  AND annual_premium IS NOT NULL
LIMIT 30;


-- ------------------------------------------------------------
-- SECTION 5 — DATE FORMAT CONSISTENCY CHECK
-- ------------------------------------------------------------

-- 5.1 Check if start_date > end_date (only for YYYY-MM-DD format)
SELECT COUNT(*) AS incoherent_dates
FROM raw.contracts
WHERE start_date ~ '^\d{4}-\d{2}-\d{2}$'
  AND end_date   ~ '^\d{4}-\d{2}-\d{2}$'
  AND start_date::date > end_date::date;

-- 5.2 Check if declaration_date < occurrence_date (impossible)
SELECT COUNT(*) AS declaration_before_occurrence
FROM raw.claims
WHERE occurrence_date  ~ '^\d{4}-\d{2}-\d{2}$'
  AND declaration_date ~ '^\d{4}-\d{2}-\d{2}$'
  AND declaration_date::date < occurrence_date::date;


-- ------------------------------------------------------------
-- SECTION 6 — NUMERIC OUTLIERS
-- ------------------------------------------------------------

-- 6.1 client_age distribution check
SELECT
    MIN(client_age::numeric) AS min_age,
    MAX(client_age::numeric) AS max_age,
    ROUND(AVG(client_age::numeric), 1) AS avg_age
FROM raw.contracts
WHERE client_age ~ '^[0-9]+(\.[0-9]+)?$';

-- 6.2 client_age suspicious values (< 18 or > 100)
SELECT client_age, COUNT(*) AS nb
FROM raw.contracts
WHERE client_age ~ '^[0-9]+(\.[0-9]+)?$'
  AND (client_age::numeric < 18 OR client_age::numeric > 100)
GROUP BY client_age
ORDER BY client_age;

-- 6.3 Check for negative or zero amounts
SELECT COUNT(*) AS zero_or_negative
FROM raw.claims
WHERE damage_amount ~ '^[0-9.]+$' AND damage_amount::numeric <= 0;


-- ------------------------------------------------------------
-- SECTION 7 — REFERENTIAL INTEGRITY
-- ------------------------------------------------------------

-- 7.1 Orphans in claims.contract_id
SELECT COUNT(*) AS claims_orphans
FROM raw.claims c
LEFT JOIN raw.contracts ct ON c.contract_id = ct.contract_id
WHERE ct.contract_id IS NULL;

-- 7.2 Orphans in vehicles.contract_id
SELECT COUNT(*) AS vehicles_orphans
FROM raw.vehicles v
LEFT JOIN raw.contracts c ON v.contract_id = c.contract_id
WHERE c.contract_id IS NULL;


-- ------------------------------------------------------------
-- SECTION 8 — DUPLICATES
-- ------------------------------------------------------------

-- 8.1 Duplicates on contracts.contract_id
SELECT COUNT(*) - COUNT(DISTINCT contract_id) AS duplicate_contract_ids
FROM raw.contracts;

-- 8.2 Duplicates on claims.claim_id
SELECT COUNT(*) - COUNT(DISTINCT claim_id) AS duplicate_claim_ids
FROM raw.claims;

-- 8.3 Duplicates on vehicles.contract_id
SELECT COUNT(*) - COUNT(DISTINCT contract_id) AS duplicate_vehicle_contract_ids
FROM raw.vehicles;


-- ------------------------------------------------------------
-- SECTION 9 — CATEGORY NORMALIZATION CHECK
-- ------------------------------------------------------------

-- 9.1 Distinct gender values (with counts)
SELECT COALESCE(NULLIF(gender, ''), '(empty)') AS gender_value, COUNT(*) AS nb
FROM raw.contracts
GROUP BY 1
ORDER BY nb DESC;

-- 9.2 Distinct csp values (with counts)
SELECT COALESCE(NULLIF(csp, ''), '(empty)') AS csp_value, COUNT(*) AS nb
FROM raw.contracts
GROUP BY 1
ORDER BY nb DESC;

-- 9.3 Distinct liability values (with counts)
SELECT COALESCE(NULLIF(liability, ''), '(empty)') AS liability_value, COUNT(*) AS nb
FROM raw.claims
GROUP BY 1
ORDER BY nb DESC;


-- ============================================================
-- END OF DIAGNOSTICS
-- ============================================================
