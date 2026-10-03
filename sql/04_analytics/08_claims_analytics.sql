-- ============================================================
-- 04_analytics / 08_claims_analytics.sql
-- Claims Analytics — volume, frequency, severity, delays, outliers
-- Phase 17 — Claims Analytics
-- ============================================================


-- ============================================================
-- SECTION 1 — CLAIM VOLUME OVER TIME
-- ============================================================

-- Q1. Monthly claim volume
SELECT
    date_trunc('month', occurrence_date)::date AS month,
    COUNT(*)                                    AS nb_claims
FROM core.claims
WHERE occurrence_date IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- Q2. Yearly claim volume
SELECT
    EXTRACT(YEAR FROM occurrence_date)::int AS year,
    COUNT(*)                                 AS nb_claims
FROM core.claims
WHERE occurrence_date IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- Q3. Claim volume per quarter
SELECT
    EXTRACT(YEAR FROM occurrence_date)::int  AS year,
    EXTRACT(QUARTER FROM occurrence_date)::int AS quarter,
    COUNT(*)                                  AS nb_claims
FROM core.claims
WHERE occurrence_date IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2;


-- ============================================================
-- SECTION 2 — CLAIM FREQUENCY BY DIMENSION
-- ============================================================

-- Q4. Frequency by product
SELECT
    p.product_name,
    COUNT(DISTINCT c.contract_id)           AS nb_contracts,
    COUNT(cl.claim_id)                      AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency
FROM core.contracts c
JOIN core.ref_products p  ON p.product_id = c.product_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY p.product_name
ORDER BY frequency DESC;

-- Q5. Frequency by channel
SELECT
    ch.channel_name,
    COUNT(DISTINCT c.contract_id)           AS nb_contracts,
    COUNT(cl.claim_id)                      AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency
FROM core.contracts c
JOIN core.ref_channels ch ON ch.channel_id = c.channel_id
LEFT JOIN core.claims cl  ON cl.contract_id = c.contract_id
GROUP BY ch.channel_name
ORDER BY frequency DESC;

-- Q6. Frequency by risk zone
SELECT
    rz.risk_zone_name,
    COUNT(DISTINCT c.contract_id)           AS nb_contracts,
    COUNT(cl.claim_id)                      AS nb_claims,
    ROUND(COUNT(cl.claim_id)::numeric
          / NULLIF(COUNT(DISTINCT c.contract_id), 0), 4) AS frequency
FROM core.contracts c
JOIN core.ref_cities ci     ON ci.city_id = c.city_id
JOIN core.ref_risk_zones rz ON rz.risk_zone_id = ci.risk_zone_id
LEFT JOIN core.claims cl    ON cl.contract_id = c.contract_id
GROUP BY rz.risk_zone_name
ORDER BY frequency DESC;

-- Q7. Frequency by claim type per product
SELECT
    p.product_name,
    ct.claim_type_name,
    COUNT(*) AS nb_claims
FROM core.claims cl
JOIN core.contracts c     ON c.contract_id = cl.contract_id
JOIN core.ref_products p  ON p.product_id  = c.product_id
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
GROUP BY p.product_name, ct.claim_type_name
ORDER BY p.product_name, nb_claims DESC;


-- ============================================================
-- SECTION 3 — SEVERITY AND DISTRIBUTION
-- ============================================================

-- Q8. Severity statistics per claim type
SELECT
    ct.claim_type_name,
    COUNT(*)                                     AS nb_claims,
    ROUND(AVG(damage_amount_eur), 2)             AS avg_damage,
    ROUND(STDDEV(damage_amount_eur), 2)          AS stddev_damage,
    ROUND(MIN(damage_amount_eur), 2)             AS min_damage,
    ROUND(MAX(damage_amount_eur), 2)             AS max_damage,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY damage_amount_eur)::numeric, 2) AS median_damage
