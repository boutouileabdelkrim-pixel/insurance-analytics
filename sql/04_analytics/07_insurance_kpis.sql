-- ============================================================
-- 04_analytics / 07_insurance_kpis.sql
-- Insurance KPI catalog
-- Phase 16 — Insurance-specific business analysis
-- ============================================================


-- ============================================================
-- SECTION 1 — PORTFOLIO KPI (contracts, premium)
-- ============================================================

-- KPI 1.1 Total contracts and total premium
SELECT
    COUNT(*)                              AS nb_contracts,
    COUNT(DISTINCT client_id)             AS nb_clients,
    ROUND(SUM(annual_premium_eur), 2)     AS total_premium_eur,
    ROUND(AVG(annual_premium_eur), 2)     AS avg_premium_eur,
    ROUND(MIN(annual_premium_eur), 2)     AS min_premium_eur,
    ROUND(MAX(annual_premium_eur), 2)     AS max_premium_eur
FROM core.contracts;

-- KPI 1.2 Average premium per product
SELECT
    p.product_name,
    COUNT(*)                              AS nb_contracts,
    ROUND(AVG(c.annual_premium_eur), 2)   AS avg_premium_eur,
    ROUND(SUM(c.annual_premium_eur), 2)   AS total_premium_eur
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
GROUP BY p.product_name
ORDER BY total_premium_eur DESC;

-- KPI 1.3 Portfolio distribution by risk zone
SELECT
    rz.risk_zone_name,
    COUNT(*)                             AS nb_contracts,
    ROUND(AVG(c.annual_premium_eur), 2)  AS avg_premium_eur,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_portfolio
FROM core.contracts c
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
GROUP BY rz.risk_zone_name
ORDER BY nb_contracts DESC;


-- ============================================================
-- SECTION 2 — CLAIMS KPI (frequency, severity)
-- ============================================================

-- KPI 2.1 Global claim frequency
SELECT
    (SELECT COUNT(*) FROM core.claims)      AS total_claims,
    (SELECT COUNT(*) FROM core.contracts)   AS total_contracts,
    ROUND(
        (SELECT COUNT(*) FROM core.claims)::numeric
        / NULLIF((SELECT COUNT(*) FROM core.contracts), 0),
        4
    ) AS claim_frequency;

-- KPI 2.2 Global severity
SELECT
    COUNT(*)                                AS total_claims,
    ROUND(AVG(damage_amount_eur), 2)        AS avg_damage_eur,
    ROUND(AVG(indemnified_amount_eur), 2)   AS avg_indemnified_eur,
    ROUND(SUM(damage_amount_eur), 2)        AS total_damage_eur,
    ROUND(SUM(indemnified_amount_eur), 2)   AS total_indemnified_eur
FROM core.claims;

-- KPI 2.3 Frequency and severity per product
SELECT
    p.product_name,
    COUNT(DISTINCT c.contract_id)             AS nb_contracts,
    COUNT(cl.claim_id)                        AS nb_claims,
    ROUND(
        COUNT(cl.claim_id)::numeric
        / NULLIF(COUNT(DISTINCT c.contract_id), 0),
        4
    ) AS frequency,
    ROUND(AVG(cl.damage_amount_eur), 2)       AS avg_damage_eur
FROM core.contracts c
JOIN core.ref_products p   ON p.product_id = c.product_id
LEFT JOIN core.claims cl   ON cl.contract_id = c.contract_id
GROUP BY p.product_name
ORDER BY frequency DESC;


-- ============================================================
-- SECTION 3 — LOSS RATIO, COMBINED RATIO, S/P
-- ============================================================

-- KPI 3.1 Loss ratio per product
SELECT
    p.product_name,
    ROUND(SUM(c.annual_premium_eur), 2)            AS total_premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS total_indemnified,
    ROUND(
        COALESCE(SUM(cl.indemnified_amount_eur), 0)
        / NULLIF(SUM(c.annual_premium_eur), 0),
        4
    ) AS loss_ratio
FROM core.contracts c
JOIN core.ref_products p  ON p.product_id = c.product_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY p.product_name
ORDER BY loss_ratio DESC;

