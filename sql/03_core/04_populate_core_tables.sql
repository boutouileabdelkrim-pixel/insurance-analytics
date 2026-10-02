-- ============================================================
-- 03_core / 04_populate_core_tables.sql
-- Populate core tables from staging
-- Phase 9 — Table and Constraint Creation
-- ============================================================

BEGIN;

TRUNCATE core.vehicles, core.claims, core.contracts, core.clients CASCADE;


-- ------------------------------------------------------------
-- clients (depends on ref_csp)
-- ------------------------------------------------------------
INSERT INTO core.clients (client_id, client_name, client_age, gender, csp_id)
SELECT DISTINCT ON (c.client_id)
    c.client_id,
    c.client_name,
    c.client_age,
    c.gender,
    rc.csp_id
FROM staging.contracts c
LEFT JOIN core.ref_csp rc ON rc.csp_name = c.csp
ORDER BY c.client_id;


-- ------------------------------------------------------------
-- contracts (depends on clients, ref_products, ref_channels, ref_cities, ref_contract_statuses)
-- ------------------------------------------------------------
INSERT INTO core.contracts (
    contract_id, client_id, product_id, channel_id, city_id,
    start_date, end_date, annual_premium_eur, status_id
)
SELECT
    c.contract_id,
    c.client_id,
    rp.product_id,
    rch.channel_id,
    rci.city_id,
    c.start_date,
    c.end_date,
    c.annual_premium_eur,
    rcs.status_id
FROM staging.contracts c
JOIN core.ref_products          rp  ON rp.product_name   = c.product
JOIN core.ref_channels          rch ON rch.channel_name  = c.channel
JOIN core.ref_cities            rci ON rci.city_name = c.city AND rci.postal_code = c.postal_code
JOIN core.ref_contract_statuses rcs ON rcs.status_name   = c.status;


-- ------------------------------------------------------------
-- claims (depends on contracts, ref_claim_types, ref_claim_statuses, ref_liabilities)
-- ------------------------------------------------------------
INSERT INTO core.claims (
    claim_id, contract_id, occurrence_date, declaration_date, claim_type_id,
    damage_amount_eur, indemnified_amount_eur, status_id, expert_id, liability_id
)
SELECT
    cl.claim_id,
    cl.contract_id,
    cl.occurrence_date,
    cl.declaration_date,
    rct.claim_type_id,
    cl.damage_amount_eur,
    cl.indemnified_amount_eur,
    rcs.status_id,
    cl.expert_id,
    rl.liability_id
FROM staging.claims cl
JOIN core.ref_claim_types    rct ON rct.claim_type_name = cl.claim_type
JOIN core.ref_claim_statuses rcs ON rcs.status_name     = cl.status
LEFT JOIN core.ref_liabilities rl ON rl.liability_name  = cl.liability;


-- ------------------------------------------------------------
-- vehicles (depends on contracts, ref_vehicle_brands, ref_fuel_types, ref_vehicle_usages, ref_vehicle_colors)
-- ------------------------------------------------------------
INSERT INTO core.vehicles (
    contract_id, brand_id, model, year, power,
    fuel_type_id, current_value_eur, color_id, usage_id, previous_claims
)
SELECT
    v.contract_id,
    rb.brand_id,
    v.model,
    v.year,
    v.power,
    rft.fuel_type_id,
    v.current_value_eur,
    rvc.color_id,
    rvu.usage_id,
    v.previous_claims
FROM staging.vehicles v
JOIN core.contracts              c   ON c.contract_id     = v.contract_id
LEFT JOIN core.ref_vehicle_brands rb  ON rb.brand_name     = v.brand
LEFT JOIN core.ref_fuel_types    rft ON rft.fuel_type_name = v.fuel_type
LEFT JOIN core.ref_vehicle_usages rvu ON rvu.usage_name    = v.usage
LEFT JOIN core.ref_vehicle_colors rvc ON rvc.color_name    = v.color;

COMMIT;


-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'clients'   AS table_name, (SELECT COUNT(*) FROM staging.contracts) AS staging_count,
                                   (SELECT COUNT(DISTINCT client_id) FROM staging.contracts) AS expected_count,
                                   (SELECT COUNT(*) FROM core.clients) AS core_count
UNION ALL
SELECT 'contracts',
       (SELECT COUNT(*) FROM staging.contracts),
       (SELECT COUNT(*) FROM staging.contracts),
       (SELECT COUNT(*) FROM core.contracts)
UNION ALL
SELECT 'claims',
       (SELECT COUNT(*) FROM staging.claims),
       (SELECT COUNT(*) FROM staging.claims),
       (SELECT COUNT(*) FROM core.claims)
UNION ALL
SELECT 'vehicles',
       (SELECT COUNT(*) FROM staging.vehicles),
       (SELECT COUNT(*) FROM staging.vehicles),
       (SELECT COUNT(*) FROM core.vehicles);
