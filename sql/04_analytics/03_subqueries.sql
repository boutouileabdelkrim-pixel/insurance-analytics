-- ============================================================
-- 04_analytics / 03_subqueries.sql
-- Master subqueries: scalar, IN, EXISTS, derived tables, correlated
-- Phase 12 — Subqueries
-- ============================================================


-- ============================================================
-- SECTION 1 — SCALAR SUBQUERY
-- ============================================================

-- Q1. Contracts with premium above the global average
SELECT contract_id, annual_premium_eur
FROM core.contracts
WHERE annual_premium_eur > (
    SELECT AVG(annual_premium_eur) FROM core.contracts
)
ORDER BY annual_premium_eur DESC
LIMIT 20;

-- Q2. Claims with damage above the global average damage
SELECT claim_id, damage_amount_eur
FROM core.claims
WHERE damage_amount_eur > (
    SELECT AVG(damage_amount_eur) FROM core.claims
)
ORDER BY damage_amount_eur DESC
LIMIT 20;


-- ============================================================
-- SECTION 2 — SUBQUERY IN WHERE (IN / NOT IN)
-- ============================================================

-- Q3. Contracts belonging to clients with a CSP known
SELECT contract_id, client_id
FROM core.contracts
WHERE client_id IN (
    SELECT client_id FROM core.clients WHERE csp_id IS NOT NULL
)
ORDER BY contract_id
LIMIT 20;

-- Q4. Clients who never had a claim
SELECT client_id, client_name
FROM core.clients
WHERE client_id NOT IN (
    SELECT c.client_id
    FROM core.contracts c
    JOIN core.claims cl ON cl.contract_id = c.contract_id
)
ORDER BY client_id
LIMIT 20;

-- Q5. Contracts that generated at least one claim
SELECT contract_id
FROM core.contracts
WHERE contract_id IN (
    SELECT DISTINCT contract_id FROM core.claims
)
ORDER BY contract_id
LIMIT 20;


-- ============================================================
-- SECTION 3 — EXISTS / NOT EXISTS
-- ============================================================

-- Q6. Contracts with at least one claim (EXISTS)
SELECT c.contract_id
FROM core.contracts c
WHERE EXISTS (
    SELECT 1 FROM core.claims cl WHERE cl.contract_id = c.contract_id
)
ORDER BY c.contract_id
LIMIT 20;

-- Q7. Contracts with no claim (NOT EXISTS)
SELECT c.contract_id
FROM core.contracts c
WHERE NOT EXISTS (
    SELECT 1 FROM core.claims cl WHERE cl.contract_id = c.contract_id
)
ORDER BY c.contract_id
LIMIT 20;

-- Q8. Clients who have at least one Auto contract
SELECT cl.client_id, cl.client_name
FROM core.clients cl
WHERE EXISTS (
    SELECT 1
    FROM core.contracts c
    JOIN core.ref_products p ON p.product_id = c.product_id
    WHERE c.client_id = cl.client_id
      AND p.product_name = 'Auto'
)
ORDER BY cl.client_id
LIMIT 20;


-- ============================================================
-- SECTION 4 — SUBQUERY IN FROM (DERIVED TABLE)
-- ============================================================

-- Q9. Average premium per product via derived table
SELECT
    t.product_id,
    ROUND(AVG(t.annual_premium_eur), 2) AS avg_premium
FROM (
    SELECT product_id, annual_premium_eur
    FROM core.contracts
    WHERE annual_premium_eur IS NOT NULL
) t
GROUP BY t.product_id
ORDER BY t.product_id;

-- Q10. Contracts with premium above their product's average
SELECT
    c.contract_id,
    c.product_id,
    c.annual_premium_eur
FROM core.contracts c
JOIN (
    SELECT product_id, AVG(annual_premium_eur) AS avg_premium
    FROM core.contracts
    GROUP BY product_id
) pa ON pa.product_id = c.product_id
WHERE c.annual_premium_eur > pa.avg_premium
ORDER BY c.contract_id
LIMIT 20;


