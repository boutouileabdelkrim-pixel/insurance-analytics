-- ============================================================
-- 07_tests / 01_data_quality_tests.sql
-- Automated data quality tests on staging and core schemas
-- Phase 29 (ex-Phase 32) — Data Quality Testing
-- ============================================================
-- Each test returns:
--   test_name, status (PASS/FAIL), observed, threshold
-- ============================================================


-- ============================================================
-- SECTION 1 — COMPLETENESS TESTS
-- ============================================================

-- T1. Core tables should have no missing primary keys
SELECT
    'T1_contract_pk_not_null' AS test_name,
    CASE WHEN COUNT(*) FILTER (WHERE contract_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) FILTER (WHERE contract_id IS NULL) AS observed,
    0 AS threshold
FROM core.contracts
UNION ALL
SELECT
    'T1_claim_pk_not_null',
    CASE WHEN COUNT(*) FILTER (WHERE claim_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) FILTER (WHERE claim_id IS NULL),
    0
FROM core.claims
UNION ALL
SELECT
    'T1_vehicle_pk_not_null',
    CASE WHEN COUNT(*) FILTER (WHERE contract_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) FILTER (WHERE contract_id IS NULL),
    0
FROM core.vehicles
UNION ALL
SELECT
    'T1_client_pk_not_null',
    CASE WHEN COUNT(*) FILTER (WHERE client_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) FILTER (WHERE client_id IS NULL),
    0
FROM core.clients;

-- T2. Critical FK columns should not be NULL
SELECT
    'T2_contracts_fk_not_null' AS test_name,
    CASE
        WHEN COUNT(*) FILTER (WHERE client_id IS NULL
                                OR product_id IS NULL
                                OR channel_id IS NULL
                                OR city_id IS NULL
                                OR status_id IS NULL) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    COUNT(*) FILTER (WHERE client_id IS NULL
                        OR product_id IS NULL
                        OR channel_id IS NULL
                        OR city_id IS NULL
                        OR status_id IS NULL) AS observed,
    0 AS threshold
FROM core.contracts
UNION ALL
SELECT
    'T2_claims_fk_not_null',
    CASE
        WHEN COUNT(*) FILTER (WHERE contract_id IS NULL
                                OR claim_type_id IS NULL
                                OR status_id IS NULL) = 0
        THEN 'PASS' ELSE 'FAIL'
    END,
    COUNT(*) FILTER (WHERE contract_id IS NULL
                        OR claim_type_id IS NULL
                        OR status_id IS NULL),
    0
FROM core.claims;


-- ============================================================
-- SECTION 2 — UNIQUENESS TESTS
-- ============================================================

-- T3. Primary keys must be unique
SELECT
    'T3_contract_id_unique' AS test_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT contract_id) THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) - COUNT(DISTINCT contract_id) AS observed,
    0 AS threshold
FROM core.contracts
UNION ALL
SELECT
    'T3_claim_id_unique',
    CASE WHEN COUNT(*) = COUNT(DISTINCT claim_id) THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) - COUNT(DISTINCT claim_id),
    0
FROM core.claims
UNION ALL
SELECT
    'T3_vehicle_contract_id_unique',
    CASE WHEN COUNT(*) = COUNT(DISTINCT contract_id) THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) - COUNT(DISTINCT contract_id),
    0
FROM core.vehicles
UNION ALL
SELECT
    'T3_client_id_unique',
    CASE WHEN COUNT(*) = COUNT(DISTINCT client_id) THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) - COUNT(DISTINCT client_id),
    0
FROM core.clients;

-- T4. Reference tables: names must be unique
SELECT
    'T4_ref_products_unique' AS test_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT product_name) THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) - COUNT(DISTINCT product_name) AS observed,
    0 AS threshold
FROM core.ref_products
UNION ALL
SELECT 'T4_ref_channels_unique',
    CASE WHEN COUNT(*) = COUNT(DISTINCT channel_name) THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) - COUNT(DISTINCT channel_name), 0
FROM core.ref_channels
UNION ALL
SELECT 'T4_ref_csp_unique',
    CASE WHEN COUNT(*) = COUNT(DISTINCT csp_name) THEN 'PASS' ELSE 'FAIL' END,
    COUNT(*) - COUNT(DISTINCT csp_name), 0
FROM core.ref_csp;


-- ============================================================
-- SECTION 3 — VALIDITY TESTS (DOMAIN CONSTRAINTS)
-- ============================================================

-- T5. Gender must be 'M' or 'F' (or NULL)
SELECT
    'T5_gender_valid' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.clients
WHERE gender IS NOT NULL AND gender NOT IN ('M', 'F');

-- T6. Age must be between 0 and 120
SELECT
    'T6_age_valid' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.clients
WHERE client_age IS NOT NULL
  AND (client_age < 0 OR client_age > 120);

-- T7. Premiums must be non-negative
SELECT
    'T7_premium_non_negative' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.contracts
WHERE annual_premium_eur IS NOT NULL AND annual_premium_eur < 0;

