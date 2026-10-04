-- ============================================================
-- 05_advanced / 05_transactions.sql
-- Transactions, savepoints, isolation levels
-- Phase 27
-- ============================================================

-- SECTION 1 — BEGIN / COMMIT / ROLLBACK

BEGIN;
    UPDATE core.contracts
    SET annual_premium_eur = annual_premium_eur * 1.01
    WHERE contract_id = (SELECT contract_id FROM core.contracts ORDER BY contract_id LIMIT 1);
    SELECT contract_id, annual_premium_eur FROM core.contracts
    WHERE contract_id = (SELECT contract_id FROM core.contracts ORDER BY contract_id LIMIT 1);
ROLLBACK;

-- SECTION 2 — SAVEPOINT

BEGIN;
    UPDATE core.contracts
    SET annual_premium_eur = annual_premium_eur + 1
    WHERE contract_id = (SELECT contract_id FROM core.contracts ORDER BY contract_id LIMIT 1);

    SAVEPOINT sp1;

    UPDATE core.contracts
    SET annual_premium_eur = annual_premium_eur + 100
    WHERE contract_id = (SELECT contract_id FROM core.contracts ORDER BY contract_id LIMIT 1);

    ROLLBACK TO SAVEPOINT sp1;

    SELECT contract_id, annual_premium_eur FROM core.contracts
    WHERE contract_id = (SELECT contract_id FROM core.contracts ORDER BY contract_id LIMIT 1);
ROLLBACK;

-- SECTION 3 — ISOLATION LEVELS

SHOW transaction_isolation;

BEGIN ISOLATION LEVEL READ COMMITTED;
    SELECT COUNT(*) FROM core.contracts;
COMMIT;

BEGIN ISOLATION LEVEL REPEATABLE READ;
    SELECT COUNT(*) FROM core.contracts;
COMMIT;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    SELECT COUNT(*) FROM core.contracts;
COMMIT;

-- SECTION 4 — BUSINESS CASE: simulate an indemnification

BEGIN;
    SAVEPOINT before_update;

    UPDATE core.claims
    SET indemnified_amount_eur = COALESCE(indemnified_amount_eur, 0) + 1000
    WHERE claim_id = (SELECT claim_id FROM core.claims ORDER BY claim_id LIMIT 1);

    SELECT claim_id, indemnified_amount_eur FROM core.claims
    WHERE claim_id = (SELECT claim_id FROM core.claims ORDER BY claim_id LIMIT 1);

    ROLLBACK TO SAVEPOINT before_update;
ROLLBACK;

-- SECTION 5 — BUSINESS CASE: contract amendment (avenant)

BEGIN;
    SAVEPOINT before_avenant;

    UPDATE core.contracts
    SET annual_premium_eur = annual_premium_eur * 1.05
    WHERE contract_id = (SELECT contract_id FROM core.contracts
                         WHERE status_id = (SELECT status_id FROM core.ref_contract_statuses WHERE status_name = 'Active')
                         ORDER BY contract_id LIMIT 1);

    SELECT contract_id, annual_premium_eur FROM core.contracts
    WHERE contract_id = (SELECT contract_id FROM core.contracts
                         WHERE status_id = (SELECT status_id FROM core.ref_contract_statuses WHERE status_name = 'Active')
                         ORDER BY contract_id LIMIT 1);
ROLLBACK;

-- SECTION 6 — VERIFY INTEGRITY AFTER TRANSACTIONS

SELECT 'contracts' AS table_name, COUNT(*) FROM core.contracts
UNION ALL SELECT 'claims', COUNT(*) FROM core.claims
UNION ALL SELECT 'vehicles', COUNT(*) FROM core.vehicles
UNION ALL SELECT 'clients', COUNT(*) FROM core.clients;

