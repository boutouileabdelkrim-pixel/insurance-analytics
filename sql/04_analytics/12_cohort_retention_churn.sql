-- ============================================================
-- 04_analytics / 12_cohort_retention_churn.sql
-- Cohort / Retention / Churn Analytics
-- Phase 21
-- ============================================================

-- SECTION 1 — COHORTS

SELECT
    EXTRACT(YEAR FROM start_date)::int AS cohort_year,
    COUNT(*) AS nb_contracts,
    COUNT(DISTINCT client_id) AS nb_clients
FROM core.contracts
WHERE start_date IS NOT NULL
GROUP BY 1 ORDER BY 1;

SELECT
    EXTRACT(YEAR FROM c.start_date)::int AS cohort_year,
    cs.status_name,
    COUNT(*) AS nb_contracts
FROM core.contracts c
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
WHERE c.start_date IS NOT NULL
GROUP BY 1, 2 ORDER BY 1, 2;

-- SECTION 2 — RETENTION RATES

SELECT
    EXTRACT(YEAR FROM start_date)::int AS cohort_year,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name IN ('Active', 'Renewed')) AS retained,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name IN ('Active', 'Renewed'))
          / NULLIF(COUNT(*), 0), 2) AS retention_pct
FROM core.contracts c
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
WHERE c.start_date IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- SECTION 3 — CHURN RATES

SELECT
    EXTRACT(YEAR FROM start_date)::int AS cohort_year,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
WHERE c.start_date IS NOT NULL
GROUP BY 1 ORDER BY 1;

SELECT
    p.product_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY p.product_name ORDER BY churn_pct DESC;

SELECT
    ch.channel_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_channels ch ON ch.channel_id = c.channel_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY ch.channel_name ORDER BY churn_pct DESC;

SELECT
    rz.risk_zone_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_cities ci ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY rz.risk_zone_name ORDER BY churn_pct DESC;

-- SECTION 4 — LTV BY COHORT

SELECT
    EXTRACT(YEAR FROM start_date)::int AS cohort_year,
    COUNT(DISTINCT client_id) AS nb_clients,
    ROUND(SUM(annual_premium_eur), 2) AS total_premium,
    ROUND(SUM(annual_premium_eur) / NULLIF(COUNT(DISTINCT client_id), 0), 2) AS ltv
FROM core.contracts
WHERE start_date IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- SECTION 5 — CHURN FACTORS

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
JOIN core.clients cl ON cl.client_id = c.client_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
WHERE cl.client_age IS NOT NULL
GROUP BY 1 ORDER BY 1;

SELECT
    csp.csp_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.clients cl ON cl.client_id = c.client_id
JOIN core.ref_csp csp ON csp.csp_id = cl.csp_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY csp.csp_name ORDER BY churn_pct DESC;

-- SECTION 6 — COHORT COMPARISON

WITH cohort_data AS (
    SELECT
        EXTRACT(YEAR FROM start_date)::int AS cohort_year,
        COUNT(*) AS total,
        COUNT(*) FILTER (WHERE cs.status_name IN ('Active','Renewed')) AS retained
    FROM core.contracts c
    JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
    WHERE c.start_date IS NOT NULL
    GROUP BY 1
)
SELECT
    cohort_year, total, retained,
    ROUND(100.0 * retained / NULLIF(total, 0), 2) AS retention_pct,
    ROUND(100.0 * (total - retained) / NULLIF(total, 0), 2) AS churn_pct
FROM cohort_data
ORDER BY cohort_year;