FROM core.claims cl
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
GROUP BY ct.claim_type_name
ORDER BY avg_damage DESC;

-- Q9. Severity distribution by quartile
WITH ranked AS (
    SELECT
        claim_id,
        damage_amount_eur,
        NTILE(4) OVER (ORDER BY damage_amount_eur) AS quartile
    FROM core.claims
    WHERE damage_amount_eur IS NOT NULL
)
SELECT
    quartile,
    COUNT(*)                          AS nb_claims,
    ROUND(MIN(damage_amount_eur),2)   AS min_dmg,
    ROUND(AVG(damage_amount_eur),2)   AS avg_dmg,
    ROUND(MAX(damage_amount_eur),2)   AS max_dmg
FROM ranked
GROUP BY quartile
ORDER BY quartile;

-- Q10. Claims by severity bucket
SELECT
    CASE
        WHEN damage_amount_eur <  500 THEN '0-500'
        WHEN damage_amount_eur < 2000 THEN '500-2000'
        WHEN damage_amount_eur < 5000 THEN '2000-5000'
        WHEN damage_amount_eur < 20000 THEN '5000-20000'
        ELSE '20000+'
    END AS severity_bucket,
    COUNT(*) AS nb_claims
FROM core.claims
WHERE damage_amount_eur IS NOT NULL
GROUP BY 1
ORDER BY MIN(damage_amount_eur);


-- ============================================================
-- SECTION 4 — PROCESSING DELAYS
-- ============================================================

-- Q11. Declaration delay (occurrence → declaration)
SELECT
    ROUND(AVG(declaration_date - occurrence_date), 2) AS avg_delay_days,
    MIN(declaration_date - occurrence_date)            AS min_delay,
    MAX(declaration_date - occurrence_date)            AS max_delay,
    COUNT(*)                                           AS nb_claims
FROM core.claims
WHERE occurrence_date IS NOT NULL
  AND declaration_date IS NOT NULL;

-- Q12. Declaration delay by claim type
SELECT
    ct.claim_type_name,
    COUNT(*)                                          AS nb_claims,
    ROUND(AVG(declaration_date - occurrence_date), 2) AS avg_delay_days
FROM core.claims cl
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
WHERE occurrence_date IS NOT NULL
  AND declaration_date IS NOT NULL
GROUP BY ct.claim_type_name
ORDER BY avg_delay_days DESC;

-- Q13. Delay distribution buckets
SELECT
    CASE
        WHEN declaration_date < occurrence_date         THEN 'negative'
        WHEN declaration_date - occurrence_date <= 7    THEN '0-7 days'
        WHEN declaration_date - occurrence_date <= 30   THEN '8-30 days'
        WHEN declaration_date - occurrence_date <= 90   THEN '31-90 days'
        ELSE '90+ days'
    END AS delay_bucket,
    COUNT(*) AS nb_claims
FROM core.claims
WHERE occurrence_date IS NOT NULL
  AND declaration_date IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;


-- ============================================================
-- SECTION 5 — ACCEPTANCE / REJECTION RATES
-- ============================================================

-- Q14. Claim status distribution
SELECT
    cs.status_name,
    COUNT(*) AS nb_claims,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM core.claims cl
JOIN core.ref_claim_statuses cs ON cs.status_id = cl.status_id
GROUP BY cs.status_name
ORDER BY nb_claims DESC;

-- Q15. Rejection rate by claim type
SELECT
    ct.claim_type_name,
    COUNT(*)                                                AS nb_claims,
    COUNT(*) FILTER (WHERE cs.status_name = 'Rejected')     AS nb_rejected,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE cs.status_name = 'Rejected')
        / NULLIF(COUNT(*), 0), 2
    ) AS rejection_rate_pct
FROM core.claims cl
JOIN core.ref_claim_types ct    ON ct.claim_type_id = cl.claim_type_id
JOIN core.ref_claim_statuses cs ON cs.status_id    = cl.status_id
GROUP BY ct.claim_type_name
ORDER BY rejection_rate_pct DESC;


