# Phase 13 — Common Table Expressions (CTE)

## Purpose

Structure complex queries into readable, maintainable steps using CTEs.

## Covered CTE patterns

| Section | Pattern |
|---|---|
| 1 | Simple CTE |
| 2 | Multiple chained CTEs |
| 3 | Recursive CTE |
| 4 | CTE referenced multiple times |
| 5 | CTE vs subquery comparison |
| 6 | Refactoring complex queries |

## Query catalog

The file `sql/04_analytics/04_cte.sql` contains 12 queries:

| # | Query | Pattern |
|---|---|---|
| 1 | Contracts above avg premium | Simple |
| 2 | Claims per claim type | Simple |
| 3 | Contracts by risk zone | Chained |
| 4 | Client → contract → claim pipeline | Chained |
| 5 | Numbers 1..10 | Recursive |
| 6 | Monthly buckets | Recursive |
| 7 | Product stats referenced twice | Reuse |
| 8 | Top clients (CTE) | CTE version |
| 9 | Top clients (subquery) | Subquery version |
| 10 | Loss ratio per product | Refactoring |
| 11 | Claim severity per product | Refactoring |
| 12 | Portfolio summary per channel | Multi-CTE |

## Key learnings

- **Readability**: CTEs name intermediate steps, making queries self-documenting.
- **Reusability**: a CTE can be referenced multiple times in the main query.
- **Recursion**: `WITH RECURSIVE` enables hierarchies and date ranges.
- **Performance**: CTEs in PostgreSQL 12+ are inlined when possible.
- **Business value**: multi-CTE pipelines compute KPIs (loss ratio,
  claim frequency) without nested subqueries.

## Business insight

- **Q10**: loss ratio per product — key insurance KPI.
- **Q12**: claim frequency per channel — acquisition quality signal.

## Files

- `sql/04_analytics/04_cte.sql`
- `docs/13_cte.md`