-- ============================================================
-- SECTION 5 — SUBQUERY IN SELECT
-- ============================================================

-- Q11. Each contract with its client's total contract count
SELECT
    c.contract_id,
    c.client_id,
    (
        SELECT COUNT(*)
        FROM core.contracts c2
        WHERE c2.client_id = c.client_id
    ) AS client_total_contracts
FROM core.contracts c
ORDER BY c.contract_id
LIMIT 20;

-- Q12. Each claim with the average damage of its claim type
SELECT
    cl.claim_id,
    cl.claim_type_id,
    cl.damage_amount_eur,
    (
        SELECT ROUND(AVG(cl2.damage_amount_eur), 2)
        FROM core.claims cl2
        WHERE cl2.claim_type_id = cl.claim_type_id
    ) AS avg_type_damage
FROM core.claims cl
ORDER BY cl.claim_id
LIMIT 20;


-- ============================================================
-- SECTION 6 — CORRELATED SUBQUERY
-- ============================================================

-- Q13. Contracts whose premium is above the average of their own product
SELECT c.contract_id, c.product_id, c.annual_premium_eur
FROM core.contracts c
WHERE c.annual_premium_eur > (
    SELECT AVG(c2.annual_premium_eur)
    FROM core.contracts c2
    WHERE c2.product_id = c.product_id
)
ORDER BY c.contract_id
LIMIT 20;

-- Q14. Clients whose contract count is above the global average
SELECT cl.client_id, cl.client_name
FROM core.clients cl
WHERE (
    SELECT COUNT(*)
    FROM core.contracts c
    WHERE c.client_id = cl.client_id
) > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM core.contracts GROUP BY client_id
    ) x
)
ORDER BY cl.client_id
LIMIT 20;


-- ============================================================
-- SECTION 7 — COMPARISON: SUBQUERY vs JOIN
-- ============================================================

-- Q15. Contracts with at least one claim — subquery version
SELECT c.contract_id
FROM core.contracts c
WHERE c.contract_id IN (
    SELECT DISTINCT contract_id FROM core.claims
)
ORDER BY c.contract_id
LIMIT 20;

-- Q16. Same as Q15 but with JOIN (usually faster)
SELECT DISTINCT c.contract_id
FROM core.contracts c
JOIN core.claims cl ON cl.contract_id = c.contract_id
ORDER BY c.contract_id
LIMIT 20;


-- ============================================================
-- SECTION 8 — ADVANCED BUSINESS SUBQUERIES
-- ============================================================

-- Q17. Claims declared BEFORE their occurrence date (anomaly)
SELECT
    cl.claim_id,
    cl.occurrence_date,
    cl.declaration_date
FROM core.claims cl
WHERE cl.declaration_date < cl.occurrence_date
ORDER BY cl.claim_id
LIMIT 20;

-- Q18. Claims where damage_amount is the maximum for its claim_type
SELECT cl.claim_id, cl.claim_type_id, cl.damage_amount_eur
FROM core.claims cl
WHERE cl.damage_amount_eur = (
    SELECT MAX(cl2.damage_amount_eur)
    FROM core.claims cl2
    WHERE cl2.claim_type_id = cl.claim_type_id
)
ORDER BY cl.claim_id
LIMIT 20;

-- Q19. Clients with an average premium above 1000 EUR
SELECT cl.client_id, cl.client_name
FROM core.clients cl
WHERE (
    SELECT AVG(c.annual_premium_eur)
    FROM core.contracts c
    WHERE c.client_id = cl.client_id
) > 1000
ORDER BY cl.client_id
LIMIT 20;

-- Q20. Contracts whose premium is in the top 10% of their product
SELECT c.contract_id, c.product_id, c.annual_premium_eur
FROM core.contracts c
WHERE c.annual_premium_eur >= (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY c2.annual_premium_eur)
    FROM core.contracts c2
    WHERE c2.product_id = c.product_id
      AND c2.annual_premium_eur IS NOT NULL
)
ORDER BY c.product_id, c.annual_premium_eur DESC
LIMIT 20;


-- ============================================================
-- END
-- ============================================================
