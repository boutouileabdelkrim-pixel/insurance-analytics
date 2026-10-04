# Case Study 3 — Fraud Detection

## Business question
Which claims exhibit fraud signals? How to prioritize investigation?

## SQL approach
1. Weighted suspicion score per claim (5 signals).
2. Expert concentration (network).
3. Prioritized investigation list.

## Suspicion score

| Signal | Weight |
|--------|--------|
| Negative delay (declaration < occurrence) | 30 |
| Damage > 3× type average | 25 |
| Damage > 5× indemnified | 20 |
| Claim within 7 days of subscription | 15 |
| Client with 3+ claims | 10 |

Max = 100. Threshold = 0.

## Files
- `sql/08_case_studies/03_fraud_detection.sql`

## Key queries

### Q1: Suspicion score per claim
Ranks claims with weighted signals. Output includes triggered_signals array.

### Q2: Expert concentration
Experts with many claims → potential network.

### Q3: Prioritized investigation list
Top 20 with client name, product, claim type, and score.

## Business use
- Send top-20 to fraud investigation team.
- Investigate experts with > 3 claims.
- Combine with expert concentration for network detection.

## Recommendations (framework)
- **Score ≥ 50**: investigate immediately.
- **30 ≤ Score < 50**: queue for review.
- **Score < 30**: monitor only.
- **Expert with > 5 claims**: audit.

## Files
- `sql/08_case_studies/03_fraud_detection.sql`
- `docs/case_studies/CS3_fraud_detection.md`