-- KPI 3.2 Combined ratio (assuming 25% expense ratio)
WITH per_product AS (
    SELECT
        p.product_name,
        SUM(c.annual_premium_eur)                        AS premium,
        COALESCE(SUM(cl.indemnified_amount_eur), 0)      AS indemnified
    FROM core.contracts c
    JOIN core.ref_products p  ON p.product_id = c.product_id
    LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
    GROUP BY p.product_name
)
SELECT
    product_name,
    ROUND(premium, 2)                                     AS premium,
    ROUND(indemnified, 2)                                 AS indemnified,
    ROUND(indemnified / NULLIF(premium, 0), 4)            AS loss_ratio,
    ROUND(0.25, 2)                                        AS expense_ratio,
    ROUND(indemnified / NULLIF(premium, 0) + 0.25, 4)     AS combined_ratio
FROM per_product
ORDER BY combined_ratio DESC;

-- KPI 3.3 Global loss ratio
SELECT
    ROUND(SUM(annual_premium_eur), 2) AS total_premium,
    ROUND((SELECT SUM(indemnified_amount_eur) FROM core.claims), 2) AS total_indemnified,
    ROUND(
        (SELECT SUM(indemnified_amount_eur) FROM core.claims)
        / NULLIF(SUM(annual_premium_eur), 0),
        4
    ) AS global_loss_ratio
FROM core.contracts;


-- ============================================================
-- SECTION 4 — RETENTION / CHURN KPI
-- ============================================================

-- KPI 4.1 Contract distribution by status
SELECT
    cs.status_name,
    COUNT(*)                                AS nb_contracts,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM core.contracts c
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY cs.status_name
ORDER BY nb_contracts DESC;

-- KPI 4.2 Retention rate (Renewed vs total non-Active)
WITH counts AS (
    SELECT
        COUNT(*) FILTER (WHERE cs.status_name IN ('Renewed', 'Active')) AS active_or_renewed,
        COUNT(*) FILTER (WHERE cs.status_name IN ('Renewed', 'Cancelled', 'Expired')) AS closed_or_renewed
    FROM core.contracts c
    JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
)
SELECT
    active_or_renewed,
    closed_or_renewed,
    ROUND(active_or_renewed::numeric / NULLIF(closed_or_renewed, 0), 4) AS retention_rate
FROM counts;

-- KPI 4.3 Churn rate (Cancelled vs total)
WITH counts AS (
    SELECT
        COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
        COUNT(*)                                              AS total
    FROM core.contracts c
    JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
)
SELECT
    cancelled,
    total,
    ROUND(cancelled::numeric / NULLIF(total, 0), 4) AS churn_rate
FROM counts;


-- ============================================================
-- SECTION 5 — CUSTOMER KPI (LTV, multi-product)
-- ============================================================

-- KPI 5.1 Average premium per client
SELECT
    ROUND(AVG(total_per_client), 2) AS avg_premium_per_client,
    MAX(total_per_client)           AS max_premium_per_client,
    MIN(total_per_client)           AS min_premium_per_client
FROM (
    SELECT client_id, SUM(annual_premium_eur) AS total_per_client
    FROM core.contracts
    GROUP BY client_id
) t;

-- KPI 5.2 Client distribution by number of contracts
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

-- KPI 5.3 Multi-product clients (potential cross-sell)
SELECT
    cl.client_id,
    cl.client_name,
    COUNT(DISTINCT c.product_id) AS nb_distinct_products
FROM core.clients cl
JOIN core.contracts c ON c.client_id = cl.client_id
GROUP BY cl.client_id, cl.client_name
HAVING COUNT(DISTINCT c.product_id) > 1
ORDER BY nb_distinct_products DESC
LIMIT 20;


-- ============================================================
-- SECTION 6 — FRAUD KPI (suspicion signals)
-- ============================================================

-- KPI 6.1 Suspicious claims: declaration before occurrence
SELECT
    COUNT(*) AS suspicious_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM core.claims), 2) AS pct_of_claims
FROM core.claims
WHERE declaration_date < occurrence_date;

-- KPI 6.2 Claims with expert shared across multiple claims
WITH expert_counts AS (
    SELECT expert_id, COUNT(*) AS nb_claims
    FROM core.claims
    WHERE expert_id IS NOT NULL
    GROUP BY expert_id
)
SELECT
    COUNT(*) FILTER (WHERE nb_claims > 1) AS experts_with_multiple_claims,
    COUNT(*)                               AS total_experts
FROM expert_counts;

