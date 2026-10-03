# Phase 14 — Window Functions

## Purpose

Master window functions for time-series, ranking, and comparative analytics.

## Covered concepts

| Section | Concept |
|---|---|
| 1 | OVER() and PARTITION BY |
| 2 | ROW_NUMBER, RANK, DENSE_RANK |
| 3 | LAG, LEAD |
| 4 | FIRST_VALUE, LAST_VALUE |
| 5 | Windowed aggregates |
| 6 | Sliding windows (ROWS BETWEEN) |
| 7 | NTILE |
| 8 | Window + CTE combination |
| 9 | Business applications |

## Query catalog

The file `sql/04_analytics/05_window_functions.sql` contains 20 queries:

| # | Query | Concept |
|---|---|---|
| 1 | Global avg premium | OVER() |
| 2 | Avg per product | PARTITION BY |
| 3 | Ranking per product | ROW_NUMBER/RANK/DENSE_RANK |
| 4 | Top 3 per product | ROW_NUMBER + CTE |
| 5 | Premium evolution | LAG/LEAD |
| 6 | Monthly claim delta | LAG + CTE |
| 7 | First/last claim per contract | FIRST_VALUE/LAST_VALUE |
| 8 | Running total premium | SUM OVER |
| 9 | Claim % per product | windowed aggregate |
| 10 | 3-day moving average | ROWS BETWEEN |
| 11 | Cumulative claims per product | windowed COUNT |
| 12 | Premium quartiles | NTILE(4) |
| 13 | Severity buckets | NTILE(5) |
| 14 | Top 5 clients by premium | RANK + CTE |
| 15 | Monthly premium MoM delta | LAG + CTE |
| 16 | Claim type severity ranking | RANK |
| 17 | Premium percentile per product | PERCENT_RANK |
| 18 | Rolling 30-day claim freq | ROWS BETWEEN 29 PRECEDING |
| 19 | First contract per client | ROW_NUMBER |
| 20 | Cumulative premium per client | SUM OVER PARTITION |

## Key learnings

- **PARTITION BY** defines the window scope.
- **ROW_NUMBER vs RANK**: ROW_NUMBER gives unique numbers, RANK ties share.
- **LAG/LEAD**: access previous/next rows for time-series deltas.
- **Sliding windows**: `ROWS BETWEEN n PRECEDING AND CURRENT ROW` for moving averages.
- **NTILE**: divide rows into N equal buckets (quartiles, deciles).
- **Window functions don't collapse rows** — unlike GROUP BY.

## Business insight

- **Q6**: monthly claim delta reveals trend changes.
- **Q15**: premium MoM delta tracks portfolio growth.
- **Q18**: rolling 30-day frequency detects claim spikes.
- **Q17**: premium percentile identifies high-value contracts.

## Files

- `sql/04_analytics/05_window_functions.sql`
- `docs/14_window_functions.md`
