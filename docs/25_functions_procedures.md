# Phase 25 — Functions / Procedures (PL/pgSQL)

## Purpose
Industrialize recurring computations as reusable functions and procedures.

## Functions catalog

| Name | Type | Parameters | Returns |
|------|------|------------|---------|
| fn_loss_ratio | PL/pgSQL | product_id | numeric |
| fn_claim_frequency | SQL | product_id | numeric |
| fn_client_age_band | SQL IMMUTABLE | age | text |
| fn_premium_band | SQL IMMUTABLE | premium | text |
| fn_top_n_products | SQL SETOF | n | TABLE |

## Procedures catalog

| Name | Purpose |
|------|---------|
| sp_refresh_all_mv | Refresh all materialized views |
| sp_show_kpi_summary | Print KPI summary via RAISE NOTICE |

## Volatility
- IMMUTABLE: same input → same output (candidate for indexing).
- STABLE: consistent within a transaction.
- VOLATILE (default): may change at any time.

## Key learnings
- LANGUAGE SQL: simple, inlined.
- LANGUAGE plpgsql: complex logic, loops, exceptions.
- RETURNS TABLE(...) for set-returning functions.
- PROCEDURE (PostgreSQL 11+): supports COMMIT/ROLLBACK inside.
- SECURITY: functions run as caller by default.

## Files
- `sql/05_advanced/03_create_functions.sql`
- `docs/25_functions_procedures.md`