-- KPI 6.3 Claims with high damage compared to type average
WITH type_avg AS (
    SELECT claim_type_id, AVG(damage_amount_eur) AS avg_dmg
    FROM core.claims
    GROUP BY claim_type_id
)
SELECT
    COUNT(*) AS suspicious_high_damage_claims
FROM core.claims cl
JOIN type_avg ta ON ta.claim_type_id = cl.claim_type_id
WHERE cl.damage_amount_eur > ta.avg_dmg * 3;


-- ============================================================
-- SECTION 7 — KPI BY DIMENSION
-- ============================================================

-- KPI 7.1 Contract count + avg premium + claim frequency per channel
SELECT
    ch.channel_name,
    COUNT(DISTINCT c.contract_id)            AS nb_contracts,
    ROUND(AVG(c.annual_premium_eur), 2)      AS avg_premium,
    COUNT(cl.claim_id)                       AS nb_claims,
    ROUND(
        COUNT(cl.claim_id)::numeric
        / NULLIF(COUNT(DISTINCT c.contract_id), 0),
        4
    ) AS frequency
FROM core.contracts c
JOIN core.ref_channels ch  ON ch.channel_id = c.channel_id
LEFT JOIN core.claims cl   ON cl.contract_id = c.contract_id
GROUP BY ch.channel_name
ORDER BY nb_contracts DESC;

-- KPI 7.2 Loss ratio by CSP
SELECT
    csp.csp_name,
    COUNT(DISTINCT c.contract_id)                            AS nb_contracts,
    ROUND(SUM(c.annual_premium_eur), 2)                      AS total_premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2)    AS total_indemnified,
    ROUND(
        COALESCE(SUM(cl.indemnified_amount_eur), 0)
        / NULLIF(SUM(c.annual_premium_eur), 0),
        4
    ) AS loss_ratio
FROM core.clients cl
JOIN core.ref_csp csp  ON csp.csp_id = cl.csp_id
JOIN core.contracts c  ON c.client_id = cl.client_id
LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
GROUP BY csp.csp_name
ORDER BY loss_ratio DESC;

-- KPI 7.3 Loss ratio by risk zone
SELECT
    rz.risk_zone_name,
    ROUND(SUM(c.annual_premium_eur), 2)                      AS total_premium,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2)    AS total_indemnified,
    ROUND(
        COALESCE(SUM(cl.indemnified_amount_eur), 0)
        / NULLIF(SUM(c.annual_premium_eur), 0),
        4
    ) AS loss_ratio
FROM core.contracts c
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
LEFT JOIN core.claims cl    ON cl.contract_id = c.contract_id
GROUP BY rz.risk_zone_name
ORDER BY loss_ratio DESC;


-- ============================================================
-- SECTION 8 — CONSOLIDATED KPI DASHBOARD
-- ============================================================

-- KPI 8.1 All headline KPIs in one row
WITH portfolio AS (
    SELECT
        COUNT(*)                          AS nb_contracts,
        COUNT(DISTINCT client_id)         AS nb_clients,
        SUM(annual_premium_eur)           AS total_premium,
        AVG(annual_premium_eur)           AS avg_premium
    FROM core.contracts
),
claims_kpi AS (
    SELECT
        COUNT(*)                          AS nb_claims,
        SUM(indemnified_amount_eur)       AS total_indemnified,
        AVG(damage_amount_eur)            AS avg_damage
    FROM core.claims
),
retention AS (
    SELECT
        COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
        COUNT(*)                                              AS total_status
    FROM core.contracts c
    JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
)
SELECT
    p.nb_contracts,
    p.nb_clients,
    ROUND(p.total_premium, 2)                                AS total_premium,
    ROUND(p.avg_premium, 2)                                  AS avg_premium,
    ck.nb_claims,
    ROUND(ck.total_indemnified, 2)                           AS total_indemnified,
    ROUND(ck.avg_damage, 2)                                  AS avg_damage,
    ROUND(ck.total_indemnified / NULLIF(p.total_premium, 0), 4) AS loss_ratio,
    ROUND(ck.nb_claims::numeric / NULLIF(p.nb_contracts, 0), 4) AS claim_frequency,
    ROUND(r.cancelled::numeric / NULLIF(r.total_status, 0), 4)  AS churn_rate
FROM portfolio p, claims_kpi ck, retention r;


-- ============================================================
-- END
-- ============================================================
