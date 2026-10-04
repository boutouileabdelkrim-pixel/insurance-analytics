-- ============================================================
-- Case Study 4 — Client Segmentation (RFM + Sinistrality)
-- Question: How to segment clients for targeted actions?
-- ============================================================

-- STEP 1 — RFM scoring per client
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
GROUP BY segment
ORDER BY nb_clients DESC;

-- STEP 2 — Segment value (share of total premium)
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
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_clients,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 2) AS pct_premium
FROM segmented
GROUP BY segment
ORDER BY total_premium DESC;

-- STEP 3 — Top 20 negative-margin clients (claims > premium)
WITH client_premium AS (
    SELECT client_id, SUM(annual_premium_eur) AS premium
    FROM core.contracts GROUP BY client_id
),
client_claims AS (
    SELECT c.client_id, SUM(cl.indemnified_amount_eur) AS claims
    FROM core.contracts c
    JOIN core.claims cl ON cl.contract_id = c.contract_id
    GROUP BY c.client_id
)
SELECT
    cp.client_id,
    ROUND(cp.premium, 2) AS premium,
    ROUND(COALESCE(cc.claims, 0), 2) AS claims,
    ROUND(COALESCE(cc.claims, 0) - cp.premium, 2) AS margin
FROM client_premium cp
LEFT JOIN client_claims cc ON cc.client_id = cp.client_id
WHERE COALESCE(cc.claims, 0) > cp.premium
ORDER BY margin DESC
LIMIT 20;
