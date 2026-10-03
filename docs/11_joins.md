# Phase 11 — JOINs

## Purpose

Master all JOIN types on the `core` schema with realistic insurance
business queries.

## Covered JOIN types

| Section | Type |
|---|---|
| 1 | INNER JOIN |
| 2 | LEFT JOIN |
| 3 | RIGHT JOIN |
| 4 | FULL OUTER JOIN |
| 5 | CROSS JOIN (controlled) |
| 6 | SELF JOIN |
| 7 | Multi-table JOIN (4+ tables) |
| 8 | Composite key JOIN |
| 9 | Anti-join (LEFT JOIN + IS NULL) |

## Query catalog

The file `sql/04_analytics/02_joins.sql` contains 15 queries:

| # | Query | JOIN type |
|---|---|---|
| 1 | Contracts + client + product | INNER |
| 2 | Claims + contract + product + claim_type | INNER × 3 |
| 3 | Claim count per contract | LEFT |
| 4 | Contracts without claims | LEFT + IS NULL |
| 5 | Contract count per client | LEFT |
| 6 | Contract count per product | RIGHT |
| 7 | Products: contracts vs claims | FULL OUTER |
| 8 | Product × channel grid | CROSS |
| 9 | Contracts sharing a client | SELF |
| 10 | Claims sharing an expert | SELF |
| 11 | Full contract profile (6 tables) | MULTI |
| 12 | Full claim profile (6 tables) | MULTI |
| 13 | Contracts with city + risk zone | COMPOSITE |
| 14 | Contracts without vehicle | ANTI |
| 15 | Auto contracts without vehicle | ANTI |

## Key learnings

- **INNER vs LEFT**: LEFT JOIN preserves unmatched rows — essential to
  find contracts with 0 claims or clients with 0 contracts.
- **Anti-join**: `LEFT JOIN ... WHERE right.id IS NULL` detects
  missing relationships (anomalies).
- **SELF JOIN**: useful for detecting pairs (shared client, shared expert).
- **CROSS JOIN**: only when a full cartesian is intentional (coverage grid).
- **Multi-table JOINs**: alias every table, use `ON` explicitly, no
  implicit joins in `WHERE`.

## Business insight examples

- **Q4**: contracts without claims — identify portfolios never activated.
- **Q10**: claims sharing an expert — potential fraud network signal.
- **Q15**: Auto contracts without a vehicle — data quality anomaly.

## Files

- `sql/04_analytics/02_joins.sql`
- `docs/11_joins.md`
