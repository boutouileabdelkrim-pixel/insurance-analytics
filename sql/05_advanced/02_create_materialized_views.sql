-- ============================================================
-- 05_advanced / 02_create_materialized_views.sql
-- Materialized views for heavy analytics
-- Phase 24 — Materialized Views
-- ============================================================

-- MV1. mv_product_kpi — global KPI per product
DROP MATERIALIZED VIEW IF EXISTS analytics.mv_product_kpi CASCADE;
CREATE MATERIALIZED VIEW analytics.mv_product_kpi AS
SELECT
    p.product_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COUNT(DISTINCT c.client_id)   AS nb_clients,
    ROUND(SUM(c.annual_premium_eur), 2) AS total_premium,
    ROUND(AVG(c.annual_premium_eur), 2) AS avg_premium,
    COUNT(cl.claim_id) AS nb_claims,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS total_indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS claim_frequency
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
LEFT JOIN core.claims cl ON cl.contract_id = c.contract_id
GROUP BY p.product_name;

CREATE UNIQUE INDEX idx_mv_product_kpi ON analytics.mv_product_kpi(product_name);

-- MV2. mv_channel_kpi — global KPI per channel
DROP MATERIALIZED VIEW IF EXISTS analytics.mv_channel_kpi CASCADE;
CREATE MATERIALIZED VIEW analytics.mv_channel_kpi AS
SELECT
    ch.channel_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    ROUND(SUM(c.annual_premium_eur), 2) AS total_premium,
    ROUND(AVG(c.annual_premium_eur), 2) AS avg_premium,
    COUNT(cl.claim_id) AS nb_claims,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS total_indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_channels ch ON ch.channel_id = c.channel_id
LEFT JOIN core.claims cl ON cl.contract_id = c.contract_id
GROUP BY ch.channel_name;

CREATE UNIQUE INDEX idx_mv_channel_kpi ON analytics.mv_channel_kpi(channel_name);

-- MV3. mv_city_kpi — KPI per city (heavy join)
DROP MATERIALIZED VIEW IF EXISTS analytics.mv_city_kpi CASCADE;
CREATE MATERIALIZED VIEW analytics.mv_city_kpi AS
SELECT
    ci.city_name,
    ci.postal_code,
    rz.risk_zone_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    ROUND(SUM(c.annual_premium_eur), 2) AS total_premium,
    COUNT(cl.claim_id) AS nb_claims,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0), 2) AS total_indemnified,
    ROUND(COALESCE(SUM(cl.indemnified_amount_eur), 0)
          / NULLIF(SUM(c.annual_premium_eur), 0), 4) AS loss_ratio
FROM core.contracts c
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
LEFT JOIN core.claims cl    ON cl.contract_id = c.contract_id
GROUP BY ci.city_name, ci.postal_code, rz.risk_zone_name;

CREATE UNIQUE INDEX idx_mv_city_kpi ON analytics.mv_city_kpi(city_name, postal_code);

-- MV4. mv_monthly_premium — monthly premium timeline
DROP MATERIALIZED VIEW IF EXISTS analytics.mv_monthly_premium CASCADE;
CREATE MATERIALIZED VIEW analytics.mv_monthly_premium AS
SELECT
    date_trunc('month', start_date)::date AS month,
    COUNT(*) AS nb_contracts,
    ROUND(SUM(annual_premium_eur), 2) AS total_premium,
    ROUND(AVG(annual_premium_eur), 2) AS avg_premium
FROM core.contracts
WHERE start_date IS NOT NULL
GROUP BY 1;

CREATE UNIQUE INDEX idx_mv_monthly_premium ON analytics.mv_monthly_premium(month);

-- MV5. mv_client_360 — client 360 view (very heavy)
DROP MATERIALIZED VIEW IF EXISTS analytics.mv_client_360 CASCADE;
CREATE MATERIALIZED VIEW analytics.mv_client_360 AS
SELECT
    cl.client_id,
    cl.client_name,
    cl.client_age,
    cl.gender,
    csp.csp_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COALESCE(SUM(c.annual_premium_eur), 0) AS total_premium,
    COUNT(cl2.claim_id) AS nb_claims,
    COALESCE(SUM(cl2.damage_amount_eur), 0) AS total_damage,
    COALESCE(SUM(cl2.indemnified_amount_eur), 0) AS total_indemnified,
    COALESCE(SUM(cl2.indemnified_amount_eur), 0) - COALESCE(SUM(c.annual_premium_eur), 0) AS margin
FROM core.clients cl
LEFT JOIN core.ref_csp csp ON csp.csp_id = cl.csp_id
LEFT JOIN core.contracts c ON c.client_id = cl.client_id
LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
GROUP BY cl.client_id, cl.client_name, cl.client_age, cl.gender, csp.csp_name;

CREATE UNIQUE INDEX idx_mv_client_360 ON analytics.mv_client_360(client_id);

-- REFRESH ALL
REFRESH MATERIALIZED VIEW analytics.mv_product_kpi;
REFRESH MATERIALIZED VIEW analytics.mv_channel_kpi;
REFRESH MATERIALIZED VIEW analytics.mv_city_kpi;
REFRESH MATERIALIZED VIEW analytics.mv_monthly_premium;
REFRESH MATERIALIZED VIEW analytics.mv_client_360;

-- VERIFICATION
SELECT matviewname, ispopulated
FROM pg_matviews
WHERE schemaname = 'analytics'
ORDER BY matviewname;
