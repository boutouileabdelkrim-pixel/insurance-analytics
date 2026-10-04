-- ============================================================
-- 04_analytics / 13_rfm_segmentation.sql
-- RFM adapted to insurance: R, F, M, S (sinistrality), P (profit)
-- Phase 22
-- ============================================================

-- SECTION 1 — BASE METRICS PER CLIENT

WITH client_metrics AS (
    SELECT
        cl.client_id,
        cl.client_name,
        MAX(c.start_date) AS last_contract_date,
        COUNT(DISTINCT c.contract_id) AS frequency,
        COALESCE(SUM(c.annual_premium_eur), 0) AS monetary,
        COALESCE(SUM(cl2.damage_amount_eur), 0) AS sinistrality
    FROM core.clients cl
    LEFT JOIN core.contracts c ON c.client_id = cl.client_id
    LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
    GROUP BY cl.client_id, cl.client_name
)
SELECT
    client_id, client_name, last_contract_date,
    (CURRENT_DATE - last_contract_date) AS recency_days,
    frequency, monetary, sinistrality,
    (monetary - sinistrality) AS profitability
FROM client_metrics
ORDER BY client_id LIMIT 30;

-- SECTION 2 — R SCORE (RECENCY)

WITH client_metrics AS (
    SELECT
        cl.client_id,
        (CURRENT_DATE - MAX(c.start_date)) AS recency_days
    FROM core.clients cl
    LEFT JOIN core.contracts c ON c.client_id = cl.client_id
    GROUP BY cl.client_id
),
r_scores AS (
    SELECT client_id, recency_days,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score
    FROM client_metrics WHERE recency_days IS NOT NULL
)
SELECT * FROM r_scores ORDER BY client_id LIMIT 30;

-- SECTION 3 — F, M, S SCORES

WITH metrics AS (
    SELECT
        cl.client_id,
        COUNT(DISTINCT c.contract_id) AS frequency,
        COALESCE(SUM(c.annual_premium_eur), 0) AS monetary,
        COALESCE(SUM(cl2.damage_amount_eur), 0) AS sinistrality
    FROM core.clients cl
    LEFT JOIN core.contracts c ON c.client_id = cl.client_id
    LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
    GROUP BY cl.client_id
),
scores AS (
    SELECT client_id, frequency, monetary, sinistrality,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score,
        NTILE(5) OVER (ORDER BY sinistrality DESC) AS s_score
    FROM metrics
)
SELECT * FROM scores ORDER BY client_id LIMIT 30;

-- SECTION 4 — FULL SEGMENTATION

WITH metrics AS (
    SELECT
        cl.client_id,
        cl.client_name,
        (CURRENT_DATE - MAX(c.start_date)) AS recency_days,
        COUNT(DISTINCT c.contract_id) AS frequency,
        COALESCE(SUM(c.annual_premium_eur), 0) AS monetary,
        COALESCE(SUM(cl2.damage_amount_eur), 0) AS sinistrality
    FROM core.clients cl
    LEFT JOIN core.contracts c ON c.client_id = cl.client_id
    LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
    GROUP BY cl.client_id, cl.client_name
),
scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC NULLS LAST) AS r,
        NTILE(5) OVER (ORDER BY frequency) AS f,
        NTILE(5) OVER (ORDER BY monetary) AS m,
        NTILE(5) OVER (ORDER BY sinistrality DESC) AS s
    FROM metrics
),
segmented AS (
    SELECT *,
        CASE
            WHEN r >= 4 AND f >= 4 AND m >= 4 THEN 'Champions'
            WHEN r >= 3 AND m >= 4 THEN 'Loyal High-Value'
            WHEN r >= 4 AND f <= 2 THEN 'New Promising'
            WHEN r <= 2 AND m >= 3 THEN 'At Risk High-Value'
            WHEN r <= 2 AND m <= 2 THEN 'Lost Low-Value'
            WHEN s >= 4 THEN 'High-Risk'
            ELSE 'Standard'
        END AS segment
    FROM scored
)
SELECT segment, COUNT(*) AS nb_clients,
       ROUND(AVG(monetary), 2) AS avg_monetary,
       ROUND(AVG(sinistrality), 2) AS avg_sinistrality
FROM segmented
GROUP BY segment ORDER BY nb_clients DESC;

-- SECTION 5 — SEGMENT SIZE AND VALUE

WITH metrics AS (
    SELECT
        cl.client_id,
        (CURRENT_DATE - MAX(c.start_date)) AS recency_days,
        COUNT(DISTINCT c.contract_id) AS frequency,
        COALESCE(SUM(c.annual_premium_eur), 0) AS monetary
    FROM core.clients cl
    LEFT JOIN core.contracts c ON c.client_id = cl.client_id
    GROUP BY cl.client_id
),
scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC NULLS LAST) AS r,
        NTILE(5) OVER (ORDER BY frequency) AS f,
        NTILE(5) OVER (ORDER BY monetary) AS m
    FROM metrics
),
segmented AS (
    SELECT *,
        CASE
            WHEN r >= 4 AND f >= 4 AND m >= 4 THEN 'Champions'
            WHEN r >= 3 AND m >= 4 THEN 'Loyal High-Value'
            WHEN r >= 4 AND f <= 2 THEN 'New Promising'
            WHEN r <= 2 AND m >= 3 THEN 'At Risk High-Value'
            WHEN r <= 2 AND m <= 2 THEN 'Lost Low-Value'
            ELSE 'Standard'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*) AS nb_clients,
    ROUND(SUM(monetary), 2) AS total_premium,
    ROUND(AVG(monetary), 2) AS avg_premium,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_clients,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 2) AS pct_premium
FROM segmented
GROUP BY segment ORDER BY total_premium DESC;

-- SECTION 6 — HIGH-RISK CLIENT LIST

WITH metrics AS (
    SELECT
        cl.client_id, cl.client_name,
        COALESCE(SUM(c.annual_premium_eur), 0) AS monetary,
        COALESCE(SUM(cl2.damage_amount_eur), 0) AS sinistrality
    FROM core.clients cl
    LEFT JOIN core.contracts c ON c.client_id = cl.client_id
    LEFT JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
    GROUP BY cl.client_id, cl.client_name
)
SELECT client_id, client_name, monetary, sinistrality,
       (sinistrality - monetary) AS loss
FROM metrics
WHERE sinistrality > monetary
ORDER BY loss DESC LIMIT 20;
