-- ============================================================
-- 01_import / 01_create_raw_tables.sql
-- Create raw tables in the raw schema
-- Phase 4 — Data import
-- ============================================================

-- Connect: psql -d insurance_analytics

-- Table raw.contracts (14 colonnes)
CREATE TABLE raw.contracts (
    contract_id       TEXT,
    client_id         TEXT,
    client_name       TEXT,
    product           TEXT,
    start_date        TEXT,
    end_date          TEXT,
    annual_premium    TEXT,
    status            TEXT,
    city_postal       TEXT,
    risk_zone         TEXT,
    client_age        TEXT,
    channel           TEXT,
    csp               TEXT,
    gender            TEXT
);

-- Table raw.claims (10 colonnes)
CREATE TABLE raw.claims (
    claim_id            TEXT,
    contract_id         TEXT,
    occurrence_date     TEXT,
    declaration_date    TEXT,
    claim_type          TEXT,
    damage_amount       TEXT,
    indemnified_amount  TEXT,
    status              TEXT,
    expert_id           TEXT,
    liability           TEXT
);

-- Table raw.vehicles (10 colonnes)
CREATE TABLE raw.vehicles (
    contract_id       TEXT,
    brand             TEXT,
    model             TEXT,
    year              TEXT,
    power             TEXT,
    fuel_type         TEXT,
    current_value     TEXT,
    color             TEXT,
    usage             TEXT,
    previous_claims   TEXT
);
