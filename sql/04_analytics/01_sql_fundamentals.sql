-- ============================================================
-- 04_analytics / 01_sql_fundamentals.sql
-- Fundamentals: SELECT, WHERE, ORDER BY, aggregates, GROUP BY,
-- HAVING, NULL, CASE, UNION/INTERSECT/EXCEPT
-- Phase 10 — Applied Fundamental SQL
-- ============================================================


-- ============================================================
-- SECTION 1 — SELECTION AND PROJECTION
-- ============================================================

-- Q1. List the first 20 contracts with their client name and premium
SELECT contract_id, client_id, annual_premium_eur
FROM core.contracts
ORDER BY contract_id
LIMIT 20;

-- Q2. List all distinct products (name + id)
SELECT product_id, product_name
FROM core.ref_products
ORDER BY product_id;

-- Q3. List all reference statuses for contracts
SELECT status_id, status_name
FROM core.ref_contract_statuses
ORDER BY status_id;


-- ============================================================
-- SECTION 2 — FILTERING (WHERE)
-- ============================================================

-- Q4. Contracts with premium > 2000 EUR
SELECT contract_id, annual_premium_eur
FROM core.contracts
WHERE annual_premium_eur > 2000
ORDER BY annual_premium_eur DESC
LIMIT 20;

-- Q5. Female clients with a known socio-professional category
SELECT client_id, client_name, client_age, gender
FROM core.clients
WHERE gender = 'F'
  AND csp_id IS NOT NULL
LIMIT 20;

-- Q6. Auto contracts signed in 2024
SELECT c.contract_id, p.product_name, c.start_date, c.annual_premium_eur
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
WHERE p.product_name = 'Auto'
  AND c.start_date >= '2024-01-01'
  AND c.start_date <  '2025-01-01'
ORDER BY c.start_date
LIMIT 20;


-- ============================================================
-- SECTION 3 — SORTING AND LIMITING
-- ============================================================

-- Q7. Top 10 most expensive contracts
SELECT contract_id, annual_premium_eur
FROM core.contracts
ORDER BY annual_premium_eur DESC NULLS LAST
LIMIT 10;

-- Q8. Top 10 claims by damage amount
SELECT claim_id, damage_amount_eur, indemnified_amount_eur
FROM core.claims
ORDER BY damage_amount_eur DESC NULLS LAST
LIMIT 10;


-- ============================================================
-- SECTION 4 — SIMPLE AGGREGATES
-- ============================================================

-- Q9. Global statistics on contracts
SELECT
    COUNT(*)                          AS nb_contracts,
    ROUND(AVG(annual_premium_eur), 2) AS avg_premium,
    MIN(annual_premium_eur)           AS min_premium,
    MAX(annual_premium_eur)           AS max_premium,
    ROUND(SUM(annual_premium_eur), 2) AS total_premium
FROM core.contracts;

-- Q10. Global statistics on claims
SELECT
    COUNT(*)                             AS nb_claims,
    ROUND(AVG(damage_amount_eur), 2)     AS avg_damage,
    ROUND(AVG(indemnified_amount_eur),2) AS avg_indemnified,
    ROUND(SUM(indemnified_amount_eur),2) AS total_indemnified
FROM core.claims;


-- ============================================================
-- SECTION 5 — GROUP BY AND HAVING
-- ============================================================

-- Q11. Number of contracts and average premium per product
SELECT
    p.product_name,
    COUNT(*)                          AS nb_contracts,
    ROUND(AVG(c.annual_premium_eur),2) AS avg_premium
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
GROUP BY p.product_name
ORDER BY nb_contracts DESC;

-- Q12. Claim count per claim_type, keeping only types with > 20 claims
SELECT
    ct.claim_type_name,
    COUNT(*) AS nb_claims
FROM core.claims c
JOIN core.ref_claim_types ct ON ct.claim_type_id = c.claim_type_id
GROUP BY ct.claim_type_name
HAVING COUNT(*) > 20
ORDER BY nb_claims DESC;

-- Q13. Contracts per risk zone (only zones with avg premium > 900)
SELECT
    rz.risk_zone_name,
    COUNT(*)                           AS nb_contracts,
    ROUND(AVG(c.annual_premium_eur),2) AS avg_premium
FROM core.contracts c
JOIN core.ref_cities ci ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
GROUP BY rz.risk_zone_name
HAVING AVG(c.annual_premium_eur) > 900
ORDER BY avg_premium DESC;


-- ============================================================
-- SECTION 6 — NULL HANDLING
-- ============================================================

-- Q14. Clients with missing age, grouped by gender
SELECT
    COALESCE(gender, 'Unknown') AS gender,
    COUNT(*)                    AS nb_missing_age
FROM core.clients
WHERE client_age IS NULL
GROUP BY gender
ORDER BY nb_missing_age DESC;

-- Q15. Claims without a liability set
SELECT claim_id, contract_id, damage_amount_eur
FROM core.claims
WHERE liability_id IS NULL
LIMIT 20;


-- ============================================================
-- SECTION 7 — CASE EXPRESSIONS
-- ============================================================

-- Q16. Classify contracts by premium band
SELECT
    contract_id,
    annual_premium_eur,
    CASE
        WHEN annual_premium_eur <  500 THEN 'Low'
        WHEN annual_premium_eur < 1000 THEN 'Medium'
        WHEN annual_premium_eur < 2000 THEN 'High'
        ELSE 'Very high'
    END AS premium_band
FROM core.contracts
ORDER BY annual_premium_eur DESC
LIMIT 20;

-- Q17. Count of contracts per premium band
SELECT
    CASE
        WHEN annual_premium_eur <  500 THEN 'Low'
        WHEN annual_premium_eur < 1000 THEN 'Medium'
        WHEN annual_premium_eur < 2000 THEN 'High'
        ELSE 'Very high'
    END AS premium_band,
    COUNT(*) AS nb_contracts
FROM core.contracts
GROUP BY 1
ORDER BY 2 DESC;


-- ============================================================
-- SECTION 8 — SET OPERATORS
-- ============================================================

-- Q18. Products that have both contracts and claims (INTERSECT)
SELECT p.product_name
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
INTERSECT
SELECT p.product_name
FROM core.claims cl
JOIN core.contracts c ON c.contract_id = cl.contract_id
JOIN core.ref_products p ON p.product_id = c.product_id
ORDER BY product_name;

-- Q19. Products with contracts but no claims (EXCEPT)
SELECT p.product_name
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
EXCEPT
SELECT p.product_name
FROM core.claims cl
JOIN core.contracts c ON c.contract_id = cl.contract_id
JOIN core.ref_products p ON p.product_id = c.product_id
ORDER BY product_name;

-- Q20. Combined list of all statuses (contracts + claims) via UNION
SELECT 'contract' AS source, status_name FROM core.ref_contract_statuses
UNION
SELECT 'claim'    AS source, status_name FROM core.ref_claim_statuses
ORDER BY source, status_name;


-- ============================================================
-- END
-- ============================================================
