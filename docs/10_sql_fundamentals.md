# Phase 10 — Applied Fundamental SQL

## Purpose

Apply the SQL fundamentals on the `core` schema to build a first set
of business-oriented queries.

## Covered concepts

| Section | Concepts |
|---|---|
| 1 | SELECT, projection, LIMIT |
| 2 | WHERE, comparison, AND/OR |
| 3 | ORDER BY, DESC, NULLS LAST |
| 4 | COUNT, AVG, MIN, MAX, SUM, ROUND |
| 5 | GROUP BY, HAVING |
| 6 | NULL handling (IS NULL, COALESCE) |
| 7 | CASE expressions |
| 8 | UNION, INTERSECT, EXCEPT |

## Query catalog

The file `sql/04_analytics/01_sql_fundamentals.sql` contains 20 queries:

| # | Query | Concept |
|---|---|---|
| 1 | First 20 contracts | LIMIT |
| 2 | Distinct products | projection |
| 3 | Contract statuses | reference listing |
| 4 | Premium > 2000 EUR | WHERE |
| 5 | Female clients with CSP | WHERE + NULL |
| 6 | Auto contracts in 2024 | JOIN + WHERE on date |
| 7 | Top 10 expensive contracts | ORDER BY DESC |
| 8 | Top 10 claims by damage | ORDER BY DESC |
| 9 | Global contract stats | aggregates |
| 10 | Global claim stats | aggregates |
| 11 | Contracts + premium by product | GROUP BY |
| 12 | Claim types with >20 claims | GROUP BY + HAVING |
| 13 | Risk zones with avg premium >900 | HAVING |
| 14 | Clients with missing age | IS NULL + GROUP BY |
| 15 | Claims without liability | IS NULL |
| 16 | Contract premium band | CASE |
| 17 | Contracts per premium band | CASE + GROUP BY |
| 18 | Products with contracts + claims | INTERSECT |
| 19 | Products with contracts but no claims | EXCEPT |
| 20 | Combined statuses | UNION |

## Key learnings

- **NULL handling**: `IS NULL`, `COALESCE`, `NULLS LAST` are essential,
  because many columns contain NULL (gender, csp_id, liability_id, etc.).
- **GROUP BY vs HAVING**: HAVING filters aggregated results; WHERE filters
  individual rows before aggregation.
- **Set operators**: useful for comparing populations (products with vs
  without claims).
- **CASE**: essential for deriving categorical buckets from numeric ranges.

## Files

- `sql/04_analytics/01_sql_fundamentals.sql`
- `docs/10_sql_fundamentals.md`
