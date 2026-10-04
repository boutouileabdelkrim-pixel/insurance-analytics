# Case Study 2 — Churn & Retention

## Business question
Which segments have the highest churn rate? Where to focus retention
efforts?

## SQL approach
1. Global churn rate.
2. Churn by product, channel, zone, age band, CSP.
3. Cross-tab to identify high-churn combos.

## Files
- `sql/08_case_studies/02_churn_analysis.sql`

## Definitions
- **Churn** = contract status = 'Cancelled'.
- **Churn rate** = cancelled / total.

## Key queries

### Q1: Global churn rate
Baseline for comparison.

### Q2: Churn by product
Identifies products losing customers fastest.

### Q3: Churn by channel
Reveals acquisition quality (e.g., Web vs Broker).

### Q4: Churn by risk zone
Geographic retention patterns.

### Q5: Churn by age band
Demographic drivers.

### Q6: Churn by CSP
Socio-professional drivers.

## Recommendations (framework)
- **Churn > 25%**: urgent retention action.
- **15% < Churn < 25%**: monitor, target retention campaigns.
- **Churn < 15%**: healthy.
- **Channel with high churn**: re-evaluate acquisition strategy.
- **CSP/age band with high churn**: customize offers.

## Files
- `sql/08_case_studies/02_churn_analysis.sql`
- `docs/case_studies/CS2_churn_analysis.md`
