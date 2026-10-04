# Phase 29 — Data Quality Testing

## Purpose
Formalize reproducible data quality tests on the `core` schema,
covering completeness, uniqueness, validity, referential integrity,
and freshness.

## Test categories

| Category | Tests | Focus |
|----------|-------|-------|
| Completeness | T1, T2 | PKs not null, FKs not null |
| Uniqueness | T3, T4 | PK uniqueness, reference uniqueness |
| Validity | T5–T12 | Domain constraints (gender, age, amounts, dates) |
| Referential integrity | T13–T16 | No orphan rows in FK relations |
| Freshness | T17, T18 | No dates in the far future |

## Test catalog

| Test | Description | Threshold |
|------|-------------|-----------|
| T1 | Primary keys not null | 0 |
| T2 | Foreign keys not null | 0 |
| T3 | Primary keys unique | 0 |
| T4 | Reference values unique | 0 |
| T5 | Gender ∈ {M, F, NULL} | 0 |
| T6 | Age ∈ [0, 120] | 0 |
| T7 | Premium ≥ 0 | 0 |
| T8 | Damage ≥ 0 | 0 |
| T9 | Indemnified ≥ 0 | 0 |
| T10 | end_date ≥ start_date | 0 |
| T11 | Year ∈ [1900, 2100] | 0 |
| T12 | Power > 0 | 0 |
| T13 | Contracts → clients | 0 |
| T14 | Claims → contracts | 0 |
| T15 | Vehicles → contracts | 0 |
| T16 | Contracts → products | 0 |
| T17 | Contract dates not in far future | 0 |
| T18 | Claim dates not in far future | 0 |

## How to run
psql -d insurance_analytics
\pset pager off
\i sql/07_tests/01_data_quality_tests.sql



Each test returns a row with:
- `test_name`
- `status` (PASS / FAIL)
- `observed` count
- `threshold` (0)

## Interpretation
- **PASS**: the observed count equals 0 (no violations).
- **FAIL**: at least 1 violation. Investigate the corresponding query.

## Industrialization
- Tests are pure SQL, versioned.
- Can be run at any time (idempotent, read-only).
- Can be scheduled via cron or CI later.

## Files
- `sql/07_tests/01_data_quality_tests.sql`
- `docs/29_data_quality_testing.md`
