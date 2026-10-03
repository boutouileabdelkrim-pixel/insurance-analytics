-- ============================================================
-- 04_analytics / 05_window_functions.sql
-- Master window functions for advanced analytics
-- Phase 14 — Window Functions
-- ============================================================


-- ============================================================
-- SECTION 1 — OVER() AND PARTITION BY
-- ============================================================

-- Q1. Global average premium (no partition)
SELECT
    contract_id,
    annual_premium_eur,
    ROUND(AVG(annual_premium_eur) OVER (), 2) AS global_avg
FROM core.contracts
ORDER BY contract_id
LIMIT 20;

-- Q2. Average premium per product (partitioned)
SELECT
    c.contract_id,
    p.product_name,
    c.annual_premium_eur,
    ROUND(AVG(c.annual_premium_eur) OVER (PARTITION BY p.product_name), 2) AS product_avg
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
ORDER BY c.contract_id
LIMIT 20;


-- ============================================================
-- SECTION 2 — ROW_NUMBER, RANK, DENSE_RANK
-- ============================================================

-- Q3. Rank contracts by premium within each product
SELECT
    p.product_name,
    c.contract_id,
    c.annual_premium_eur,
    ROW_NUMBER() OVER (PARTITION BY p.product_name ORDER BY c.annual_premium_eur DESC) AS rn,
    RANK()       OVER (PARTITION BY p.product_name ORDER BY c.annual_premium_eur DESC) AS rnk,
    DENSE_RANK() OVER (PARTITION BY p.product_name ORDER BY c.annual_premium_eur DESC) AS dense_rnk
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
WHERE c.annual_premium_eur IS NOT NULL
ORDER BY p.product_name, rn
LIMIT 30;

-- Q4. Top 3 contracts per product
WITH ranked AS (
    SELECT
        p.product_name,
        c.contract_id,
        c.annual_premium_eur,
        ROW_NUMBER() OVER (PARTITION BY p.product_name ORDER BY c.annual_premium_eur DESC) AS rn
    FROM core.contracts c
    JOIN core.ref_products p ON p.product_id = c.product_id
)
SELECT * FROM ranked WHERE rn <= 3 ORDER BY product_name, rn;


-- ============================================================
-- SECTION 3 — LAG, LEAD
-- ============================================================

-- Q5. Premium evolution per contract (sorted by start_date)
SELECT
    c.contract_id,
    c.start_date,
    c.annual_premium_eur,
    LAG(c.annual_premium_eur)  OVER (ORDER BY c.start_date, c.contract_id) AS prev_premium,
    LEAD(c.annual_premium_eur) OVER (ORDER BY c.start_date, c.contract_id) AS next_premium
FROM core.contracts c
WHERE c.start_date IS NOT NULL
ORDER BY c.start_date, c.contract_id
LIMIT 30;

-- Q6. Monthly claim count with previous month comparison
WITH monthly_claims AS (
    SELECT
        date_trunc('month', occurrence_date)::date AS month,
        COUNT(*) AS nb_claims
    FROM core.claims
    WHERE occurrence_date IS NOT NULL
    GROUP BY 1
)
SELECT
    month,
    nb_claims,
    LAG(nb_claims) OVER (ORDER BY month) AS prev_month,
    nb_claims - LAG(nb_claims) OVER (ORDER BY month) AS delta
FROM monthly_claims
ORDER BY month;


-- ============================================================
-- SECTION 4 — FIRST_VALUE, LAST_VALUE, NTH_VALUE
-- ============================================================