-- ============================================================
-- SECTION 6 — COST PER CLAIM AND PER CONTRACT
-- ============================================================

-- Q16. Total cost per contract (contracts with claims only)
SELECT
    c.contract_id,
    p.product_name,
    COUNT(cl.claim_id)                        AS nb_claims,
    ROUND(SUM(cl.damage_amount_eur), 2)       AS total_damage,
    ROUND(SUM(cl.indemnified_amount_eur), 2)  AS total_indemnified
FROM core.contracts c
JOIN core.ref_products p ON p.product_id = c.product_id
JOIN core.claims cl      ON cl.contract_id = c.contract_id
GROUP BY c.contract_id, p.product_name
ORDER BY total_damage DESC
LIMIT 20;

-- Q17. Average cost per claim by product
SELECT
    p.product_name,
    COUNT(cl.claim_id)                        AS nb_claims,
    ROUND(AVG(cl.damage_amount_eur), 2)       AS avg_damage,
    ROUND(AVG(cl.indemnified_amount_eur), 2)  AS avg_indemnified
FROM core.claims cl
JOIN core.contracts c    ON c.contract_id = cl.contract_id
JOIN core.ref_products p ON p.product_id  = c.product_id
GROUP BY p.product_name
ORDER BY avg_damage DESC;


-- ============================================================
-- SECTION 7 — RECURRING / MULTI-CLAIMS
-- ============================================================

-- Q18. Contracts with multiple claims
SELECT
    contract_id,
    COUNT(*)                    AS nb_claims,
    ROUND(SUM(damage_amount_eur), 2) AS total_damage
FROM core.claims
GROUP BY contract_id
HAVING COUNT(*) > 1
ORDER BY nb_claims DESC, total_damage DESC;

-- Q19. Distribution of claims per contract
SELECT
    nb_claims,
    COUNT(*) AS nb_contracts
FROM (
    SELECT contract_id, COUNT(*) AS nb_claims
    FROM core.claims
    GROUP BY contract_id
) t
GROUP BY nb_claims
ORDER BY nb_claims;


-- ============================================================
-- SECTION 8 — OUTLIERS (TOP / BOTTOM)
-- ============================================================

-- Q20. Top 10 most expensive claims
SELECT
    cl.claim_id,
    cl.contract_id,
    p.product_name,
    ct.claim_type_name,
    cl.damage_amount_eur,
    cl.indemnified_amount_eur
FROM core.claims cl
JOIN core.contracts c       ON c.contract_id = cl.contract_id
JOIN core.ref_products p    ON p.product_id  = c.product_id
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
ORDER BY cl.damage_amount_eur DESC NULLS LAST
LIMIT 10;

-- Q21. Top 10 cheapest claims
SELECT
    cl.claim_id,
    cl.damage_amount_eur,
    ct.claim_type_name
FROM core.claims cl
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
WHERE cl.damage_amount_eur IS NOT NULL
ORDER BY cl.damage_amount_eur ASC
LIMIT 10;

-- Q22. Claims above 3× type average (potential outliers)
WITH type_avg AS (
    SELECT claim_type_id, AVG(damage_amount_eur) AS avg_dmg
    FROM core.claims
    GROUP BY claim_type_id
)
SELECT
    cl.claim_id,
    ct.claim_type_name,
    cl.damage_amount_eur,
    ROUND(ta.avg_dmg, 2) AS type_avg
FROM core.claims cl
JOIN type_avg ta              ON ta.claim_type_id = cl.claim_type_id
JOIN core.ref_claim_types ct  ON ct.claim_type_id = cl.claim_type_id
WHERE cl.damage_amount_eur > ta.avg_dmg * 3
ORDER BY cl.damage_amount_eur DESC;


-- ============================================================
-- END
-- ============================================================
