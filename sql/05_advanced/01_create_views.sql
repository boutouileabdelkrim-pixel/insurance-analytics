-- ============================================================
-- 05_advanced / 01_create_views.sql
-- Reusable analytical views on core schema
-- Phase 23 — Views
-- ============================================================

-- V1. v_contract_details
CREATE OR REPLACE VIEW analytics.v_contract_details AS
SELECT
    c.contract_id, c.client_id, cl.client_name,
    p.product_name, ch.channel_name,
    ci.city_name, ci.postal_code, rz.risk_zone_name,
    c.start_date, c.end_date, c.annual_premium_eur,
    cs.status_name
FROM core.contracts c
JOIN core.clients cl                ON cl.client_id = c.client_id
JOIN core.ref_products p            ON p.product_id = c.product_id
JOIN core.ref_channels ch           ON ch.channel_id = c.channel_id
JOIN core.ref_cities ci             ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz         ON rz.risk_zone_id = ci.risk_zone_id
JOIN core.ref_contract_statuses cs  ON cs.status_id = c.status_id;

-- V2. v_claim_details
CREATE OR REPLACE VIEW analytics.v_claim_details AS
SELECT
    cl.claim_id, cl.contract_id,
    p.product_name, ct.claim_type_name,
    cs.status_name AS claim_status,
    cli.liability_name,
    cl.occurrence_date, cl.declaration_date,
    cl.damage_amount_eur, cl.indemnified_amount_eur,
    (cl.declaration_date - cl.occurrence_date) AS delay_days
FROM core.claims cl
JOIN core.contracts c              ON c.contract_id = cl.contract_id
JOIN core.ref_products p           ON p.product_id = c.product_id
JOIN core.ref_claim_types ct       ON ct.claim_type_id = cl.claim_type_id
JOIN core.ref_claim_statuses cs    ON cs.status_id = cl.status_id
LEFT JOIN core.ref_liabilities cli ON cli.liability_id = cl.liability_id;

-- V3. v_portfolio_kpi (based on v_contract_details)
CREATE OR REPLACE VIEW analytics.v_portfolio_kpi AS
SELECT
    product_name,
    COUNT(*) AS nb_contracts,
    COUNT(DISTINCT client_id) AS nb_clients,
    ROUND(SUM(annual_premium_eur), 2) AS total_premium,
    ROUND(AVG(annual_premium_eur), 2) AS avg_premium
FROM analytics.v_contract_details
GROUP BY product_name;

-- V4. v_loss_ratio_per_product (based on V1 and V2)
CREATE OR REPLACE VIEW analytics.v_loss_ratio_per_product AS
WITH premiums AS (
    SELECT product_name, SUM(annual_premium_eur) AS premium
    FROM analytics.v_contract_details
    GROUP BY product_name
),
indemnified AS (
    SELECT product_name, SUM(indemnified_amount_eur) AS indemn
    FROM analytics.v_claim_details
    GROUP BY product_name
)
SELECT
    p.product_name,
    ROUND(p.premium, 2) AS premium,
    ROUND(COALESCE(i.indemn, 0), 2) AS indemnified,
    ROUND(COALESCE(i.indemn, 0) / NULLIF(p.premium, 0), 4) AS loss_ratio
FROM premiums p
LEFT JOIN indemnified i ON i.product_name = p.product_name;

-- V5. v_client_metrics
CREATE OR REPLACE VIEW analytics.v_client_metrics AS
SELECT
    cl.client_id, cl.client_name,
    COUNT(DISTINCT c.contract_id) AS nb_contracts,
    COALESCE(SUM(c.annual_premium_eur), 0) AS total_premium,
    COUNT(cl2.claim_id) AS nb_claims,
    COALESCE(SUM(cl2.damage_amount_eur), 0) AS total_damage
FROM core.clients cl
LEFT JOIN core.contracts c ON c.client_id = cl.client_id
LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
GROUP BY cl.client_id, cl.client_name;

-- V6. v_monthly_claims
CREATE OR REPLACE VIEW analytics.v_monthly_claims AS
SELECT
    date_trunc('month', occurrence_date)::date AS month,
    COUNT(*) AS nb_claims,
    ROUND(SUM(damage_amount_eur), 2) AS total_damage,
    ROUND(AVG(damage_amount_eur), 2) AS avg_damage
FROM core.claims
WHERE occurrence_date IS NOT NULL
GROUP BY 1;

-- V7. v_churn_by_product
CREATE OR REPLACE VIEW analytics.v_churn_by_product AS
SELECT
    p.product_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled') AS cancelled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Cancelled')
          / NULLIF(COUNT(*), 0), 2) AS churn_pct
FROM core.contracts c
JOIN core.ref_products p           ON p.product_id = c.product_id
JOIN core.ref_contract_statuses cs ON cs.status_id = c.status_id
GROUP BY p.product_name;

-- VERIFICATION
SELECT table_name FROM information_schema.views
WHERE table_schema = 'analytics'
ORDER BY table_name;

