# Phase 24 — Materialized Views

## Purpose
Precompute heavy analytics into materialized views for fast reads.

## Materialized views catalog

| MV | Purpose | Refresh |
|----|---------|---------|
| mv_product_kpi | Global KPI per product | on demand |
| mv_channel_kpi | Global KPI per channel | on demand |
| mv_city_kpi | KPI per city (heavy joins) | on demand |
| mv_monthly_premium | Monthly premium timeline | on demand |
| mv_client_360 | Full client 360 | on demand |

## Refresh strategies
- **On demand**: `REFRESH MATERIALIZED VIEW analytics.mv_xxx;`
- **Concurrent**: `REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.mv_xxx;` (requires UNIQUE index, no lock).
- **Scheduled**: not covered (would need cron / pg_cron).

## Performance gain
- A materialized view stores results on disk.
- Reads are O(1) instead of re-running heavy joins.
- Trade-off: staleness (data must be refreshed).

## Unique indexes
Each MV has a UNIQUE index, enabling:
- CONCURRENT refresh.
- Fast lookups on the key.

## Files
- `sql/05_advanced/02_create_materialized_views.sql`
- `docs/24_materialized_views.md`
