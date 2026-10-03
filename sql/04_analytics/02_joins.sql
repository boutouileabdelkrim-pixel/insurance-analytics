-- ============================================================
-- 04_analytics / 02_joins.sql
-- Master all JOIN types with business-oriented queries
-- Phase 11 — JOINs
-- ============================================================


-- ============================================================
-- SECTION 1 — INNER JOIN
-- ============================================================

-- Q1. Contracts with client name and product name
SELECT
    c.contract_id,
    cl.client_name,
    p.product_name,
    c.annual_premium_eur
FROM core.contracts c
INNER JOIN core.clients  cl ON cl.client_id  = c.client_id
INNER JOIN core.ref_products p ON p.product_id = c.product_id
ORDER BY c.contract_id
LIMIT 20;

-- Q2. Claims with contract and product info
SELECT
    cl.claim_id,
    cl.contract_id,
    p.product_name,
    ct.claim_type_name,
    cl.damage_amount_eur
FROM core.claims cl
INNER JOIN core.contracts c     ON c.contract_id    = cl.contract_id
INNER JOIN core.ref_products p  ON p.product_id     = c.product_id
INNER JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
ORDER BY cl.claim_id
LIMIT 20;


-- ============================================================
-- SECTION 2 — LEFT JOIN
-- ============================================================

-- Q3. All contracts, with claim count (0 if no claim)
SELECT
    c.contract_id,
    COUNT(cl.claim_id) AS nb_claims
FROM core.contracts c
LEFT JOIN core.claims cl ON cl.contract_id = c.contract_id
GROUP BY c.contract_id
ORDER BY nb_claims DESC, c.contract_id
LIMIT 20;

-- Q4. Contracts without any claim
SELECT c.contract_id
FROM core.contracts c
LEFT JOIN core.claims cl ON cl.contract_id = c.contract_id
WHERE cl.claim_id IS NULL
ORDER BY c.contract_id
LIMIT 20;

-- Q5. Clients with their contract count (0 if none)
SELECT
    cl.client_id,
    cl.client_name,
    COUNT(c.contract_id) AS nb_contracts
FROM core.clients cl
LEFT JOIN core.contracts c ON c.client_id = cl.client_id
GROUP BY cl.client_id, cl.client_name
ORDER BY nb_contracts DESC, cl.client_id
LIMIT 20;


-- ============================================================
-- SECTION 3 — RIGHT JOIN
-- ============================================================

-- Q6. All products with their contract count (even products with no contract)
SELECT
    p.product_name,
    COUNT(c.contract_id) AS nb_contracts
FROM core.contracts c
RIGHT JOIN core.ref_products p ON p.product_id = c.product_id
GROUP BY p.product_name
ORDER BY nb_contracts DESC;


-- ============================================================
-- SECTION 4 — FULL OUTER JOIN
-- ============================================================

-- Q7. Products: contracts vs claims coverage
SELECT
    COALESCE(pc.product_name, pcl.product_name) AS product_name,
    pc.nb_contracts,
    pcl.nb_claims
FROM (
    SELECT p.product_name, COUNT(*) AS nb_contracts
    FROM core.contracts c
    JOIN core.ref_products p ON p.product_id = c.product_id
    GROUP BY p.product_name
) pc
FULL OUTER JOIN (
    SELECT p.product_name, COUNT(*) AS nb_claims
    FROM core.claims cl
    JOIN core.contracts c ON c.contract_id = cl.contract_id
    JOIN core.ref_products p ON p.product_id = c.product_id
    GROUP BY p.product_name
) pcl
ON pc.product_name = pcl.product_name
ORDER BY product_name;


-- ============================================================
-- SECTION 5 — CROSS JOIN (controlled)
-- ============================================================

-- Q8. All product × channel combinations (grid for coverage analysis)
SELECT
    p.product_name,
    ch.channel_name
FROM core.ref_products p
CROSS JOIN core.ref_channels ch
ORDER BY p.product_name, ch.channel_name;


