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

### 2. Date parsing (4 date columns)
- `^\d{4}-\d{2}-\d{2}$`  -> cast to DATE (ISO)
- `^\d{2}/\d{2}/\d{4}$`  -> to_date(..., 'DD/MM/YYYY')
- `^\d{2}-\d{2}-\d{4}$`  -> to_date(..., 'DD-MM-YYYY')
- anything else -> NULL

### 3. Currency normalization (4 amount columns)
- Extract numeric part: `regexp_replace(col, '[^0-9.]', '', 'g')`
- If value contains `$`: multiply by 0.92 (USD -> EUR)
- If value contains `€`, `EUR`, `euros`, or is plain number: keep as is
- Result stored in `*_eur` columns

### 4. Gender normalization
- `M`, `Male`   -> `M`
- `F`, `Female` -> `F`
- other / empty -> NULL

### 5. city_postal split
- `Paris_75001` -> city = `Paris`, postal_code = `75001`
- Uses `split_part(city_postal, '_', 1)` and `split_part(city_postal, '_', 2)`

### 6. Decimal-string to integer
- `year` (vehicles): `'2018.0'` -> `2018`
- `previous_claims`: `'1.0'` -> `1`
- `power`: `'90.0'` -> `90`

## Anomalies preserved (not corrected)
- **47 claims** have `declaration_date < occurrence_date` (declaration before the event).
  This is a business signal, not a data error.
  Kept as-is. To be investigated in Phase 20 (Fraud Analytics).

## Results after cleaning
(TO BE COMPLETED with the V1-V8 outputs)

## Files
- `sql/02_staging/01_quality_diagnostics.sql` : diagnostics
- `sql/02_staging/02_create_staging_tables.sql` : table definitions
- `sql/02_staging/03_populate_staging.sql` : cleaning + population
