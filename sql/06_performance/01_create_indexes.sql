-- ============================================================
-- 06_performance / 01_create_indexes.sql
-- Indexes strategy: simple, composite, partial, expression
-- Phase 28 — Indexes
-- ============================================================

-- SECTION 1 — SIMPLE B-TREE INDEXES (FOREIGN KEYS)

CREATE INDEX IF NOT EXISTS idx_contracts_client_id    ON core.contracts(client_id);
CREATE INDEX IF NOT EXISTS idx_contracts_product_id   ON core.contracts(product_id);
CREATE INDEX IF NOT EXISTS idx_contracts_channel_id   ON core.contracts(channel_id);
CREATE INDEX IF NOT EXISTS idx_contracts_city_id      ON core.contracts(city_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status_id    ON core.contracts(status_id);

CREATE INDEX IF NOT EXISTS idx_claims_contract_id     ON core.claims(contract_id);
CREATE INDEX IF NOT EXISTS idx_claims_claim_type_id   ON core.claims(claim_type_id);
CREATE INDEX IF NOT EXISTS idx_claims_status_id       ON core.claims(status_id);
CREATE INDEX IF NOT EXISTS idx_claims_expert_id       ON core.claims(expert_id);

CREATE INDEX IF NOT EXISTS idx_vehicles_brand_id      ON core.vehicles(brand_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_fuel_type_id  ON core.vehicles(fuel_type_id);

CREATE INDEX IF NOT EXISTS idx_clients_csp_id         ON core.clients(csp_id);

-- SECTION 2 — DATE INDEXES (range queries)

CREATE INDEX IF NOT EXISTS idx_contracts_start_date   ON core.contracts(start_date);
CREATE INDEX IF NOT EXISTS idx_contracts_end_date     ON core.contracts(end_date);
CREATE INDEX IF NOT EXISTS idx_claims_occurrence_date ON core.claims(occurrence_date);
CREATE INDEX IF NOT EXISTS idx_claims_declaration_date ON core.claims(declaration_date);

-- SECTION 3 — COMPOSITE INDEXES

CREATE INDEX IF NOT EXISTS idx_contracts_product_status
    ON core.contracts(product_id, status_id);

CREATE INDEX IF NOT EXISTS idx_claims_contract_status
    ON core.claims(contract_id, status_id);

CREATE INDEX IF NOT EXISTS idx_contracts_status_start_date
    ON core.contracts(status_id, start_date DESC);

-- SECTION 4 — PARTIAL INDEXES

CREATE INDEX IF NOT EXISTS idx_contracts_active
    ON core.contracts(contract_id)
    WHERE status_id = (SELECT status_id FROM core.ref_contract_statuses WHERE status_name = 'Active');

CREATE INDEX IF NOT EXISTS idx_claims_closed
    ON core.claims(claim_id)
    WHERE status_id = (SELECT status_id FROM core.ref_claim_statuses WHERE status_name = 'Closed');

-- SECTION 5 — EXPRESSION INDEXES

CREATE INDEX IF NOT EXISTS idx_contracts_start_year
    ON core.contracts(EXTRACT(YEAR FROM start_date));

CREATE INDEX IF NOT EXISTS idx_clients_lower_name
    ON core.clients(LOWER(client_name));

CREATE INDEX IF NOT EXISTS idx_claims_occurrence_month
    ON core.claims(date_trunc('month', occurrence_date));

-- SECTION 6 — VERIFY INDEXES

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname IN ('core', 'analytics')
ORDER BY schemaname, tablename, indexname;