-- ============================================================
-- SECTION 6 — SELF JOIN
-- ============================================================

-- Q9. Contracts sharing the same client (potential multi-contract clients)
SELECT
    c1.client_id,
    c1.contract_id AS contract_1,
    c2.contract_id AS contract_2
FROM core.contracts c1
INNER JOIN core.contracts c2
    ON c1.client_id = c2.client_id
   AND c1.contract_id < c2.contract_id
ORDER BY c1.client_id
LIMIT 20;

-- Q10. Claims sharing the same expert (potential fraud signal)
SELECT
    cl1.expert_id,
    cl1.claim_id AS claim_1,
    cl2.claim_id AS claim_2
FROM core.claims cl1
INNER JOIN core.claims cl2
    ON cl1.expert_id = cl2.expert_id
   AND cl1.claim_id < cl2.claim_id
WHERE cl1.expert_id IS NOT NULL
ORDER BY cl1.expert_id
LIMIT 20;


-- ============================================================
-- SECTION 7 — MULTI-TABLE JOIN (4+ tables)
-- ============================================================

-- Q11. Full contract profile: client, product, channel, city, risk zone
SELECT
    c.contract_id,
    cl.client_name,
    p.product_name,
    ch.channel_name,
    ci.city_name,
    rz.risk_zone_name,
    c.annual_premium_eur
FROM core.contracts c
JOIN core.clients              cl ON cl.client_id  = c.client_id
JOIN core.ref_products         p  ON p.product_id  = c.product_id
JOIN core.ref_channels         ch ON ch.channel_id = c.channel_id
JOIN core.ref_cities           ci ON ci.city_id    = c.city_id
JOIN core.ref_risk_zones       rz ON rz.risk_zone_id = ci.risk_zone_id
ORDER BY c.contract_id
LIMIT 20;

-- Q12. Full claim profile
SELECT
    cl.claim_id,
    c.contract_id,
    p.product_name,
    ct.claim_type_name,
    cs.status_name,
    cli.liability_name,
    cl.damage_amount_eur,
    cl.indemnified_amount_eur
FROM core.claims cl
JOIN core.contracts           c   ON c.contract_id   = cl.contract_id
JOIN core.ref_products        p   ON p.product_id    = c.product_id
JOIN core.ref_claim_types     ct  ON ct.claim_type_id = cl.claim_type_id
JOIN core.ref_claim_statuses  cs  ON cs.status_id    = cl.status_id
LEFT JOIN core.ref_liabilities cli ON cli.liability_id = cl.liability_id
ORDER BY cl.claim_id
LIMIT 20;


-- ============================================================
-- SECTION 8 — COMPOSITE KEY JOIN
-- ============================================================

-- Q13. Contracts matched to cities via (city_name, postal_code)
SELECT
    c.contract_id,
    ci.city_name,
    ci.postal_code,
    rz.risk_zone_name
FROM core.contracts c
JOIN core.ref_cities ci
    ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz
    ON rz.risk_zone_id = ci.risk_zone_id
ORDER BY c.contract_id
LIMIT 20;


-- ============================================================
-- SECTION 9 — ANTI-JOIN (detect anomalies)
-- ============================================================

-- Q14. Contracts with no associated vehicle (should be non-Auto only)
SELECT
    c.contract_id,
    p.product_name
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
LEFT JOIN core.vehicles v ON v.contract_id = c.contract_id
WHERE v.contract_id IS NULL
ORDER BY p.product_name, c.contract_id
LIMIT 30;

-- Q15. Auto contracts WITHOUT a vehicle (anomaly)
SELECT c.contract_id
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
LEFT JOIN core.vehicles v ON v.contract_id = c.contract_id
WHERE p.product_name = 'Auto'
  AND v.contract_id IS NULL
ORDER BY c.contract_id
LIMIT 20;


-- ============================================================
-- END
-- ============================================================
