-- ============================================================
-- 04_analytics / 06_date_time.sql
-- Date and Time SQL in PostgreSQL
-- Phase 15 — Date / Time SQL
-- ============================================================


-- ============================================================
-- SECTION 1 — DATE, TIME, TIMESTAMP, INTERVAL TYPES
-- ============================================================

-- Q1. Type introspection of core tables
SELECT
    table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'core'
  AND data_type IN ('date', 'timestamp', 'timestamp with time zone', 'time')
ORDER BY table_name, column_name;

-- Q2. Examples of literal types
SELECT
    '2024-06-15'::date                                AS d,
    '14:30:00'::time                                  AS t,
    '2024-06-15 14:30:00'::timestamp                  AS ts,
    '2024-06-15 14:30:00+00'::timestamptz             AS tstz,
    '5 days 3 hours'::interval                        AS iv;

-- Q3. Interval arithmetic
SELECT
    now()                                AS now_value,
    now() + INTERVAL '1 day'             AS plus_1_day,
    now() - INTERVAL '1 month'           AS minus_1_month,
    now() + INTERVAL '1 year 2 months'   AS plus_1y2m,
    age(now(), '2024-01-01'::timestamp)  AS age_since_2024;


-- ============================================================
-- SECTION 2 — EXTRACTION (YEAR, MONTH, QUARTER, WEEK, DOW)
-- ============================================================

-- Q4. Extract components from start_date
SELECT
    c.contract_id,
    c.start_date,
    EXTRACT(YEAR    FROM c.start_date) AS year,
    EXTRACT(MONTH   FROM c.start_date) AS month,
    EXTRACT(QUARTER FROM c.start_date) AS quarter,
    EXTRACT(WEEK    FROM c.start_date) AS iso_week,
    EXTRACT(DAY     FROM c.start_date) AS day,
    EXTRACT(DOW     FROM c.start_date) AS day_of_week
FROM core.contracts c
WHERE c.start_date IS NOT NULL
ORDER BY c.contract_id
LIMIT 20;

-- Q5. Contracts per year and quarter
SELECT
    EXTRACT(YEAR    FROM start_date) AS year,
    EXTRACT(QUARTER FROM start_date) AS quarter,
    COUNT(*)                         AS nb_contracts
FROM core.contracts
WHERE start_date IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2;

-- Q6. Contracts per day of week
SELECT
    EXTRACT(DOW FROM start_date) AS dow,
    TO_CHAR(start_date, 'Day')   AS day_name,
    COUNT(*)                     AS nb_contracts
FROM core.contracts
WHERE start_date IS NOT NULL
GROUP BY 1, 2
ORDER BY 1;


-- ============================================================
-- SECTION 3 — DURATION CALCULATIONS
-- ============================================================

-- Q7. Contract duration in days
SELECT
    contract_id,
    start_date,
    end_date,
    (end_date - start_date)                       AS duration_days,
    (end_date - start_date) / 30.0                AS duration_months_approx,
    age(end_date, start_date)                     AS duration_interval
FROM core.contracts
WHERE start_date IS NOT NULL
  AND end_date IS NOT NULL
ORDER BY contract_id
LIMIT 20;

-- Q8. Claim processing delay (declaration → occurrence)
SELECT
    claim_id,
    occurrence_date,
    declaration_date,
    (declaration_date - occurrence_date) AS delay_days
FROM core.claims
WHERE occurrence_date IS NOT NULL
  AND declaration_date IS NOT NULL
ORDER BY delay_days DESC
LIMIT 20;

-- Q9. Average claim delay by claim type
SELECT
    ct.claim_type_name,
    COUNT(*)                                       AS nb_claims,
    ROUND(AVG(declaration_date - occurrence_date), 2) AS avg_delay_days,
    MIN(declaration_date - occurrence_date)        AS min_delay,
    MAX(declaration_date - occurrence_date)        AS max_delay
FROM core.claims cl
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
WHERE cl.occurrence_date IS NOT NULL
  AND cl.declaration_date IS NOT NULL
GROUP BY ct.claim_type_name
ORDER BY avg_delay_days DESC;


-- ============================================================
-- SECTION 4 — TIME SERIES GENERATION
-- ============================================================

-- Q10. Generate 12 consecutive months
SELECT
    (DATE '2024-01-01' + (n || ' month')::interval)::date AS month_start
