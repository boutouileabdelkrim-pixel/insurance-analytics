# Phase 21 — Cohort / Retention / Churn Analytics

## Purpose
Analyze loyalty, retention, and attrition across cohorts and dimensions.

## Sections
1. Cohorts (by subscription year)
2. Retention rates per cohort
3. Churn rates (global, by product, channel, zone)
4. LTV per cohort
5. Churn factors (age band, CSP)
6. Cohort comparison

## Definitions
- Cohort: group of contracts subscribed the same year.
- Retention: contract still Active or Renewed.
- Churn: contract Cancelled.
- LTV: total premium per client in the cohort.

## Query file
`sql/04_analytics/12_cohort_retention_churn.sql`

## Key learnings
- FILTER (WHERE ...) for conditional counts.
- Cohort comparison via CTE.
- Churn rate = cancelled / total.
- LTV = SUM(premium) / COUNT(DISTINCT client).

## Business insight
- Churn by product reveals retention priorities.
- Churn by channel reveals acquisition quality.
- Age band churn guides targeting.
- Cohort trends show portfolio dynamics.