-- Q7. First and last claim per contract
SELECT DISTINCT
    cl.contract_id,
    FIRST_VALUE(cl.claim_id) OVER (PARTITION BY cl.contract_id ORDER BY cl.occurrence_date) AS first_claim,
    LAST_VALUE(cl.claim_id)  OVER (
        PARTITION BY cl.contract_id
        ORDER BY cl.occurrence_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_claim
FROM core.claims cl
ORDER BY cl.contract_id
LIMIT 20;


-- ============================================================
-- SECTION 5 — WINDOWED AGGREGATES
-- ============================================================

-- Q8. Running total of premium over time
SELECT
    c.start_date,
    c.contract_id,
    c.annual_premium_eur,
    SUM(c.annual_premium_eur) OVER (ORDER BY c.start_date, c.contract_id) AS running_total
FROM core.contracts c
WHERE c.start_date IS NOT NULL
ORDER BY c.start_date, c.contract_id
LIMIT 30;

-- Q9. Claim count per product with percentage of total
SELECT
    p.product_name,
    COUNT(cl.claim_id) AS nb_claims,
    ROUND(100.0 * COUNT(cl.claim_id) / SUM(COUNT(cl.claim_id)) OVER (), 2) AS pct_of_total
FROM core.claims cl
JOIN core.contracts c    ON c.contract_id = cl.contract_id
JOIN core.ref_products p ON p.product_id  = c.product_id
GROUP BY p.product_name
ORDER BY nb_claims DESC;


-- ============================================================
-- SECTION 6 — SLIDING WINDOWS
-- ============================================================

-- Q10. 3-day moving average of damage amount
WITH daily AS (
    SELECT
        occurrence_date,
        AVG(damage_amount_eur) AS avg_damage
    FROM core.claims
    WHERE occurrence_date IS NOT NULL
    GROUP BY occurrence_date
)
SELECT
    occurrence_date,
    ROUND(avg_damage, 2) AS avg_damage,
    ROUND(AVG(avg_damage) OVER (
        ORDER BY occurrence_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3
FROM daily
ORDER BY occurrence_date;

-- Q11. Cumulative claims count per product over time
SELECT
    p.product_name,
    cl.occurrence_date,
    COUNT(cl.claim_id) OVER (
        PARTITION BY p.product_name
        ORDER BY cl.occurrence_date
    ) AS cumulative_claims
FROM core.claims cl
JOIN core.contracts c    ON c.contract_id = cl.contract_id
JOIN core.ref_products p ON p.product_id  = c.product_id
WHERE cl.occurrence_date IS NOT NULL
ORDER BY p.product_name, cl.occurrence_date
LIMIT 30;


-- ============================================================
-- SECTION 7 — NTILE
-- ============================================================

-- Q12. Segment contracts into premium quartiles
SELECT
    contract_id,
    annual_premium_eur,
    NTILE(4) OVER (ORDER BY annual_premium_eur) AS quartile
FROM core.contracts
WHERE annual_premium_eur IS NOT NULL
ORDER BY annual_premium_eur
LIMIT 30;

-- Q13. Segment claims into 5 severity buckets
SELECT
    claim_id,
    damage_amount_eur,
    NTILE(5) OVER (ORDER BY damage_amount_eur) AS severity_bucket
FROM core.claims
WHERE damage_amount_eur IS NOT NULL
ORDER BY damage_amount_eur;


-- ============================================================
-- SECTION 8 — WINDOW + CTE
-- ============================================================

-- Q14. Top 5 clients by total premium
WITH client_totals AS (
    SELECT client_id, SUM(annual_premium_eur) AS total_premium
    FROM core.contracts
    GROUP BY client_id
),
ranked AS (
    SELECT
        client_id,
        total_premium,
        RANK() OVER (ORDER BY total_premium DESC) AS rnk
    FROM client_totals
)
SELECT r.client_id, cl.client_name, r.total_premium, r.rnk
FROM ranked r
JOIN core.clients cl ON cl.client_id = r.client_id
WHERE r.rnk <= 5
ORDER BY r.rnk;


-- ============================================================
-- SECTION 9 — BUSINESS APPLICATIONS
-- ============================================================

-- Q15. Monthly premium evolution with month-over-month delta
WITH monthly AS (
    SELECT
        date_trunc('month', start_date)::date AS month,
        SUM(annual_premium_eur) AS premium
    FROM core.contracts
    WHERE start_date IS NOT NULL
    GROUP BY 1
)
SELECT
    month,
    ROUND(premium, 2) AS premium,
    ROUND(premium - LAG(premium) OVER (ORDER BY month), 2) AS delta_prev_month
FROM monthly
ORDER BY month;

-- Q16. Rank claim types by average severity
WITH type_avg AS (
    SELECT
        ct.claim_type_name,
        AVG(cl.damage_amount_eur) AS avg_damage
    FROM core.claims cl
    JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
    GROUP BY ct.claim_type_name
)
SELECT
    claim_type_name,
    ROUND(avg_damage, 2) AS avg_damage,
    RANK() OVER (ORDER BY avg_damage DESC) AS severity_rank
FROM type_avg
ORDER BY severity_rank;

-- Q17. Contract's premium percentile within product
SELECT
    p.product_name,
    c.contract_id,
    c.annual_premium_eur,
    ROUND(
        100.0 * PERCENT_RANK() OVER (PARTITION BY p.product_name ORDER BY c.annual_premium_eur),
        2
    ) AS pct_rank
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
WHERE c.annual_premium_eur IS NOT NULL
ORDER BY p.product_name, pct_rank DESC
LIMIT 30;

-- Q18. Claim frequency rolling 30-day window per product
WITH daily_claims AS (
    SELECT
        p.product_name,
        cl.occurrence_date,
        COUNT(*) AS daily_count
    FROM core.claims cl
    JOIN core.contracts c    ON c.contract_id = cl.contract_id
    JOIN core.ref_products p ON p.product_id  = c.product_id
    WHERE cl.occurrence_date IS NOT NULL
    GROUP BY 1, 2
)
SELECT
    product_name,
    occurrence_date,
    daily_count,
    SUM(daily_count) OVER (
        PARTITION BY product_name
        ORDER BY occurrence_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30d
FROM daily_claims
ORDER BY product_name, occurrence_date
LIMIT 40;

-- Q19. First contract per client (earliest start_date)
WITH ranked AS (
    SELECT
        client_id,
        contract_id,
        start_date,
        ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY start_date) AS rn
    FROM core.contracts
    WHERE start_date IS NOT NULL
)
SELECT client_id, contract_id AS first_contract, start_date
FROM ranked
WHERE rn = 1
ORDER BY client_id
LIMIT 20;

-- Q20. Cumulative premium per client
SELECT
    client_id,
    contract_id,
    start_date,
    annual_premium_eur,
    SUM(annual_premium_eur) OVER (
        PARTITION BY client_id
        ORDER BY start_date, contract_id
    ) AS cumulative_premium
FROM core.contracts
WHERE start_date IS NOT NULL
ORDER BY client_id, start_date
LIMIT 30;


-- ============================================================
-- END
-- ============================================================
