-- ============================================================
-- 04_analytics / 10_risk_analytics.sql
-- Risk Analytics — segmentation, concentration, correlation
-- Phase 19 — Risk Analytics
-- ============================================================

-- SECTION 1 — RISK BY CUSTOMER PROFILE

SELECT
    CASE
        WHEN cl.client_age < 25 THEN '<25'
        WHEN cl.client_age < 35 THEN '25-34'
        WHEN cl.client_age < 45 THEN '35-44'
        WHEN cl.client_age < 55 THEN '45-54'
        WHEN cl.client_age < 65 THEN '55-64'
        ELSE '65+'
    END AS age_band,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COUNT(cl2.claim_id)            AS nb_claims,
    ROUND(COUNT(cl2.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency,
    ROUND(AVG(cl2.damage_amount_eur), 2) AS avg_damage
FROM core.clients cl
JOIN core.contracts c     ON c.client_id = cl.client_id
LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
WHERE cl.client_age IS NOT NULL
GROUP BY 1 ORDER BY 1;

SELECT
    COALESCE(cl.gender, 'Unknown') AS gender,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COUNT(cl2.claim_id)            AS nb_claims,
    ROUND(COUNT(cl2.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency
FROM core.clients cl
JOIN core.contracts c     ON c.client_id = cl.client_id
LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
GROUP BY 1 ORDER BY frequency DESC;

SELECT
    csp.csp_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COUNT(cl.claim_id)            AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency,
    ROUND(AVG(cl.damage_amount_eur), 2) AS avg_damage
FROM core.clients cl
JOIN core.ref_csp csp     ON csp.csp_id = cl.csp_id
JOIN core.contracts c     ON c.client_id = cl.client_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY csp.csp_name ORDER BY frequency DESC;

-- SECTION 2 — RISK BY PRODUCT

SELECT
    p.product_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COUNT(cl.claim_id)            AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency,
    ROUND(AVG(cl.damage_amount_eur), 2) AS avg_severity
FROM core.contracts c
JOIN core.ref_products p  ON p.product_id = c.product_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY p.product_name ORDER BY frequency DESC;

SELECT
    p.product_name,
    ROUND(SUM(c.annual_premium_eur), 2) AS total_premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS total_indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_products p  ON p.product_id = c.product_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY p.product_name ORDER BY loss_ratio DESC;

-- SECTION 3 — RISK BY GEOGRAPHY

SELECT
    rz.risk_zone_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COUNT(cl.claim_id)            AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency,
    ROUND(SUM(c.annual_premium_eur), 2) AS premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
LEFT JOIN core.claims cl    ON cl.contract_id = c.contract_id
GROUP BY rz.risk_zone_name ORDER BY loss_ratio DESC;

SELECT
    ci.city_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    ROUND(SUM(c.annual_premium_eur), 2) AS premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_cities ci   ON ci.city_id = c.city_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY ci.city_name
HAVING COUNT(DISTINCT c.contract_id) >= 20
ORDER BY loss_ratio DESC LIMIT 15;

-- SECTION 4 — RISK CONCENTRATION

WITH ranked AS (
    SELECT contract_id, annual_premium_eur,
           NTILE(100) OVER (ORDER BY annual_premium_eur DESC) AS percentile
    FROM core.contracts
    WHERE annual_premium_eur IS NOT NULL
)
SELECT COUNT(*) AS nb_top_1pct,
       ROUND(SUM(annual_premium_eur), 2) AS total_premium,
       ROUND(AVG(annual_premium_eur), 2) AS avg_premium
FROM ranked WHERE percentile = 1;

-- SECTION 5 — CORRELATION VARIABLES x CLAIMS

SELECT
    CASE
        WHEN v.year < 2000 THEN '<2000'
        WHEN v.year < 2010 THEN '2000-2009'
        WHEN v.year < 2015 THEN '2010-2014'
        WHEN v.year < 2020 THEN '2015-2019'
        ELSE '2020+'
    END AS year_band,
    COUNT(DISTINCT v.contract_id) AS nb_vehicles,
    COUNT(cl.claim_id)            AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT v.contract_id), 0), 4) AS frequency
FROM core.vehicles v
JOIN core.contracts c    ON c.contract_id = v.contract_id
LEFT JOIN core.claims cl ON cl.contract_id = v.contract_id
WHERE v.year IS NOT NULL
GROUP BY 1 ORDER BY 1;

SELECT
    COALESCE(v.previous_claims, 0) AS prev_claims,
    COUNT(DISTINCT v.contract_id) AS nb_vehicles,
    COUNT(cl.claim_id)            AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT v.contract_id), 0), 4) AS frequency
FROM core.vehicles v
JOIN core.contracts c    ON c.contract_id = v.contract_id
LEFT JOIN core.claims cl ON cl.contract_id = v.contract_id
GROUP BY 1 ORDER BY 1;

-- SECTION 6 — HIGH-RISK SEGMENTS

SELECT
    p.product_name, rz.risk_zone_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COUNT(cl.claim_id)            AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_products p    ON p.product_id = c.product_id
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
LEFT JOIN core.claims cl    ON cl.contract_id = c.contract_id
GROUP BY p.product_name, rz.risk_zone_name
HAVING COUNT(DISTINCT c.contract_id) >= 30
ORDER BY loss_ratio DESC;

-- SECTION 7 — UNDER-PRICED SEGMENTS

SELECT
    p.product_name, rz.risk_zone_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    ROUND(SUM(c.annual_premium_eur), 2) AS premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_products p    ON p.product_id = c.product_id
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
LEFT JOIN core.claims cl    ON cl.contract_id = c.contract_id
GROUP BY p.product_name, rz.risk_zone_name
HAVING COALESCE(SUM(cl.indemnified_amount_eur), 0)
       / NULLIF(SUM(c.annual_premium_eur), 0) > 1
ORDER BY loss_ratio DESC;

-- SECTION 8 — EMERGING RISK (YOY TREND)

WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM c.start_date)::int AS year,
        COUNT(DISTINCT c.contract_id)         AS nb_contracts,
        COUNT(cl.claim_id)                    AS nb_claims
    FROM core.contracts c
    LEFT JOIN core.claims cl ON cl.contract_id = c.contract_id
    WHERE c.start_date IS NOT NULL
    GROUP BY 1
)
SELECT year, nb_contracts, nb_claims,
    ROUND(nb_claims::numeric / NULLIF(nb_contracts, 0), 4) AS frequency,
    ROUND(nb_claims::numeric / NULLIF(nb_contracts, 0)
          - LAG(nb_claims::numeric / NULLIF(nb_contracts, 0))
            OVER (ORDER BY year), 4) AS freq_delta
FROM yearly ORDER BY year;
