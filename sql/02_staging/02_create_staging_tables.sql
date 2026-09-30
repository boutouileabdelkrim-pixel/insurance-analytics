-- ============================================================
-- 02_staging / 02_create_staging_tables.sql
-- Create cleaned staging tables with proper types
-- Phase 6 — Data Quality and Cleaning
-- ============================================================

-- Drop if exists (idempotent)
DROP TABLE IF EXISTS staging.contracts CASCADE;
DROP TABLE IF EXISTS staging.claims CASCADE;
DROP TABLE IF EXISTS staging.vehicles CASCADE;


-- ------------------------------------------------------------
-- staging.contracts
-- ------------------------------------------------------------
CREATE TABLE staging.contracts (
    contract_id     TEXT PRIMARY KEY,
    client_id       TEXT NOT NULL,
    client_name     TEXT,
    product         TEXT,
    start_date      DATE,
    end_date        DATE,
    annual_premium_eur  NUMERIC(12, 2),
    status          TEXT,
    city            TEXT,
    postal_code     TEXT,
    risk_zone       TEXT,
    client_age      NUMERIC(5, 1),
    channel         TEXT,
    csp             TEXT,
    gender          TEXT
);

COMMENT ON TABLE staging.contracts IS
    'Cleaned contracts. Dates parsed, amounts converted to EUR, categories normalized.';


-- ------------------------------------------------------------
-- staging.claims
-- ------------------------------------------------------------
CREATE TABLE staging.claims (
    claim_id            TEXT PRIMARY KEY,
    contract_id         TEXT NOT NULL,
    occurrence_date     DATE,
    declaration_date    DATE,
    claim_type          TEXT,
    damage_amount_eur   NUMERIC(12, 2),
    indemnified_amount_eur NUMERIC(12, 2),
    status              TEXT,
    expert_id           TEXT,
    liability           TEXT
);

COMMENT ON TABLE staging.claims IS
    'Cleaned claims. Dates parsed, amounts converted to EUR, empty strings become NULL.';


-- ------------------------------------------------------------
-- staging.vehicles
-- ------------------------------------------------------------
CREATE TABLE staging.vehicles (
    contract_id         TEXT PRIMARY KEY,
    brand               TEXT,
    model               TEXT,
    year                INTEGER,
    power               INTEGER,
    fuel_type           TEXT,
    current_value_eur   NUMERIC(12, 2),
    color               TEXT,
    usage               TEXT,
    previous_claims     INTEGER
);

COMMENT ON TABLE staging.vehicles IS
    'Cleaned vehicles. Integer casts from decimal strings, amounts converted to EUR.';
