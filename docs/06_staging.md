# Phase 6 — Data Quality and Cleaning (staging)

## Purpose
Transform raw data into clean, typed tables in the `staging` schema.

## Quality dimensions checked
- **Completeness** : count of NULL / empty values per column
- **Uniqueness** : primary key candidates verified
- **Validity** : regex checks on dates, numeric strings, currencies
- **Consistency** : date order, referential integrity
- **Accuracy** : plausible ranges (age 18-100, no negative amounts)

## Cleaning rules applied

### 1. Empty strings -> NULL
All text columns: `NULLIF(col, '')`

### 2. Date parsing (helper function `staging.parse_date`)
Five formats supported:
- `YYYY-MM-DD` (ISO)         -> cast to DATE
- `DD/MM/YYYY` (European)    -> to_date(..., 'DD/MM/YYYY')
- `MM/DD/YYYY` (US)          -> to_date(..., 'MM/DD/YYYY')
- `DD-MM-YYYY` (European)    -> to_date(..., 'DD-MM-YYYY')
- `MM-DD-YYYY` (US)          -> to_date(..., 'MM-DD-YYYY')

Disambiguation: if day > 12, use DD/MM/YYYY; if month > 12, use MM/DD/YYYY;
otherwise default to DD/MM/YYYY (European context).

### 3. Currency normalization
- Extract numeric part: `regexp_replace(col, '[^0-9.]', '', 'g')`
- If value contains `$`: multiply by 0.92 (USD -> EUR fixed rate)
- Other formats (€ suffix, € prefix, EUR, euros, plain number): kept as EUR
- Result stored in `*_eur` columns

### 4. Gender normalization
- `M`, `Male`   -> `M`
- `F`, `Female` -> `F`
- other / empty -> NULL

### 5. city_postal split
- `Paris_75001` -> city = `Paris`, postal_code = `75001`
- Uses `split_part(city_postal, '_', 1)` and `split_part(city_postal, '_', 2)`

### 6. Decimal-string to integer
- `year`            : `'2018.0'` -> `2018`
- `previous_claims` : `'1.0'`    -> `1`
- `power`           : `'90.0'`   -> `90`

## Anomalies preserved (not corrected)
- **47 claims** have `declaration_date < occurrence_date` (declaration before the event).
  This is a business signal, not a data error.
  Kept as-is. To be investigated in Phase 20 (Fraud Analytics).

## Results after cleaning

### Row counts
| Table     | Raw    | Staging | Match |
|-----------|--------|---------|-------|
| contracts | 15000  | 15000   | ✅    |
| claims    | 155    | 155     | ✅    |
| vehicles  | 5390   | 5390    | ✅    |

### Contracts
- start_date parsed : 15000 / 15000 (100%)
- end_date parsed   : 15000 / 15000 (100%)
- annual_premium_eur : min 224.14, max 2849.59, avg 948.34, 0 NULL
- gender distribution: M=5978, F=5926, NULL=3096

### Claims
- occurrence_date parsed  : 155 / 155 (100%)
- declaration_date parsed : 155 / 155 (100%)
- damage_amount_eur       : min 190.01, max 48459.84, avg 4345.04
- indemnified_amount_eur  : avg 2656.64

### Vehicles
- year             : min 2010, max 2024, 273 NULL
- previous_claims  : 0=1214, 1=1245, 2=1166, 3=1230, NULL=535

## Files (execution order matters)
1. `sql/02_staging/00_date_helpers.sql`         - `staging.parse_date` function
2. `sql/02_staging/01_quality_diagnostics.sql`  - diagnostics (read-only)
3. `sql/02_staging/02_create_staging_tables.sql`- table definitions
4. `sql/02_staging/03_populate_staging.sql`     - cleaning + population

## How to run (from scratch)
psql -d insurance_analytics
\pset pager off
\i sql/02_staging/00_date_helpers.sql
\i sql/02_staging/02_create_staging_tables.sql
\i sql/02_staging/03_populate_staging.sql
