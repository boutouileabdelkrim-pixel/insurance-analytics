# Phase 23 — Views

## Purpose
Encapsulate reusable analytical queries as views in the `analytics` schema.

## Views catalog

| View | Purpose | Based on |
|------|---------|----------|
| v_contract_details | Denormalized contract info | core (6 tables) |
| v_claim_details | Denormalized claim info | core (5 tables) |
| v_portfolio_kpi | Portfolio KPI per product | v_contract_details |
| v_loss_ratio_per_product | Loss ratio per product | v_contract_details, v_claim_details |
| v_client_metrics | Client 360 (contracts, premium, claims) | core |
| v_monthly_claims | Monthly claim aggregates | core.claims |
| v_churn_by_product | Churn per product | core |

## Layers
1. **Detail views** (V1, V2): denormalized joins.
2. **Aggregate views** (V3, V4, V5, V6, V7): KPI-ready.

## Key learnings
- `CREATE OR REPLACE VIEW` is idempotent.
- Views can reference other views (layered).
- Views don't store data: they run on query.
- Always schema-qualify (analytics.v_...).

## Performance note
- Detail views with many joins can be slow.
- Consider materialized views for heavy aggregations (Phase 24).

## Files
- `sql/05_advanced/01_create_views.sql`
- `docs/23_views.md`