-- T8. Damage amounts must be non-negative
SELECT
    'T8_damage_non_negative' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.claims
WHERE damage_amount_eur IS NOT NULL AND damage_amount_eur < 0;

-- T9. Indemnified amount must be non-negative
SELECT
    'T9_indemnified_non_negative' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.claims
WHERE indemnified_amount_eur IS NOT NULL AND indemnified_amount_eur < 0;

-- T10. end_date must be >= start_date
SELECT
    'T10_date_order_valid' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.contracts
WHERE start_date IS NOT NULL
  AND end_date IS NOT NULL
  AND end_date < start_date;

-- T11. Vehicle year must be plausible (1900-2100)
SELECT
    'T11_vehicle_year_valid' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.vehicles
WHERE year IS NOT NULL AND (year < 1900 OR year > 2100);

-- T12. Vehicle power must be positive
SELECT
    'T12_vehicle_power_valid' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.vehicles
WHERE power IS NOT NULL AND power <= 0;


-- ============================================================
-- SECTION 4 — REFERENTIAL INTEGRITY TESTS
-- ============================================================

-- T13. Contracts → clients (no orphans)
SELECT
    'T13_contracts_clients_fk' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.contracts c
LEFT JOIN core.clients cl ON cl.client_id = c.client_id
WHERE cl.client_id IS NULL;

-- T14. Claims → contracts
SELECT
    'T14_claims_contracts_fk' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.claims cl
LEFT JOIN core.contracts c ON c.contract_id = cl.contract_id
WHERE c.contract_id IS NULL;

-- T15. Vehicles → contracts
SELECT
    'T15_vehicles_contracts_fk' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.vehicles v
LEFT JOIN core.contracts c ON c.contract_id = v.contract_id
WHERE c.contract_id IS NULL;

-- T16. Contracts → products
SELECT
    'T16_contracts_products_fk' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.contracts c
LEFT JOIN core.ref_products p ON p.product_id = c.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- SECTION 5 — FRESHNESS TESTS
-- ============================================================

-- T17. Contract dates should not be in the far future (> 1 year)
SELECT
    'T17_contract_dates_fresh' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.contracts
WHERE start_date > (CURRENT_DATE + INTERVAL '1 year');

-- T18. Claims dates should not be in the far future
SELECT
    'T18_claim_dates_fresh' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    COUNT(*) AS observed,
    0 AS threshold
FROM core.claims
WHERE occurrence_date > (CURRENT_DATE + INTERVAL '1 year');


-- ============================================================
-- SECTION 6 — GLOBAL SUMMARY
-- ============================================================

WITH all_tests AS (
    -- Collect all tests as a single result set
    SELECT 'T1_contract_pk_not_null' AS test_name,
           CASE WHEN COUNT(*) FILTER (WHERE contract_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM core.contracts
    UNION ALL
    SELECT 'T1_claim_pk_not_null',
           CASE WHEN COUNT(*) FILTER (WHERE claim_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.claims
    UNION ALL
    SELECT 'T2_contracts_fk_not_null',
           CASE WHEN COUNT(*) FILTER (WHERE client_id IS NULL OR product_id IS NULL
                                        OR channel_id IS NULL OR city_id IS NULL
                                        OR status_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.contracts
    UNION ALL
    SELECT 'T3_contract_id_unique',
           CASE WHEN COUNT(*) = COUNT(DISTINCT contract_id) THEN 'PASS' ELSE 'FAIL' END
    FROM core.contracts
    UNION ALL
    SELECT 'T3_claim_id_unique',
           CASE WHEN COUNT(*) = COUNT(DISTINCT claim_id) THEN 'PASS' ELSE 'FAIL' END
    FROM core.claims
    UNION ALL
    SELECT 'T5_gender_valid',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.clients WHERE gender IS NOT NULL AND gender NOT IN ('M','F')
    UNION ALL
    SELECT 'T6_age_valid',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.clients WHERE client_age IS NOT NULL AND (client_age < 0 OR client_age > 120)
    UNION ALL
    SELECT 'T7_premium_non_negative',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.contracts WHERE annual_premium_eur < 0
    UNION ALL
    SELECT 'T10_date_order_valid',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.contracts WHERE start_date IS NOT NULL AND end_date IS NOT NULL
                          AND end_date < start_date
    UNION ALL
    SELECT 'T13_contracts_clients_fk',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.contracts c LEFT JOIN core.clients cl ON cl.client_id = c.client_id
    WHERE cl.client_id IS NULL
    UNION ALL
    SELECT 'T14_claims_contracts_fk',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.claims cl LEFT JOIN core.contracts c ON c.contract_id = cl.contract_id
    WHERE c.contract_id IS NULL
    UNION ALL
    SELECT 'T15_vehicles_contracts_fk',
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM core.vehicles v LEFT JOIN core.contracts c ON c.contract_id = v.contract_id
    WHERE c.contract_id IS NULL
)
SELECT
    status,
    COUNT(*) AS nb_tests
FROM all_tests
GROUP BY status
ORDER BY status DESC;
