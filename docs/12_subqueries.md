# Phase 12 — Subqueries

## Purpose

Master subqueries (scalar, correlated, IN / EXISTS, derived tables) on
the `core` schema with business-oriented queries.

## Covered subquery types

| Section | Type |
|---|---|
| 1 | Scalar subquery (returns one value) |
| 2 | IN / NOT IN |
| 3 | EXISTS / NOT EXISTS |
| 4 | Derived table (subquery in FROM) |
| 5 | Subquery in SELECT |
| 6 | Correlated subquery |
| 7 | Subquery vs JOIN comparison |
| 8 | Advanced business subqueries |

## Query catalog

The file `sql/04_analytics/03_subqueries.sql` contains 20 queries:

| # | Query | Type |
|---|---|---|
| 1 | Contracts above global avg premium | scalar |
| 2 | Claims above global avg damage | scalar |
| 3 | Contracts of clients with CSP | IN |
| 4 | Clients with no claim | NOT IN |
| 5 | Contracts with at least one claim | IN |
| 6 | Contracts with a claim | EXISTS |
| 7 | Contracts without a claim | NOT EXISTS |
| 8 | Clients with an Auto contract | EXISTS |
| 9 | Avg premium per product | derived table |
| 10 | Contracts above their product avg | derived + join |
| 11 | Client's contract count per contract | subquery in SELECT |
| 12 | Claim avg type damage per claim | subquery in SELECT |
| 13 | Contract above its product avg (correlated) | correlated |
| 14 | Clients above avg contract count | correlated |
| 15 | Contracts with claim (subquery) | IN |
| 16 | Contracts with claim (JOIN) | JOIN equivalent |
| 17 | Claims declared before occurrence | business anomaly |
| 18 | Max damage per claim type | correlated MAX |
| 19 | Clients with avg premium > 1000 | correlated AVG |
| 20 | Top 10% premium per product | PERCENTILE_CONT |

## Key learnings

- **Scalar subquery**: must return one row. Use MAX/MIN/AVG to be safe.
- **IN vs EXISTS**: EXISTS is often more efficient when the subquery
  references the outer query (correlated).
- **NOT IN vs NOT EXISTS**: NOT IN fails when the subquery returns NULL.
  Prefer NOT EXISTS.
- **Derived table**: forces materialization — useful for pre-aggregation.
- **Correlated subquery**: reruns for each outer row — powerful but
  often slower than JOIN.

## Business insight examples

- **Q17**: claims declared before occurrence — fraud/error signal
  (47 such rows exist).
- **Q20**: top 10% premium per product — high-value customer targeting.

## Files

- `sql/04_analytics/03_subqueries.sql`
- `docs/12_subqueries.md`
