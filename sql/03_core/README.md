# 03_core — Core Schema

Implementation of the relational model (Phase 7) with full constraints.

## Execution order

| # | File | Purpose |
|---|------|---------|
| 1 | `01_create_reference_tables.sql` | Create 13 reference tables |
| 2 | `02_create_core_tables.sql`      | Create 4 core tables |
| 3 | `03_populate_reference_tables.sql` | Populate reference tables |
| 4 | `04_populate_core_tables.sql`    | Populate core tables |
| 5 | `05_verify_integrity.sql`        | Verify referential integrity |

## Running from scratch
psql -d insurance_analytics
\pset pager off
\i sql/03_core/01_create_reference_tables.sql
\i sql/03_core/02_create_core_tables.sql
\i sql/03_core/03_populate_reference_tables.sql
\i sql/03_core/04_populate_core_tables.sql
\i sql/03_core/05_verify_integrity.sql


## Tables

**Reference (13)**: `ref_products`, `ref_channels`, `ref_csp`, `ref_risk_zones`,
`ref_cities`, `ref_contract_statuses`, `ref_claim_types`, `ref_claim_statuses`,
`ref_liabilities`, `ref_fuel_types`, `ref_vehicle_brands`, `ref_vehicle_usages`,
`ref_vehicle_colors`.

**Core (4)**: `clients`, `contracts`, `claims`, `vehicles`.
