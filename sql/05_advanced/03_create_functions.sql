-- ============================================================
-- 05_advanced / 03_create_functions.sql
-- SQL and PL/pgSQL functions and procedures
-- Phase 25 — Functions / Procedures
-- ============================================================

-- FN1. fn_loss_ratio(p_product_id integer) RETURNS numeric
CREATE OR REPLACE FUNCTION analytics.fn_loss_ratio(p_product_id integer)
RETURNS numeric
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_premium numeric;
    v_indemnified numeric;
BEGIN
    SELECT COALESCE(SUM(c.annual_premium_eur), 0)
    INTO v_premium
    FROM core.contracts c
    WHERE c.product_id = p_product_id;

    SELECT COALESCE(SUM(cl.indemnified_amount_eur), 0)
    INTO v_indemnified
    FROM core.claims cl
    JOIN core.contracts c ON c.contract_id = cl.contract_id
    WHERE c.product_id = p_product_id;

    IF v_premium = 0 THEN
        RETURN NULL;
    END IF;

    RETURN ROUND(v_indemnified / v_premium, 4);
END;
$$;

-- FN2. fn_claim_frequency(p_product_id integer) RETURNS numeric
CREATE OR REPLACE FUNCTION analytics.fn_claim_frequency(p_product_id integer)
RETURNS numeric
LANGUAGE sql
STABLE
AS $$
    SELECT ROUND(
        (SELECT COUNT(*) FROM core.claims cl
         JOIN core.contracts c ON c.contract_id = cl.contract_id
         WHERE c.product_id = p_product_id)::numeric
        / NULLIF((SELECT COUNT(*) FROM core.contracts WHERE product_id = p_product_id), 0),
        4);
$$;

-- FN3. fn_client_age_band(p_age numeric) RETURNS text
CREATE OR REPLACE FUNCTION analytics.fn_client_age_band(p_age numeric)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN p_age IS NULL THEN 'Unknown'
        WHEN p_age < 25 THEN '<25'
        WHEN p_age < 35 THEN '25-34'
        WHEN p_age < 45 THEN '35-44'
        WHEN p_age < 55 THEN '45-54'
        WHEN p_age < 65 THEN '55-64'
        ELSE '65+'
    END;
$$;

-- FN4. fn_premium_band(p_premium numeric) RETURNS text
CREATE OR REPLACE FUNCTION analytics.fn_premium_band(p_premium numeric)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN p_premium IS NULL THEN 'Unknown'
        WHEN p_premium <  500 THEN 'Low'
        WHEN p_premium < 1000 THEN 'Medium'
        WHEN p_premium < 2000 THEN 'High'
        ELSE 'Very high'
    END;
$$;

-- FN5. fn_top_n_products(p_n integer) RETURNS TABLE(...)
CREATE OR REPLACE FUNCTION analytics.fn_top_n_products(p_n integer)
RETURNS TABLE (
    product_name text,
    nb_contracts bigint,
    total_premium numeric
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.product_name,
        COUNT(c.contract_id) AS nb_contracts,
        ROUND(SUM(c.annual_premium_eur), 2) AS total_premium
    FROM core.contracts c
    JOIN core.ref_products p ON p.product_id = c.product_id
    GROUP BY p.product_name
    ORDER BY total_premium DESC
    LIMIT p_n;
$$;

-- SP1. sp_refresh_all_mv() — refresh all materialized views
CREATE OR REPLACE PROCEDURE analytics.sp_refresh_all_mv()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_product_kpi;
    REFRESH MATERIALIZED VIEW analytics.mv_channel_kpi;
    REFRESH MATERIALIZED VIEW analytics.mv_city_kpi;
    REFRESH MATERIALIZED VIEW analytics.mv_monthly_premium;
    REFRESH MATERIALIZED VIEW analytics.mv_client_360;
    RAISE NOTICE 'All materialized views refreshed.';
END;
$$;

-- SP2. sp_show_kpi_summary() — prints KPI summary
CREATE OR REPLACE PROCEDURE analytics.sp_show_kpi_summary()
LANGUAGE plpgsql
AS $$
DECLARE
    v_nb_contracts bigint;
    v_total_premium numeric;
    v_nb_claims bigint;
BEGIN
    SELECT COUNT(*), SUM(annual_premium_eur) INTO v_nb_contracts, v_total_premium
    FROM core.contracts;

    SELECT COUNT(*) INTO v_nb_claims
    FROM core.claims;

    RAISE NOTICE 'Contracts: %, Total premium: %, Claims: %',
        v_nb_contracts, v_total_premium, v_nb_claims;
END;
$$;

-- VERIFICATION: call functions
SELECT analytics.fn_client_age_band(30) AS age_band_30,
       analytics.fn_client_age_band(70) AS age_band_70,
       analytics.fn_premium_band(250)   AS premium_band_low,
       analytics.fn_premium_band(3000)  AS premium_band_high;

SELECT analytics.fn_loss_ratio(1) AS loss_ratio_auto;
SELECT analytics.fn_claim_frequency(1) AS freq_auto;

SELECT * FROM analytics.fn_top_n_products(3);
