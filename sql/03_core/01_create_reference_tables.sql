-- ============================================================
-- 03_core / 01_create_reference_tables.sql
-- Create reference (dimension) tables in core schema
-- Phase 9 — Table and Constraint Creation
-- ============================================================

-- Drop if exists (idempotent, reverse dependency order)
DROP TABLE IF EXISTS core.ref_cities         CASCADE;
DROP TABLE IF EXISTS core.ref_products       CASCADE;
DROP TABLE IF EXISTS core.ref_channels       CASCADE;
DROP TABLE IF EXISTS core.ref_csp            CASCADE;
DROP TABLE IF EXISTS core.ref_risk_zones     CASCADE;
DROP TABLE IF EXISTS core.ref_contract_statuses CASCADE;
DROP TABLE IF EXISTS core.ref_claim_types    CASCADE;
DROP TABLE IF EXISTS core.ref_claim_statuses CASCADE;
DROP TABLE IF EXISTS core.ref_liabilities    CASCADE;
DROP TABLE IF EXISTS core.ref_fuel_types     CASCADE;
DROP TABLE IF EXISTS core.ref_vehicle_brands CASCADE;
DROP TABLE IF EXISTS core.ref_vehicle_usages CASCADE;
DROP TABLE IF EXISTS core.ref_vehicle_colors CASCADE;


-- ------------------------------------------------------------
-- ref_risk_zones (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_risk_zones (
    risk_zone_id   SERIAL PRIMARY KEY,
    risk_zone_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_risk_zones IS 'Risk zone levels: Low, Medium, High';


-- ------------------------------------------------------------
-- ref_products (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_products (
    product_id   SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_products IS 'Insurance products: Auto, Home, Life, Health';


-- ------------------------------------------------------------
-- ref_channels (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_channels (
    channel_id   SERIAL PRIMARY KEY,
    channel_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_channels IS 'Distribution channels: Broker, Agency, Web, Phone';


-- ------------------------------------------------------------
-- ref_csp (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_csp (
    csp_id   SERIAL PRIMARY KEY,
    csp_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_csp IS 'Socio-professional categories';


-- ------------------------------------------------------------
-- ref_contract_statuses (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_contract_statuses (
    status_id   SERIAL PRIMARY KEY,
    status_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_contract_statuses IS 'Contract statuses: Active, Renewed, etc.';


-- ------------------------------------------------------------
-- ref_claim_types (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_claim_types (
    claim_type_id   SERIAL PRIMARY KEY,
    claim_type_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_claim_types IS 'Claim types: Collision, Theft, Fire, etc.';


-- ------------------------------------------------------------
-- ref_claim_statuses (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_claim_statuses (
    status_id   SERIAL PRIMARY KEY,
    status_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_claim_statuses IS 'Claim statuses: Open, Closed, etc.';


-- ------------------------------------------------------------
-- ref_liabilities (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_liabilities (
    liability_id   SERIAL PRIMARY KEY,
    liability_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_liabilities IS 'Liability types: Insured, Third_party, etc.';


-- ------------------------------------------------------------
-- ref_fuel_types (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_fuel_types (
    fuel_type_id   SERIAL PRIMARY KEY,
    fuel_type_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_fuel_types IS 'Fuel types: Gasoline, Diesel, Hybrid, Electric';


-- ------------------------------------------------------------
-- ref_vehicle_brands (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_vehicle_brands (
    brand_id   SERIAL PRIMARY KEY,
    brand_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_vehicle_brands IS 'Vehicle brands';


-- ------------------------------------------------------------
-- ref_vehicle_usages (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_vehicle_usages (
    usage_id   SERIAL PRIMARY KEY,
    usage_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_vehicle_usages IS 'Vehicle usages: Personal, Professional, Mixed';


-- ------------------------------------------------------------
-- ref_vehicle_colors (no dependencies)
-- ------------------------------------------------------------
CREATE TABLE core.ref_vehicle_colors (
    color_id   SERIAL PRIMARY KEY,
    color_name TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE core.ref_vehicle_colors IS 'Vehicle colors';


-- ------------------------------------------------------------
-- ref_cities (depends on ref_risk_zones)
-- ------------------------------------------------------------
CREATE TABLE core.ref_cities (
    city_id      SERIAL PRIMARY KEY,
    city_name    TEXT NOT NULL,
    postal_code  TEXT NOT NULL,
    risk_zone_id INTEGER NOT NULL REFERENCES core.ref_risk_zones(risk_zone_id),
    CONSTRAINT uq_city_postal UNIQUE (city_name, postal_code)
);
COMMENT ON TABLE core.ref_cities IS 'Cities with postal code and risk zone';
