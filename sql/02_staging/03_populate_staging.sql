-- ============================================================
-- 02_staging / 03_populate_staging.sql
-- Populate staging tables from raw with cleaning rules
-- Phase 6 — Data Quality and Cleaning
-- ============================================================
--
-- Depends on: 00_date_helpers.sql (staging.parse_date)
-- ============================================================

BEGIN;

TRUNCATE staging.contracts, staging.claims, staging.vehicles;


-- ------------------------------------------------------------
-- Populate staging.contracts
-- ------------------------------------------------------------
INSERT INTO staging.contracts (
    contract_id, client_id, client_name, product,
    start_date, end_date, annual_premium_eur, status,
    city, postal_code, risk_zone, client_age, channel, csp, gender
)
SELECT
    contract_id,
    client_id,
    client_name,
    product,
    staging.parse_date(start_date),
    staging.parse_date(end_date),
    CASE
        WHEN annual_premium IS NULL OR annual_premium = '' THEN NULL
        WHEN annual_premium !~ '[0-9]' THEN NULL
        WHEN annual_premium LIKE '%$%' THEN
            ROUND((regexp_replace(annual_premium, '[^0-9.]', '', 'g'))::numeric * 0.92, 2)
        ELSE
            ROUND((regexp_replace(annual_premium, '[^0-9.]', '', 'g'))::numeric, 2)
    END,
    status,
    split_part(city_postal, '_', 1),
    split_part(city_postal, '_', 2),
    risk_zone,
    CASE
        WHEN client_age ~ '^[0-9]+(\.[0-9]+)?$' THEN client_age::numeric
        ELSE NULL
    END,
    channel,
    NULLIF(csp, ''),
    CASE
        WHEN gender IN ('M', 'Male')   THEN 'M'
        WHEN gender IN ('F', 'Female') THEN 'F'
        ELSE NULL
    END
FROM raw.contracts;


-- ------------------------------------------------------------
-- Populate staging.claims
-- ------------------------------------------------------------
INSERT INTO staging.claims (
    claim_id, contract_id, occurrence_date, declaration_date,
    claim_type, damage_amount_eur, indemnified_amount_eur,
    status, expert_id, liability
)
SELECT
    claim_id,
    contract_id,
    staging.parse_date(occurrence_date),
    staging.parse_date(declaration_date),
    claim_type,
    CASE
        WHEN damage_amount IS NULL OR damage_amount = '' THEN NULL
        WHEN damage_amount !~ '[0-9]' THEN NULL
        WHEN damage_amount LIKE '%$%' THEN
            ROUND((regexp_replace(damage_amount, '[^0-9.]', '', 'g'))::numeric * 0.92, 2)
        ELSE
            ROUND((regexp_replace(damage_amount, '[^0-9.]', '', 'g'))::numeric, 2)
    END,
    CASE
        WHEN indemnified_amount IS NULL OR indemnified_amount = '' THEN NULL
        WHEN indemnified_amount !~ '[0-9]' THEN NULL
        WHEN indemnified_amount LIKE '%$%' THEN
            ROUND((regexp_replace(indemnified_amount, '[^0-9.]', '', 'g'))::numeric * 0.92, 2)
        ELSE
            ROUND((regexp_replace(indemnified_amount, '[^0-9.]', '', 'g'))::numeric, 2)
    END,
    status,
    NULLIF(expert_id, ''),
    NULLIF(liability, '')
FROM raw.claims;


-- ------------------------------------------------------------
-- Populate staging.vehicles
-- ------------------------------------------------------------
INSERT INTO staging.vehicles (
    contract_id, brand, model, year, power, fuel_type,
    current_value_eur, color, usage, previous_claims
)
SELECT
    contract_id,
    brand,
    model,
    CASE
        WHEN year ~ '^[0-9]+(\.[0-9]+)?$' THEN year::numeric::integer
        ELSE NULL
    END,
    CASE
        WHEN power ~ '^[0-9]+(\.[0-9]+)?$' THEN power::numeric::integer
        ELSE NULL
    END,
    fuel_type,
    CASE
        WHEN current_value IS NULL OR current_value = '' THEN NULL
        WHEN current_value !~ '[0-9]' THEN NULL
        WHEN current_value LIKE '%$%' THEN
            ROUND((regexp_replace(current_value, '[^0-9.]', '', 'g'))::numeric * 0.92, 2)
        ELSE
            ROUND((regexp_replace(current_value, '[^0-9.]', '', 'g'))::numeric, 2)
    END,
    NULLIF(color, ''),
    usage,
    CASE
        WHEN previous_claims ~ '^[0-9]+(\.[0-9]+)?$' THEN previous_claims::numeric::integer
        ELSE NULL
    END
FROM raw.vehicles;

COMMIT;


-- ============================================================
-- POST-POPULATION VERIFICATION
-- ============================================================

-- V1. Row counts must match raw
SELECT 'contracts' AS table_name, (SELECT COUNT(*) FROM raw.contracts) AS raw_count, (SELECT COUNT(*) FROM staging.contracts) AS staging_count
UNION ALL
SELECT 'claims', (SELECT COUNT(*) FROM raw.claims), (SELECT COUNT(*) FROM staging.claims)
UNION ALL
SELECT 'vehicles', (SELECT COUNT(*) FROM raw.vehicles), (SELECT COUNT(*) FROM staging.vehicles);

-- V2. Date parsing coverage (contracts)
SELECT
    COUNT(*) AS total,
    COUNT(start_date) AS start_parsed,
    COUNT(end_date)   AS end_parsed
FROM staging.contracts;

-- V3. Premium stats (EUR)
SELECT
    MIN(annual_premium_eur) AS min_premium,
    MAX(annual_premium_eur) AS max_premium,
    ROUND(AVG(annual_premium_eur), 2) AS avg_premium,
    COUNT(*) FILTER (WHERE annual_premium_eur IS NULL) AS nb_null
FROM staging.contracts;

-- V4. Gender distribution (normalized)
SELECT gender, COUNT(*) AS nb
FROM staging.contracts
GROUP BY gender
ORDER BY nb DESC NULLS LAST;

-- V5. Year range (vehicles)
SELECT
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    COUNT(*) FILTER (WHERE year IS NULL) AS nb_null
FROM staging.vehicles;

-- V6. previous_claims distribution
SELECT previous_claims, COUNT(*) AS nb
FROM staging.vehicles
GROUP BY previous_claims
ORDER BY previous_claims NULLS LAST;

-- V7. Claim dates coverage
SELECT
    COUNT(*) AS total,
    COUNT(occurrence_date)  AS occurrence_parsed,
    COUNT(declaration_date) AS declaration_parsed
FROM staging.claims;

-- V8. Amount stats (claims)
SELECT
    MIN(damage_amount_eur) AS min_damage,
    MAX(damage_amount_eur) AS max_damage,
    ROUND(AVG(damage_amount_eur), 2) AS avg_damage,
    ROUND(AVG(indemnified_amount_eur), 2) AS avg_indemnified
FROM staging.claims;

-- ============================================================
-- END
-- ============================================================
