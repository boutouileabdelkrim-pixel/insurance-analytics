# Phase 20 — Fraud Analytics

## Purpose
Detect fraud signals via SQL-based rules (no ML).
Produce a prioritized investigation list.

## Business rules catalog

| Rule | Description | Weight |
|------|-------------|--------|
| R1 | Claim declared before occurrence | 30 |
| R2 | Damage > 3× type average | 25 |
| R3 | Damage > 5× indemnified | 20 |
| R4 | Client with 3+ claims | 10 |
| R5 | Claim within 7 days of subscription | 15 |
| R6 | Damage = 0 | - |
| R7 | Expert shared on same client | - |
| R8 | Expert with many claims | - |
| R9 | Negative processing delay | - |
| R10 | Client with claims same day | - |

## Sections
1. Business rules
2. Atypical claims
3. Multi-claim clients
4. Early declarations
5. Declarative inconsistencies
6. Networks (shared experts)
7. Composite suspicion score
8. Prioritized investigation list

## Suspicion score
Weighted sum of 5 signals:
- R1 (negative delay) → 30 pts
- R2 (high damage) → 25 pts
- R3 (over-declared) → 20 pts
- R5 (early claim) → 15 pts
- R4 (multi-claim client) → 10 pts

Max = 100. Threshold: > 0.

## Files
- `sql/04_analytics/11_fraud_analytics.sql`
- `docs/20_fraud_analytics.md`
