# Phase 17 — Claims Analytics

## Purpose

Analyze claims from volume, frequency, severity, delays, cost,
recurrence, and outlier perspectives.

## Sections

| Section | Focus |
|---|---|
| 1 | Claim volume over time |
| 2 | Frequency by product/channel/zone |
| 3 | Severity and distribution |
| 4 | Processing delays |
| 5 | Acceptance / rejection |
| 6 | Cost per claim and per contract |
| 7 | Recurring / multi-claims |
| 8 | Outliers (top / bottom) |

## Query catalog

The file `sql/04_analytics/08_claims_analytics.sql` contains 22 queries:

| # | Query |
|---|---|
| 1 | Monthly claim volume |
| 2 | Yearly claim volume |
| 3 | Quarterly claim volume |
| 4 | Frequency by product |
| 5 | Frequency by channel |
| 6 | Frequency by risk zone |
| 7 | Frequency by claim type per product |
| 8 | Severity statistics per claim type |
| 9 | Severity distribution by quartile |
| 10 | Claims by severity bucket |
| 11 | Global declaration delay |
| 12 | Declaration delay by claim type |
| 13 | Delay distribution buckets |
| 14 | Claim status distribution |
| 15 | Rejection rate by claim type |
| 16 | Total cost per contract |
| 17 | Average cost per claim by product |
| 18 | Contracts with multiple claims |
| 19 | Claims-per-contract distribution |
| 20 | Top 10 most expensive claims |
| 21 | Top 10 cheapest claims |
| 22 | Claims above 3× type average |

## Key learnings

- **NTILE(4)** for severity quartiles.
- **PERCENTILE_CONT(0.5)** for median.
- **STDDEV** measures dispersion.
- **Delay buckets** via CASE reveal patterns.
- **FILTER (WHERE ...)** for conditional counts.

## Business insight

- **Q4**: Auto frequency higher than Home.
- **Q12**: process delays differ by claim type.
- **Q15**: rejection rate signals underwriting quality.
- **Q18**: recurring claims reveal risk patterns.
- **Q22**: outliers can signal fraud or exceptional events.

## Files

- `sql/04_analytics/08_claims_analytics.sql`
- `docs/17_claims_analytics.md`

