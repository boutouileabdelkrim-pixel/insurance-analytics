-- ============================================================
-- Case Study 2 — Churn & Retention
-- Question: Who churns? Why? Which segments to prioritize?
-- ============================================================

-- STEP 1 — Global churn rate
SELECT
    COUNT(*) AS total_contracts,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id;

-- STEP 2 — Churn by product
SELECT
    p.product_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_products p           ON p.product_id = c.product_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY p.product_name
ORDER BY churn_pct DESC;

-- STEP 3 — Churn by channel
SELECT
    ch.channel_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_channels ch          ON ch.channel_id = c.channel_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY ch.channel_name
ORDER BY churn_pct DESC;

-- STEP 4 — Churn by risk zone
SELECT
    rz.risk_zone_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_cities ci            ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz        ON rz.risk_zone_id = ci.risk_zone_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY rz.risk_zone_name
ORDER BY churn_pct DESC;

-- STEP 5 — Churn by age band
SELECT
    CASE
        WHEN cl.client_age < 25 THEN '<25'
        WHEN cl.client_age < 35 THEN '25-34'
        WHEN cl.client_age < 45 THEN '35-44'
        WHEN cl.client_age < 55 THEN '45-54'
        WHEN cl.client_age < 65 THEN '55-64'
        ELSE '65+'
    END AS age_band,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.clients cl               ON cl.client_id = c.client_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
WHERE cl.client_age IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- STEP 6 — Churn by CSP
SELECT
    csp.csp_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.clients cl               ON cl.client_id = c.client_id
JOIN core.ref_csp csp              ON csp.csp_id = cl.csp_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY csp.csp_name
ORDER BY churn_pct DESC;

