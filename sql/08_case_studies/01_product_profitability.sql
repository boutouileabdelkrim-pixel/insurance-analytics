-- ============================================================
-- Case Study 1 — Product Profitability (Loss Ratio)
-- Question: Which products are profitable? Which segments under-priced?
-- ============================================================

-- STEP 1 — Global loss ratio per product
SELECT
    p.product_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    ROUND(SUM(c.annual_premium_eur), 2) AS premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_products p  ON p.product_id = c.product_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY p.product_name
ORDER BY loss_ratio DESC;

-- STEP 2 — Combined ratio (expense ratio assumed 25%)
SELECT
    p.product_name,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio,
    0.25 AS expense_ratio,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0) + 0.25, 4) AS combined_ratio
FROM core.contracts c
JOIN core.ref_products p  ON p.product_id = c.product_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY p.product_name
ORDER BY combined_ratio DESC;

-- STEP 3 — Loss ratio by product × risk zone (>= 30 contracts)
SELECT
    p.product_name,
    rz.risk_zone_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
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

-- STEP 4 — Under-priced segments (loss ratio > 1)
SELECT
    p.product_name,
    rz.risk_zone_name,
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
