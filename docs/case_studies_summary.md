# Case Studies Summary

Four end-to-end case studies demonstrating applied SQL analytics.

## CS1 — Product Profitability (Loss Ratio)

**Question**: Which products are profitable? Where are under-priced segments?

**Approach**:
1. Compute loss ratio per product.
2. Compute combined ratio with assumed 25% expense ratio.
3. Breakdown by product × risk zone.
4. Identify segments with loss ratio > 1.

**Deliverables**:
- SQL: `sql/08_case_studies/01_product_profitability.sql`
- Doc: `docs/case_studies/CS1_product_profitability.md`

**KPIs used**: loss ratio, combined ratio, premium, indemnified.

## CS2 — Churn & Retention

**Question**: Who churns? Why? Which segments to prioritize?

**Approach**:
1. Global churn rate.
2. Churn by product, channel, zone, age band, CSP.

**Deliverables**:
- SQL: `sql/08_case_studies/02_churn_analysis.sql`
- Doc: `docs/case_studies/CS2_churn_analysis.md`

**KPIs used**: churn rate, retention rate.

## CS3 — Fraud Detection

**Question**: Which claims are suspicious? Prioritize investigation.

**Approach**:
1. Weighted suspicion score (5 signals).
2. Expert concentration analysis.
3. Prioritized investigation list.

**Signals weighted**:
- Negative delay (30 pts)
- Damage > 3× type avg (25 pts)
- Damage > 5× indemnified (20 pts)
- Early claim within 7 days (15 pts)
- Multi-claim client (10 pts)

**Deliverables**:
- SQL: `sql/08_case_studies/03_fraud_detection.sql`
- Doc: `docs/case_studies/CS3_fraud_detection.md`

## CS4 — Client Segmentation (RFM)

**Question**: How to segment clients for targeted actions?

**Approach**:
1. Compute R, F, M, S per client.
2. Score each axis 1–5 via NTILE(5).
3. Assign 7 segments via CASE rules.
4. Measure segment size and value.

**Segments**: Champions, Loyal High-Value, New Promising,
At Risk High-Value, Lost Low-Value, High-Risk, Standard.

**Deliverables**:
- SQL: `sql/08_case_studies/04_client_segmentation.sql`
- Doc: `docs/case_studies/CS4_client_segmentation.md`

## Cross-cutting SQL techniques used

| Technique | CS1 | CS2 | CS3 | CS4 |
|-----------|-----|-----|-----|-----|
| JOINs | ✓ | ✓ | ✓ | ✓ |
| CTEs | ✓ | | ✓ | ✓ |
| Window functions | | | | ✓ |
| CASE expressions | ✓ | ✓ | ✓ | ✓ |
| Aggregations | ✓ | ✓ | ✓ | ✓ |
| FILTER (WHERE) | | ✓ | | |
| NTILE | | | | ✓ |
| ARRAY_REMOVE | | | ✓ | |
