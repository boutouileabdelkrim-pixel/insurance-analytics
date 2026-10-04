-- ============================================================
-- 04_analytics / 09_customer_policy_analytics.sql
-- Customer / Policy Analytics
-- Phase 18 — Customer / Policy Analytics
-- ============================================================

-- SECTION 1 — CLIENT PORTFOLIO

SELECT
    COUNT(DISTINCT client_id)         AS nb_clients,
    COUNT(*)                          AS nb_contracts,
    ROUND(COUNT(*)::numeric
          / NULLIF(COUNT(DISTINCT client_id), 0), 2) AS contracts_per_client
FROM core.contracts;

SELECT
    nb_contracts,
    COUNT(*) AS nb_clients
FROM (
    SELECT client_id, COUNT(*) AS nb_contracts
    FROM core.contracts
    GROUP BY client_id
) t
GROUP BY nb_contracts
ORDER BY nb_contracts;

SELECT
    COALESCE(gender, 'Unknown') AS gender,
    COUNT(*) AS nb_clients
FROM core.clients
GROUP BY gender
ORDER BY nb_clients DESC;

SELECT
    CASE
        WHEN client_age < 25 THEN '<25'
        WHEN client_age < 35 THEN '25-34'
        WHEN client_age < 45 THEN '35-44'
        WHEN client_age < 55 THEN '45-54'
        WHEN client_age < 65 THEN '55-64'
        ELSE '65+'
    END AS age_band,
    COUNT(*) AS nb_clients
FROM core.clients
WHERE client_age IS NOT NULL
GROUP BY 1
ORDER BY 1;

SELECT
    csp.csp_name,
    COUNT(*) AS nb_clients
FROM core.clients cl
JOIN core.ref_csp csp ON csp.csp_id = cl.csp_id
GROUP BY csp.csp_name
ORDER BY nb_clients DESC;

-- SECTION 2 — CONTRACT PORTFOLIO

SELECT
    p.product_name,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
GROUP BY p.product_name
ORDER BY nb_contracts DESC;

SELECT
    ch.channel_name,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.ref_channels ch ON ch.channel_id = c.channel_id
GROUP BY ch.channel_name
ORDER BY nb_contracts DESC;

SELECT
    ci.city_name,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.ref_cities ci ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY nb_contracts DESC
LIMIT 15;

SELECT
    rz.risk_zone_name,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
GROUP BY rz.risk_zone_name
ORDER BY nb_contracts DESC;

-- SECTION 3 — CONTRACT LIFETIME

SELECT
    ROUND(AVG(end_date - start_date), 0)              AS avg_days,
    ROUND(AVG(end_date - start_date) / 30.0, 2)       AS avg_months,
    ROUND(AVG(end_date - start_date) / 365.0, 2)      AS avg_years
FROM core.contracts
WHERE start_date IS NOT NULL
  AND end_date IS NOT NULL;

SELECT
    p.product_name,
    ROUND(AVG(c.end_date - c.start_date), 0) AS avg_duration_days,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
WHERE c.start_date IS NOT NULL AND c.end_date IS NOT NULL
GROUP BY p.product_name
ORDER BY avg_duration_days DESC;

SELECT
    c.contract_id,
    cl.client_name,
    p.product_name,
    c.start_date,
    c.end_date,
    (c.end_date - c.start_date) AS duration_days
FROM core.contracts c
JOIN core.clients cl     ON cl.client_id = c.client_id
JOIN core.ref_products p ON p.product_id = c.product_id
WHERE c.start_date IS NOT NULL AND c.end_date IS NOT NULL
ORDER BY duration_days DESC
LIMIT 10;

-- SECTION 4 — RENEWALS AND CANCELLATIONS

SELECT
    cs.status_name,
    COUNT(*) AS nb_contracts,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM core.contracts c
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY cs.status_name
ORDER BY nb_contracts DESC;

SELECT
    p.product_name,
    cs.status_name,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.ref_products p           ON p.product_id = c.product_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY p.product_name, cs.status_name
ORDER BY p.product_name, nb_contracts DESC;

SELECT
    EXTRACT(YEAR FROM start_date)::int AS year,
    COUNT(*) FILTER (WHERE cs.status_name = 'Renewed')   AS nb_renewed,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS nb_cancelled,
    COUNT(*)                                              AS nb_total
FROM core.contracts c
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
WHERE start_date IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- SECTION 5 — MULTI-EQUIPMENT (MULTI-CONTRACT)

SELECT
    c.client_id,
    cl.client_name,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.clients cl ON cl.client_id = c.client_id
GROUP BY c.client_id, cl.client_name
HAVING COUNT(*) > 1
ORDER BY nb_contracts DESC
LIMIT 20;

SELECT
    c.client_id,
    cl.client_name,
    COUNT(DISTINCT c.product_id) AS nb_products
FROM core.contracts c
JOIN core.clients cl ON cl.client_id = c.client_id
GROUP BY c.client_id, cl.client_name
HAVING COUNT(DISTINCT c.product_id) > 1
ORDER BY nb_products DESC
LIMIT 20;

-- SECTION 6 — CUSTOMER VALUE

SELECT
    c.client_id,
    cl.client_name,
    COUNT(*)                             AS nb_contracts,
    ROUND(SUM(c.annual_premium_eur), 2)  AS total_premium
FROM core.contracts c
JOIN core.clients cl ON cl.client_id = c.client_id
GROUP BY c.client_id, cl.client_name
ORDER BY total_premium DESC
LIMIT 20;

SELECT
    c.client_id,
    cl.client_name,
    COUNT(cl2.claim_id)                       AS nb_claims,
    ROUND(SUM(cl2.indemnified_amount_eur), 2) AS total_indemnified
FROM core.contracts c
JOIN core.clients cl ON cl.client_id = c.client_id
JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
GROUP BY c.client_id, cl.client_name
ORDER BY total_indemnified DESC
LIMIT 20;

WITH client_premium AS (
    SELECT client_id, SUM(annual_premium_eur) AS premium
    FROM core.contracts
    GROUP BY client_id
),
client_claims AS (
    SELECT c.client_id, SUM(cl.indemnified_amount_eur) AS claims
    FROM core.contracts c
    JOIN core.claims cl ON cl.contract_id = c.contract_id
    GROUP BY c.client_id
)
SELECT
    cp.client_id,
    ROUND(cp.premium, 2)                    AS total_premium,
    ROUND(COALESCE(cc.claims, 0), 2)        AS total_claims,
    ROUND(COALESCE(cc.claims, 0) - cp.premium, 2) AS margin
FROM client_premium cp
LEFT JOIN client_claims cc ON cc.client_id = cp.client_id
WHERE COALESCE(cc.claims, 0) > cp.premium
ORDER BY margin DESC
LIMIT 20;

-- SECTION 7 — CHURN RISK

SELECT
    p.product_name,
    COUNT(*) AS nb_cancelled
FROM core.contracts c
JOIN core.ref_products p           ON p.product_id = c.product_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
WHERE cs.status_name = 'Cancelled'
GROUP BY p.product_name
ORDER BY nb_cancelled DESC;

SELECT
    p.product_name,
    COUNT(*)                                              AS total_contracts,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')  AS cancelled,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
        / NULLIF(COUNT(*), 0), 2
    ) AS churn_pct
FROM core.contracts c
JOIN core.ref_products p           ON p.product_id = c.product_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY p.product_name
ORDER BY churn_pct DESC;
