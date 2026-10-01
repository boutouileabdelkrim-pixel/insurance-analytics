# 02_staging — Data Quality and Cleaning

Scripts in this folder transform `raw` data into clean, typed `staging` tables.

## Execution order

| # | File                          | Purpose                              |
|---|-------------------------------|--------------------------------------|
| 0 | `00_date_helpers.sql`         | `staging.parse_date` function        |
| 1 | `01_quality_diagnostics.sql`  | Read-only diagnostics                |
| 2 | `02_create_staging_tables.sql`| Create empty staging tables          |
| 3 | `03_populate_staging.sql`     | Clean + populate staging tables      |

## Running everything
psql -d insurance_analytics
\pset pager off
\i sql/02_staging/00_date_helpers.sql
\i sql/02_staging/02_create_staging_tables.sql
\i sql/02_staging/03_populate_staging.sql


###########

`01_quality_diagnostics.sql` is optional, used for investigation only.

## Cleaning rules
See `docs/06_staging.md` for the full list of rules.

