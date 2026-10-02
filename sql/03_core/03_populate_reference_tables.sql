-- ============================================================
-- 03_core / 03_populate_reference_tables.sql
-- Populate reference tables from staging
-- Phase 9 — Table and Constraint Creation
-- ============================================================

BEGIN;

TRUNCATE core.ref_cities, core.ref_products, core.ref_channels,
         core.ref_csp, core.ref_risk_zones, core.ref_contract_statuses,
         core.ref_claim_types, core.ref_claim_statuses, core.ref_liabilities,
         core.ref_fuel_types, core.ref_vehicle_brands, core.ref_vehicle_usages,
         core.ref_vehicle_colors
RESTART IDENTITY CASCADE;


-- ------------------------------------------------------------
-- ref_risk_zones (from staging.contracts.risk_zone)
-- ------------------------------------------------------------
INSERT INTO core.ref_risk_zones (risk_zone_name)
SELECT DISTINCT risk_zone
FROM staging.contracts
WHERE risk_zone IS NOT NULL AND risk_zone <> ''
ORDER BY risk_zone;


-- ------------------------------------------------------------
-- ref_products
-- ------------------------------------------------------------
INSERT INTO core.ref_products (product_name)
SELECT DISTINCT product
FROM staging.contracts
WHERE product IS NOT NULL AND product <> ''
ORDER BY product;


-- ------------------------------------------------------------
-- ref_channels
-- ------------------------------------------------------------
INSERT INTO core.ref_channels (channel_name)
SELECT DISTINCT channel
FROM staging.contracts
WHERE channel IS NOT NULL AND channel <> ''
ORDER BY channel;


-- ------------------------------------------------------------
-- ref_csp (exclude NULL)
-- ------------------------------------------------------------
INSERT INTO core.ref_csp (csp_name)
SELECT DISTINCT csp
FROM staging.contracts
WHERE csp IS NOT NULL AND csp <> ''
ORDER BY csp;


-- ------------------------------------------------------------
-- ref_contract_statuses
-- ------------------------------------------------------------
INSERT INTO core.ref_contract_statuses (status_name)
SELECT DISTINCT status
FROM staging.contracts
WHERE status IS NOT NULL AND status <> ''
ORDER BY status;


-- ------------------------------------------------------------
-- ref_claim_types
-- ------------------------------------------------------------
INSERT INTO core.ref_claim_types (claim_type_name)
SELECT DISTINCT claim_type
FROM staging.claims
WHERE claim_type IS NOT NULL AND claim_type <> ''
ORDER BY claim_type;


-- ------------------------------------------------------------
-- ref_claim_statuses
-- ------------------------------------------------------------
INSERT INTO core.ref_claim_statuses (status_name)
SELECT DISTINCT status
FROM staging.claims
WHERE status IS NOT NULL AND status <> ''
ORDER BY status;


-- ------------------------------------------------------------
-- ref_liabilities (exclude NULL)
-- ------------------------------------------------------------
INSERT INTO core.ref_liabilities (liability_name)
SELECT DISTINCT liability
FROM staging.claims
WHERE liability IS NOT NULL AND liability <> ''
ORDER BY liability;


-- ------------------------------------------------------------
-- ref_fuel_types
-- ------------------------------------------------------------
INSERT INTO core.ref_fuel_types (fuel_type_name)
SELECT DISTINCT fuel_type
FROM staging.vehicles
WHERE fuel_type IS NOT NULL AND fuel_type <> ''
ORDER BY fuel_type;


-- ------------------------------------------------------------
-- ref_vehicle_brands
-- ------------------------------------------------------------
INSERT INTO core.ref_vehicle_brands (brand_name)
SELECT DISTINCT brand
FROM staging.vehicles
WHERE brand IS NOT NULL AND brand <> ''
ORDER BY brand;


-- ------------------------------------------------------------
-- ref_vehicle_usages
-- ------------------------------------------------------------
INSERT INTO core.ref_vehicle_usages (usage_name)
SELECT DISTINCT usage
FROM staging.vehicles
WHERE usage IS NOT NULL AND usage <> ''
ORDER BY usage;


-- ------------------------------------------------------------
-- ref_vehicle_colors (exclude NULL)
-- ------------------------------------------------------------
INSERT INTO core.ref_vehicle_colors (color_name)
SELECT DISTINCT color
FROM staging.vehicles
WHERE color IS NOT NULL AND color <> ''
ORDER BY color;


-- ------------------------------------------------------------
-- ref_cities (depends on ref_risk_zones)
-- ------------------------------------------------------------
INSERT INTO core.ref_cities (city_name, postal_code, risk_zone_id)
SELECT DISTINCT
    c.city,
    c.postal_code,
    rz.risk_zone_id
FROM staging.contracts c
JOIN core.ref_risk_zones rz ON rz.risk_zone_name = c.risk_zone
WHERE c.city IS NOT NULL AND c.city <> ''
  AND c.postal_code IS NOT NULL AND c.postal_code <> ''
ORDER BY c.city, c.postal_code;

COMMIT;


-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'ref_risk_zones'         AS table_name, COUNT(*) FROM core.ref_risk_zones
UNION ALL SELECT 'ref_products',           COUNT(*) FROM core.ref_products
UNION ALL SELECT 'ref_channels',           COUNT(*) FROM core.ref_channels
UNION ALL SELECT 'ref_csp',                COUNT(*) FROM core.ref_csp
UNION ALL SELECT 'ref_contract_statuses',  COUNT(*) FROM core.ref_contract_statuses
UNION ALL SELECT 'ref_claim_types',        COUNT(*) FROM core.ref_claim_types
UNION ALL SELECT 'ref_claim_statuses',     COUNT(*) FROM core.ref_claim_statuses
UNION ALL SELECT 'ref_liabilities',        COUNT(*) FROM core.ref_liabilities
UNION ALL SELECT 'ref_fuel_types',         COUNT(*) FROM core.ref_fuel_types
UNION ALL SELECT 'ref_vehicle_brands',     COUNT(*) FROM core.ref_vehicle_brands
UNION ALL SELECT 'ref_vehicle_usages',     COUNT(*) FROM core.ref_vehicle_usages
UNION ALL SELECT 'ref_vehicle_colors',     COUNT(*) FROM core.ref_vehicle_colors
UNION ALL SELECT 'ref_cities',             COUNT(*) FROM core.ref_cities;
