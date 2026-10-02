-- ============================================================
-- 03_core / 02_create_core_tables.sql
-- Create fact/master tables in core schema
-- Phase 9 — Table and Constraint Creation
-- ============================================================

-- Drop if exists (reverse dependency order)
DROP TABLE IF EXISTS core.vehicles  CASCADE;
DROP TABLE IF EXISTS core.claims    CASCADE;
DROP TABLE IF EXISTS core.contracts CASCADE;
DROP TABLE IF EXISTS core.clients   CASCADE;


-- ------------------------------------------------------------
-- clients
-- ------------------------------------------------------------
CREATE TABLE core.clients (
    client_id   TEXT PRIMARY KEY,
    client_name TEXT NOT NULL,
    client_age  NUMERIC(5,1),
    gender      CHAR(1),
    csp_id      INTEGER REFERENCES core.ref_csp(csp_id),
    CONSTRAINT chk_gender CHECK (gender IN ('M', 'F') OR gender IS NULL),
    CONSTRAINT chk_age    CHECK (client_age IS NULL OR (client_age >= 0 AND client_age <= 120))
);
COMMENT ON TABLE core.clients IS 'Insurance clients';


-- ------------------------------------------------------------
-- contracts
-- ------------------------------------------------------------
CREATE TABLE core.contracts (
    contract_id         TEXT PRIMARY KEY,
    client_id           TEXT NOT NULL REFERENCES core.clients(client_id),
    product_id          INTEGER NOT NULL REFERENCES core.ref_products(product_id),
    channel_id          INTEGER NOT NULL REFERENCES core.ref_channels(channel_id),
    city_id             INTEGER NOT NULL REFERENCES core.ref_cities(city_id),
    start_date          DATE,
    end_date            DATE,
    annual_premium_eur  NUMERIC(12,2),
    status_id           INTEGER NOT NULL REFERENCES core.ref_contract_statuses(status_id),
    CONSTRAINT chk_premium CHECK (annual_premium_eur IS NULL OR annual_premium_eur >= 0),
    CONSTRAINT chk_dates   CHECK (start_date IS NULL OR end_date IS NULL OR end_date >= start_date)
);
COMMENT ON TABLE core.contracts IS 'Insurance contracts';


-- ------------------------------------------------------------
-- claims
-- ------------------------------------------------------------
CREATE TABLE core.claims (
    claim_id                TEXT PRIMARY KEY,
    contract_id             TEXT NOT NULL REFERENCES core.contracts(contract_id),
    occurrence_date         DATE,
    declaration_date        DATE,
    claim_type_id           INTEGER NOT NULL REFERENCES core.ref_claim_types(claim_type_id),
    damage_amount_eur       NUMERIC(12,2),
    indemnified_amount_eur  NUMERIC(12,2),
    status_id               INTEGER NOT NULL REFERENCES core.ref_claim_statuses(status_id),
    expert_id               TEXT,
    liability_id            INTEGER REFERENCES core.ref_liabilities(liability_id),
    CONSTRAINT chk_damage      CHECK (damage_amount_eur      IS NULL OR damage_amount_eur      >= 0),
    CONSTRAINT chk_indemnified CHECK (indemnified_amount_eur IS NULL OR indemnified_amount_eur >= 0)
);
COMMENT ON TABLE core.claims IS 'Insurance claims';


-- ------------------------------------------------------------
-- vehicles
-- ------------------------------------------------------------
CREATE TABLE core.vehicles (
    contract_id       TEXT PRIMARY KEY REFERENCES core.contracts(contract_id),
    brand_id          INTEGER REFERENCES core.ref_vehicle_brands(brand_id),
    model             TEXT,
    year              INTEGER,
    power             INTEGER,
    fuel_type_id      INTEGER REFERENCES core.ref_fuel_types(fuel_type_id),
    current_value_eur NUMERIC(12,2),
    color_id          INTEGER REFERENCES core.ref_vehicle_colors(color_id),
    usage_id          INTEGER REFERENCES core.ref_vehicle_usages(usage_id),
    previous_claims   INTEGER,
    CONSTRAINT chk_year            CHECK (year IS NULL OR (year >= 1900 AND year <= 2100)),
    CONSTRAINT chk_power           CHECK (power IS NULL OR power > 0),
    CONSTRAINT chk_current_value   CHECK (current_value_eur IS NULL OR current_value_eur >= 0),
    CONSTRAINT chk_previous_claims CHECK (previous_claims IS NULL OR previous_claims >= 0)
);
COMMENT ON TABLE core.vehicles IS 'Vehicles covered by Auto contracts';
