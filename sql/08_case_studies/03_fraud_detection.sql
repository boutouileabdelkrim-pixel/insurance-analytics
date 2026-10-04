-- ============================================================
-- Case Study 3 — Fraud Detection
-- Question: Which claims are most suspicious? Prioritize investigation.
-- ============================================================

-- STEP 1 — Suspicion score per claim (weighted signals)
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
        cl.claim_id,
        cl.contract_id,
        cl.damage_amount_eur,
        cl.occurrence_date,
        cl.declaration_date,
        c.start_date,
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
SELECT
    claim_id,
    contract_id,
    damage_amount_eur,
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
ORDER BY suspicion_score DESC
LIMIT 30;

-- STEP 2 — Expert concentration (network signal)
SELECT
    expert_id,
    COUNT(*) AS nb_claims,
    COUNT(DISTINCT contract_id) AS nb_contracts,
    ROUND(AVG(damage_amount_eur), 2) AS avg_damage
FROM core.claims
WHERE expert_id IS NOT NULL
GROUP BY expert_id
HAVING COUNT(*) > 3
ORDER BY nb_claims DESC;

-- STEP 3 — Prioritized investigation list (top 20)
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
    cl.claim_id,
    cli.client_name,
    p.product_name,
    ct.claim_type_name,
    cl.damage_amount_eur,
    (cl.declaration_date - cl.occurrence_date) AS delay_days,
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
ORDER BY suspicion_score DESC, cl.damage_amount_eur DESC
LIMIT 20;
