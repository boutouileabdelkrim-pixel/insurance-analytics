-- ============================================================
-- 04_analytics / 04_cte.sql
-- Master Common Table Expressions
-- Phase 13 — CTE
-- ============================================================


-- ============================================================
-- SECTION 1 — SIMPLE CTE
-- ============================================================

-- Q1. Simple CTE: contracts with premium > avg
WITH avg_premium AS (
    SELECT AVG(annual_premium_eur) AS avg_val FROM core.contracts
)
SELECT c.contract_id, c.annual_premium_eur
FROM core.contracts c, avg_premium ap
WHERE c.annual_premium_eur > ap.avg_val
ORDER BY c.annual_premium_eur DESC
LIMIT 20;

-- Q2. Simple CTE: claims grouped by type
WITH claims_by_type AS (
    SELECT claim_type_id, COUNT(*) AS nb_claims
    FROM core.claims
    GROUP BY claim_type_id
)
SELECT ct.claim_type_name, cbt.nb_claims
FROM claims_by_type cbt
JOIN core.ref_claim_types ct ON ct.claim_type_id = cbt.claim_type_id
ORDER BY cbt.nb_claims DESC;


-- ============================================================
-- SECTION 2 — MULTIPLE CHAINED CTEs
-- ============================================================

-- Q3. Contracts joined with client, product, city, then aggregated by risk zone
WITH contract_details AS (
    SELECT
        c.contract_id,
        c.annual_premium_eur,
        p.product_name,
        ci.city_name,
        rz.risk_zone_name
    FROM core.contracts c
    JOIN core.ref_products p   ON p.product_id = c.product_id
    JOIN core.ref_cities   ci  ON ci.city_id   = c.city_id
    JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
),
zone_stats AS (
    SELECT
        risk_zone_name,
        COUNT(*) AS nb_contracts,
        ROUND(AVG(annual_premium_eur), 2) AS avg_premium
    FROM contract_details
    GROUP BY risk_zone_name
)
SELECT * FROM zone_stats
ORDER BY avg_premium DESC;

-- Q4. Clients → contracts → claims pipeline
WITH client_contracts AS (
    SELECT client_id, COUNT(*) AS nb_contracts
    FROM core.contracts
    GROUP BY client_id
),
contract_claims AS (
    SELECT c.client_id, COUNT(cl.claim_id) AS nb_claims
    FROM core.contracts c
    LEFT JOIN core.claims cl ON cl.contract_id = c.contract_id
    GROUP BY c.client_id
)
SELECT
    cc.client_id,
    cc.nb_contracts,
    ccl.nb_claims
FROM client_contracts cc
JOIN contract_claims ccl ON ccl.client_id = cc.client_id
ORDER BY ccl.nb_claims DESC, cc.client_id
LIMIT 20;


-- ============================================================
-- SECTION 3 — RECURSIVE CTE
-- ============================================================

-- Q5. Generate a sequence of numbers 1..10 (educational)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT * FROM numbers;

-- Q6. Generate monthly buckets covering the contract date range
WITH RECURSIVE months AS (
    SELECT MIN(date_trunc('month', start_date))::date AS month_start
    FROM core.contracts
    UNION ALL
    SELECT (month_start + INTERVAL '1 month')::date
    FROM months
    WHERE month_start < (SELECT MAX(date_trunc('month', end_date))::date FROM core.contracts)
)
SELECT month_start FROM months ORDER BY month_start;


-- ============================================================
-- SECTION 4 — CTE REFERENCED MULTIPLE TIMES
-- ============================================================

-- Q7. Product stats referenced twice (per-product avg + delta)
WITH product_stats AS (
    SELECT
        product_id,
        AVG(annual_premium_eur) AS avg_premium,
        MAX(annual_premium_eur) AS max_premium
    FROM core.contracts
    GROUP BY product_id
)
SELECT
    p.product_name,
    ps.avg_premium,
    ps.max_premium,
    ps.max_premium - ps.avg_premium AS delta
FROM product_stats ps
JOIN core.ref_products p ON p.product_id = ps.product_id
ORDER BY delta DESC;


