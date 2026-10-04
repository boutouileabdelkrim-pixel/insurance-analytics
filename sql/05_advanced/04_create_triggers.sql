-- ============================================================
-- 05_advanced / 04_create_triggers.sql
-- Triggers for audit and integrity
-- Phase 26 — Triggers
-- ============================================================

-- AUDIT SCHEMA
CREATE SCHEMA IF NOT EXISTS audit;

-- AUDIT TABLE: generic history for contracts
CREATE TABLE IF NOT EXISTS audit.contracts_history (
    history_id     SERIAL PRIMARY KEY,
    contract_id    TEXT NOT NULL,
    operation      TEXT NOT NULL,
    old_data       JSONB,
    new_data       JSONB,
    changed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    changed_by     TEXT NOT NULL DEFAULT current_user
);

-- AUDIT TABLE: generic history for claims
CREATE TABLE IF NOT EXISTS audit.claims_history (
    history_id     SERIAL PRIMARY KEY,
    claim_id       TEXT NOT NULL,
    operation      TEXT NOT NULL,
    old_data       JSONB,
    new_data       JSONB,
    changed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    changed_by     TEXT NOT NULL DEFAULT current_user
);

-- TRG1. Trigger function for contracts audit
CREATE OR REPLACE FUNCTION audit.fn_contracts_audit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.contracts_history(contract_id, operation, new_data)
        VALUES (NEW.contract_id, 'INSERT', to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.contracts_history(contract_id, operation, old_data, new_data)
        VALUES (NEW.contract_id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.contracts_history(contract_id, operation, old_data)
        VALUES (OLD.contract_id, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- TRG2. Trigger on core.contracts
DROP TRIGGER IF EXISTS trg_contracts_audit ON core.contracts;
CREATE TRIGGER trg_contracts_audit
AFTER INSERT OR UPDATE OR DELETE
ON core.contracts
FOR EACH ROW
EXECUTE FUNCTION audit.fn_contracts_audit();

-- TRG3. Trigger function for claims audit
CREATE OR REPLACE FUNCTION audit.fn_claims_audit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.claims_history(claim_id, operation, new_data)
        VALUES (NEW.claim_id, 'INSERT', to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.claims_history(claim_id, operation, old_data, new_data)
        VALUES (NEW.claim_id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.claims_history(claim_id, operation, old_data)
        VALUES (OLD.claim_id, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- TRG4. Trigger on core.claims
DROP TRIGGER IF EXISTS trg_claims_audit ON core.claims;
CREATE TRIGGER trg_claims_audit
AFTER INSERT OR UPDATE OR DELETE
ON core.claims
FOR EACH ROW
EXECUTE FUNCTION audit.fn_claims_audit();

-- TRG5. BEFORE trigger: prevent negative premium
CREATE OR REPLACE FUNCTION core.fn_check_premium()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.annual_premium_eur IS NOT NULL AND NEW.annual_premium_eur < 0 THEN
        RAISE EXCEPTION 'Negative premium not allowed: %', NEW.annual_premium_eur;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_premium ON core.contracts;
CREATE TRIGGER trg_check_premium
BEFORE INSERT OR UPDATE OF annual_premium_eur
ON core.contracts
FOR EACH ROW
EXECUTE FUNCTION core.fn_check_premium();

-- TRG6. BEFORE trigger: prevent claims with negative delay
CREATE OR REPLACE FUNCTION core.fn_check_claim_delay()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.declaration_date IS NOT NULL
       AND NEW.occurrence_date IS NOT NULL
       AND NEW.declaration_date < NEW.occurrence_date THEN
        -- Just warn, do not block (business anomaly, see Phase 20)
        RAISE WARNING 'Claim declared before occurrence: %', NEW.claim_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_claim_delay ON core.claims;
CREATE TRIGGER trg_check_claim_delay
BEFORE INSERT OR UPDATE OF declaration_date, occurrence_date
ON core.claims
FOR EACH ROW
EXECUTE FUNCTION core.fn_check_claim_delay();

-- TESTS
-- Test 1: UPDATE a contract, check history
UPDATE core.contracts
SET annual_premium_eur = annual_premium_eur
WHERE contract_id = (SELECT contract_id FROM core.contracts LIMIT 1);

SELECT 'contracts_history' AS table_name, COUNT(*) FROM audit.contracts_history;

-- Test 2: verify negative premium blocked
-- Uncomment to test the block:
-- UPDATE core.contracts SET annual_premium_eur = -1 WHERE contract_id = (SELECT contract_id FROM core.contracts LIMIT 1);

-- VERIFICATION: list triggers
SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    tgenabled AS enabled
FROM pg_trigger
WHERE tgname LIKE 'trg_%'
ORDER BY tgname;