FROM generate_series(0, 11) AS n;

-- Q11. Monthly contract counts with zero-fill (LEFT JOIN on generated series)
WITH months AS (
    SELECT (DATE '2022-01-01' + (n || ' month')::interval)::date AS month_start
    FROM generate_series(0, 47) AS n
)
SELECT
    m.month_start,
    COUNT(c.contract_id) AS nb_contracts
FROM months m
LEFT JOIN core.contracts c
    ON date_trunc('month', c.start_date) = m.month_start
GROUP BY m.month_start
ORDER BY m.month_start;


-- ============================================================
-- SECTION 5 — TIME AGGREGATIONS
-- ============================================================

-- Q12. Monthly premium total
SELECT
    date_trunc('month', start_date)::date AS month,
    COUNT(*)                               AS nb_contracts,
    ROUND(SUM(annual_premium_eur), 2)      AS total_premium
FROM core.contracts
WHERE start_date IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- Q13. Yearly claims + average damage
SELECT
    EXTRACT(YEAR FROM occurrence_date)::int AS year,
    COUNT(*)                                 AS nb_claims,
    ROUND(AVG(damage_amount_eur), 2)         AS avg_damage,
    ROUND(SUM(indemnified_amount_eur), 2)    AS total_indemnified
FROM core.claims
WHERE occurrence_date IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- SECTION 6 — PERIOD COMPARISONS
-- ============================================================

-- Q14. Month-over-month premium growth
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
    ROUND(LAG(premium) OVER (ORDER BY month), 2) AS prev_month,
    ROUND(100.0 * (premium - LAG(premium) OVER (ORDER BY month))
          / NULLIF(LAG(premium) OVER (ORDER BY month), 0), 2) AS growth_pct
FROM monthly
ORDER BY month;

-- Q15. Contracts same month previous year
WITH monthly AS (
    SELECT
        EXTRACT(YEAR FROM start_date)::int  AS year,
        EXTRACT(MONTH FROM start_date)::int AS month,
        COUNT(*) AS nb
    FROM core.contracts
    WHERE start_date IS NOT NULL
    GROUP BY 1, 2
)
SELECT
    m.year,
    m.month,
    m.nb AS current_year,
    p.nb AS previous_year,
    m.nb - p.nb AS delta
FROM monthly m
LEFT JOIN monthly p
    ON p.year = m.year - 1
   AND p.month = m.month
ORDER BY m.year, m.month;


-- ============================================================
-- SECTION 7 — TIMEZONE HANDLING
-- ============================================================

-- Q16. Current time in multiple timezones
SELECT
    now()                                 AS utc,
    now() AT TIME ZONE 'Europe/Paris'     AS paris,
    now() AT TIME ZONE 'Africa/Casablanca' AS casablanca,
    now() AT TIME ZONE 'America/New_York' AS new_york;

-- Q17. Session timezone
SHOW timezone;


-- ============================================================
-- SECTION 8 — BUSINESS APPLICATIONS
-- ============================================================

-- Q18. Active contracts as of a given date (2024-06-30)
SELECT COUNT(*) AS active_contracts_on_20240630
FROM core.contracts
WHERE start_date <= DATE '2024-06-30'
  AND (end_date IS NULL OR end_date >= DATE '2024-06-30');

-- Q19. Contract cohort by subscription year
SELECT
    EXTRACT(YEAR FROM start_date)::int AS cohort_year,
    COUNT(*)                            AS nb_contracts,
    ROUND(AVG(annual_premium_eur), 2)   AS avg_premium
FROM core.contracts
WHERE start_date IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- Q20. Claim lag distribution (buckets by delay)
SELECT
    CASE
        WHEN declaration_date - occurrence_date <   0 THEN 'negative (anomaly)'
        WHEN declaration_date - occurrence_date <=  7 THEN '0-7 days'
        WHEN declaration_date - occurrence_date <= 30 THEN '8-30 days'
        WHEN declaration_date - occurrence_date <= 90 THEN '31-90 days'
        ELSE '90+ days'
    END AS delay_bucket,
    COUNT(*) AS nb_claims
FROM core.claims
WHERE occurrence_date IS NOT NULL
  AND declaration_date IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;


-- ============================================================
-- END
-- ============================================================