-- ============================================================
-- SECTION 5 — CTE vs SUBQUERY (comparison)
-- ============================================================

-- Q8. Same query, CTE version
WITH top_clients AS (
    SELECT client_id, COUNT(*) AS nb_contracts
    FROM core.contracts
    GROUP BY client_id
)
SELECT * FROM top_clients WHERE nb_contracts > 1 ORDER BY nb_contracts DESC;

-- Q9. Same query, subquery version
SELECT * FROM (
    SELECT client_id, COUNT(*) AS nb_contracts
    FROM core.contracts
    GROUP BY client_id
) t
WHERE nb_contracts > 1
ORDER BY nb_contracts DESC;


-- ============================================================
-- SECTION 6 — REFACTORING COMPLEX QUERIES
-- ============================================================

-- Q10. Full loss-ratio per product using CTE pipeline
WITH claims_per_contract AS (
    SELECT
        contract_id,
        COUNT(*) AS nb_claims,
        SUM(indemnified_amount_eur) AS total_indemnified
    FROM core.claims
    GROUP BY contract_id
),
contracts_with_product AS (
    SELECT
        c.contract_id,
        p.product_name,
        c.annual_premium_eur,
        COALESCE(cpc.nb_claims, 0) AS nb_claims,
        COALESCE(cpc.total_indemnified, 0) AS total_indemnified
    FROM core.contracts c
    JOIN core.ref_products p ON p.product_id = c.product_id
    LEFT JOIN claims_per_contract cpc ON cpc.contract_id = c.contract_id
),
loss_ratio_per_product AS (
    SELECT
        product_name,
        COUNT(*) AS nb_contracts,
        ROUND(SUM(annual_premium_eur), 2) AS total_premium,
        ROUND(SUM(total_indemnified), 2) AS total_claims,
        ROUND(SUM(total_indemnified) / NULLIF(SUM(annual_premium_eur), 0), 4) AS loss_ratio
    FROM contracts_with_product
    GROUP BY product_name
)
SELECT * FROM loss_ratio_per_product ORDER BY loss_ratio DESC;

-- Q11. Claims severity per product using multi-step CTE
WITH claim_details AS (
    SELECT
        cl.claim_id,
        p.product_name,
        cl.damage_amount_eur,
        cl.indemnified_amount_eur
    FROM core.claims cl
    JOIN core.contracts c    ON c.contract_id = cl.contract_id
    JOIN core.ref_products p ON p.product_id  = c.product_id
),
product_severity AS (
    SELECT
        product_name,
        COUNT(*) AS nb_claims,
        ROUND(AVG(damage_amount_eur), 2) AS avg_damage,
        ROUND(AVG(indemnified_amount_eur), 2) AS avg_indemnified
    FROM claim_details
    GROUP BY product_name
)
SELECT * FROM product_severity ORDER BY avg_damage DESC;

-- Q12. Multi-CTE: portfolio summary per channel
WITH contracts_by_channel AS (
    SELECT ch.channel_name, COUNT(*) AS nb_contracts, SUM(c.annual_premium_eur) AS premium
    FROM core.contracts c
    JOIN core.ref_channels ch ON ch.channel_id = c.channel_id
    GROUP BY ch.channel_name
),
claims_by_channel AS (
    SELECT ch.channel_name, COUNT(cl.claim_id) AS nb_claims
    FROM core.contracts c
    JOIN core.ref_channels ch ON ch.channel_id = c.channel_id
    LEFT JOIN core.claims cl ON cl.contract_id = c.contract_id
    GROUP BY ch.channel_name
)
SELECT
    cbc.channel_name,
    cbc.nb_contracts,
    cbc.premium,
    clc.nb_claims,
    ROUND(clc.nb_claims::numeric / NULLIF(cbc.nb_contracts, 0), 4) AS claim_frequency
FROM contracts_by_channel cbc
JOIN claims_by_channel clc ON clc.channel_name = cbc.channel_name
ORDER BY claim_frequency DESC;


-- ============================================================
-- END
-- ============================================================
