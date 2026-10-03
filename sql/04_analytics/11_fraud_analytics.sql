-- ============================================================
-- 04_analytics / 11_fraud_analytics.sql
-- Fraud Analytics — SQL-based suspicion rules
-- Phase 20 — Fraud Analytics
-- ============================================================

-- SECTION 1 — BUSINESS RULES CATALOG

SELECT 'R1' AS rule_id, 'Claim declared before occurrence' AS description
UNION ALL SELECT 'R2', 'Claim damage > 3x average of its type'
UNION ALL SELECT 'R3', 'Damage > 5x indemnified'
UNION ALL SELECT 'R4', 'Client with 3+ claims'
UNION ALL SELECT 'R5', 'Claim within 7 days of subscription'
UNION ALL SELECT 'R6', 'Claim with damage = 0'
UNION ALL SELECT 'R7', 'Expert shared on same client'
UNION ALL SELECT 'R8', 'Expert with many claims'
UNION ALL SELECT 'R9', 'Negative processing delay'
UNION ALL SELECT 'R10', 'Client with claims same day';

-- SECTION 2 — ATYPICAL CLAIMS

WITH type_avg AS (
    SELECT claim_type_id, AVG(damage_amount_eur) AS avg_dmg
    FROM core.claims GROUP BY claim_type_id
)
SELECT
    cl.claim_id, cl.contract_id,
    ct.claim_type_name, cl.damage_amount_eur,
    ROUND(ta.avg_dmg, 2) AS type_avg,
    ROUND(cl.damage_amount_eur / NULLIF(ta.avg_dmg, 0), 2) AS ratio
FROM core.claims cl
JOIN type_avg ta             ON ta.claim_type_id = cl.claim_type_id
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
WHERE cl.damage_amount_eur > ta.avg_dmg * 3
ORDER BY ratio DESC;

SELECT
    claim_id, contract_id,
    damage_amount_eur, indemnified_amount_eur,
    ROUND(damage_amount_eur / NULLIF(indemnified_amount_eur, 0), 2) AS ratio
FROM core.claims
WHERE damage_amount_eur IS NOT NULL
  AND indemnified_amount_eur IS NOT NULL
  AND indemnified_amount_eur > 0
  AND damage_amount_eur > 5 * indemnified_amount_eur
ORDER BY ratio DESC;

SELECT
    claim_id, contract_id,
    occurrence_date, declaration_date,
    (declaration_date - occurrence_date) AS negative_delay_days
FROM core.claims
WHERE declaration_date < occurrence_date
ORDER BY negative_delay_days ASC;

-- SECTION 3 — MULTI-CLAIM CLIENTS

SELECT
    c.client_id, cl.client_name,
    COUNT(cl2.claim_id)                  AS nb_claims,
    ROUND(SUM(cl2.damage_amount_eur), 2) AS total_damage
FROM core.contracts c
JOIN core.clients cl ON cl.client_id = c.client_id
JOIN core.claims cl2 ON cl2.contract_id = c.contract_id
GROUP BY c.client_id, cl.client_name
HAVING COUNT(cl2.claim_id) >= 3
ORDER BY nb_claims DESC, total_damage DESC;

-- SECTION 4 — EARLY DECLARATIONS

SELECT
    cl.claim_id, c.contract_id,
    c.start_date AS subscription_date,
    cl.occurrence_date, cl.declaration_date,
    (cl.occurrence_date - c.start_date) AS days_since_subscription
FROM core.claims cl
JOIN core.contracts c ON c.contract_id = cl.contract_id
WHERE cl.occurrence_date IS NOT NULL
  AND c.start_date IS NOT NULL
  AND (cl.occurrence_date - c.start_date) BETWEEN 0 AND 7
ORDER BY days_since_subscription;

SELECT
    COUNT(*) AS nb_early_claims,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM core.claims), 2) AS pct
FROM core.claims cl
JOIN core.contracts c ON c.contract_id = cl.contract_id
WHERE cl.occurrence_date IS NOT NULL
  AND c.start_date IS NOT NULL
  AND (cl.occurrence_date - c.start_date) BETWEEN 0 AND 30;

-- SECTION 5 — DECLARATIVE INCONSISTENCIES

SELECT claim_id, contract_id, damage_amount_eur, indemnified_amount_eur
FROM core.claims WHERE damage_amount_eur = 0;

SELECT claim_id, damage_amount_eur, indemnified_amount_eur
FROM core.claims
WHERE damage_amount_eur IS NOT NULL
  AND indemnified_amount_eur IS NULL
ORDER BY damage_amount_eur DESC LIMIT 20;

-- SECTION 6 — NETWORKS (SHARED EXPERTS)

SELECT expert_id, COUNT(*) AS nb_claims,
       COUNT(DISTINCT contract_id) AS nb_contracts
FROM core.claims
WHERE expert_id IS NOT NULL
GROUP BY expert_id
HAVING COUNT(*) > 1
ORDER BY nb_claims DESC;

