# Phase 28 — Indexes

## Purpose
Design an indexing strategy: simple, composite, partial, expression.

## Index types in PostgreSQL

| Type | Use case |
|------|----------|
| B-tree | Default. Equality, range, sorting. |
| Hash | Equality only. Less common. |
| GIN | Full-text, arrays, JSONB. |
| GiST | Geometric, ranges, full-text. |
| BRIN | Very large tables with natural ordering. |

## Strategy applied

### 1. Foreign key indexes
Every FK column indexed to speed up JOINs.
Files: idx_contracts_client_id, idx_claims_contract_id, etc.

### 2. Date indexes
Range queries on dates (WHERE start_date >= ...).
Files: idx_contracts_start_date, idx_claims_occurrence_date.

### 3. Composite indexes
Multiple columns together for AND conditions.
Files: idx_contracts_product_status, idx_claims_contract_status.

### 4. Partial indexes
Index only rows matching a WHERE clause.
Useful when queries always filter on that condition.
Files: idx_contracts_active, idx_claims_closed.

### 5. Expression indexes
Index on a computation (function of column).
Files: idx_contracts_start_year, idx_clients_lower_name.

## Design principles
- Index on columns used in WHERE, JOIN, ORDER BY.
- Composite order matters: most selective first.
- Partial indexes for skewed conditions.
- Expression indexes for frequent computed filters.
- Avoid over-indexing: every index slows down INSERT/UPDATE/DELETE.

## Key learnings
- `CREATE INDEX IF NOT EXISTS`: idempotent.
- `pg_indexes`: catalog for listing indexes.
- Indexes add write cost: monitor.

## Files
- `sql/06_performance/01_create_indexes.sql`
- `docs/28_indexes.md`
