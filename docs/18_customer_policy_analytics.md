# Phase 18 — Customer / Policy Analytics

## Purpose
Analyze clients and contracts: portfolio composition, lifetime,
renewals, multi-equipment, customer value, churn risk.

## Sections

| Section | Focus |
|---|---|
| 1 | Client portfolio |
| 2 | Contract portfolio |
| 3 | Contract lifetime |
| 4 | Renewals and cancellations |
| 5 | Multi-equipment (multi-contract) |
| 6 | Customer value |
| 7 | Churn risk |

## Query catalog

The file `sql/04_analytics/09_customer_policy_analytics.sql` contains 22 queries:

| # | Query |
|---|---|
| 1 | Portfolio overview |
| 2 | Clients by number of contracts |
| 3 | Clients by gender |
| 4 | Clients by age band |
| 5 | Clients by CSP |
| 6 | Contracts per product |
| 7 | Contracts per channel |
| 8 | Contracts per city |
| 9 | Contracts per risk zone |
| 10 | Average contract duration |
| 11 | Duration by product |
| 12 | Longest contracts |
| 13 | Contract status distribution |
| 14 | Status distribution by product |
| 15 | Renewal/cancellation by year |
| 16 | Multi-contract clients |
| 17 | Multi-product clients |
| 18 | Top 20 clients by premium |
| 19 | Top 20 clients by claims |
| 20 | Clients with negative margin |
| 21 | Cancelled contracts by product |
| 22 | Churn rate per product |

## Key learnings

- **Ratio metrics**: `COUNT(*) / COUNT(DISTINCT ...)` for contracts per client.
- **Age bands**: CASE + GROUP BY.
- **Duration**: `end_date - start_date` on DATE returns integer.
- **Customer lifetime value (CLV)**: SUM of premium per client.
- **Churn**: FILTER on status.

## Business insight

- **Q5**: CSP distribution reveals target market.
- **Q12**: longest contracts — value for retention.
- **Q17**: multi-product clients — target for cross-sell.
- **Q20**: negative-margin clients — risk to profitability.
- **Q22**: churn rate per product — retention priority.

## Files

- `sql/04_analytics/09_customer_policy_analytics.sql`
- `docs/18_customer_policy_analytics.md`