WITH experts_per_client AS (
    SELECT c.client_id, cl.expert_id,
           COUNT(DISTINCT c.contract_id) AS nb_contracts,
           COUNT(cl.claim_id)            AS nb_claims
    FROM core.claims cl
    JOIN core.contracts c ON c.contract_id = cl.contract_id
    WHERE cl.expert_id IS NOT NULL
    GROUP BY c.client_id, cl.expert_id
)
SELECT * FROM experts_per_client
WHERE nb_contracts > 1 ORDER BY nb_claims DESC;

SELECT expert_id, occurrence_date, COUNT(*) AS nb_claims_same_day
FROM core.claims
WHERE expert_id IS NOT NULL AND occurrence_date IS NOT NULL
GROUP BY expert_id, occurrence_date
HAVING COUNT(*) > 1
ORDER BY nb_claims_same_day DESC;

-- SECTION 7 — COMPOSITE SUSPICION SCORE

WITH type_avg AS (
    SELECT claim_type_id, AVG(damage_amount_eur) AS avg_dmg
    FROM core.claims GROUP BY claim_type_id
),
multi_claim_clients AS (
    SELECT c.client_id, COUNT(*) AS client_nb_claims
    FROM core.contracts c
    JOIN core.claims cl ON cl.contract_id = c.contract_id
    GROUP BY c.client_id
),
scored AS (
    SELECT
        cl.claim_id, cl.contract_id, cl.damage_amount_eur,
        cl.occurrence_date, cl.declaration_date,
        c.start_date, c.client_id,
        CASE WHEN cl.declaration_date < cl.occurrence_date THEN 30 ELSE 0 END AS s1,
        CASE WHEN cl.damage_amount_eur > ta.avg_dmg * 3 THEN 25 ELSE 0 END AS s2,
        CASE WHEN cl.indemnified_amount_eur > 0
              AND cl.damage_amount_eur > 5 * cl.indemnified_amount_eur
             THEN 20 ELSE 0 END AS s3,
        CASE WHEN (cl.occurrence_date - c.start_date) BETWEEN 0 AND 7
             THEN 15 ELSE 0 END AS s4,
        CASE WHEN mcc.client_nb_claims >= 3 THEN 10 ELSE 0 END AS s5
    FROM core.claims cl
    JOIN core.contracts c ON c.contract_id = cl.contract_id
    LEFT JOIN type_avg ta ON ta.claim_type_id = cl.claim_type_id
    LEFT JOIN multi_claim_clients mcc ON mcc.client_id = c.client_id
)
SELECT claim_id, contract_id, damage_amount_eur,
    (s1 + s2 + s3 + s4 + s5) AS suspicion_score,
    ARRAY_REMOVE(ARRAY[
        CASE WHEN s1 > 0 THEN 'negative_delay'     END,
        CASE WHEN s2 > 0 THEN 'high_damage'        END,
        CASE WHEN s3 > 0 THEN 'over_declared'      END,
        CASE WHEN s4 > 0 THEN 'early_claim'        END,
        CASE WHEN s5 > 0 THEN 'multi_claim_client' END
    ], NULL) AS triggered_signals
FROM scored
WHERE (s1 + s2 + s3 + s4 + s5) > 0
ORDER BY suspicion_score DESC LIMIT 50;

-- SECTION 8 — PRIORITIZED INVESTIGATION LIST

WITH type_avg AS (
    SELECT claim_type_id, AVG(damage_amount_eur) AS avg_dmg
    FROM core.claims GROUP BY claim_type_id
),
multi_claim_clients AS (
    SELECT c.client_id, COUNT(*) AS client_nb_claims
    FROM core.contracts c
    JOIN core.claims cl ON cl.contract_id = c.contract_id
    GROUP BY c.client_id
)
SELECT
    cl.claim_id, cli.client_name, p.product_name,
    ct.claim_type_name, cl.damage_amount_eur,
    cl.occurrence_date, cl.declaration_date,
    (cl.declaration_date - cl.occurrence_date) AS delay_days,
    mcc.client_nb_claims,
    (CASE WHEN cl.declaration_date < cl.occurrence_date THEN 30 ELSE 0 END
   + CASE WHEN cl.damage_amount_eur > ta.avg_dmg * 3 THEN 25 ELSE 0 END
   + CASE WHEN cl.indemnified_amount_eur > 0
           AND cl.damage_amount_eur > 5 * cl.indemnified_amount_eur
          THEN 20 ELSE 0 END
   + CASE WHEN (cl.occurrence_date - c.start_date) BETWEEN 0 AND 7 THEN 15 ELSE 0 END
   + CASE WHEN mcc.client_nb_claims >= 3 THEN 10 ELSE 0 END
    ) AS suspicion_score
FROM core.claims cl
JOIN core.contracts c        ON c.contract_id = cl.contract_id
JOIN core.clients cli        ON cli.client_id = c.client_id
JOIN core.ref_products p     ON p.product_id  = c.product_id
JOIN core.ref_claim_types ct ON ct.claim_type_id = cl.claim_type_id
LEFT JOIN type_avg ta        ON ta.claim_type_id = cl.claim_type_id
LEFT JOIN multi_claim_clients mcc ON mcc.client_id = c.client_id
ORDER BY suspicion_score DESC, cl.damage_amount_eur DESC LIMIT 50;
