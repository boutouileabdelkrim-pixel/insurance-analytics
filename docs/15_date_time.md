# Phase 15 — Date / Time SQL

## Purpose

Master PostgreSQL temporal types, extraction, duration calculations,
series generation, time aggregations, period comparisons, and timezone
handling applied to insurance data.

## Covered concepts

| Section | Concept |
|---|---|
| 1 | Types: date, time, timestamp, timestamptz, interval |
| 2 | EXTRACT (year, month, quarter, week, day, dow) |
| 3 | Durations (end - start, age()) |
| 4 | generate_series for time series |
| 5 | Time aggregations (month, year) |
| 6 | Period comparisons (MoM, YoY) |
| 7 | Timezone handling |
| 8 | Business applications |

## Query catalog

The file `sql/04_analytics/06_date_time.sql` contains 20 queries:

| # | Query | Concept |
|---|---|---|
| 1 | Type introspection | information_schema |
| 2 | Literal types | casting |
| 3 | Interval arithmetic | INTERVAL |
| 4 | Extract components | EXTRACT |
| 5 | Contracts per year/quarter | EXTRACT + GROUP BY |
| 6 | Contracts per day of week | EXTRACT(DOW) |
| 7 | Contract duration | end - start |
| 8 | Claim processing delay | date subtraction |
| 9 | Avg delay per claim type | AVG on interval |
| 10 | Generate 12 months | generate_series |
| 11 | Monthly counts with zero-fill | LEFT JOIN + series |
| 12 | Monthly premium | date_trunc |
| 13 | Yearly claims | EXTRACT(YEAR) |
| 14 | MoM premium growth | LAG |
| 15 | YoY contract comparison | self-join |
| 16 | Multi-timezone now() | AT TIME ZONE |
| 17 | Session timezone | SHOW |
| 18 | Active contracts on date | range filter |
| 19 | Cohort by year | GROUP BY year |
| 20 | Delay buckets | CASE on interval |

## Key learnings

- **date vs timestamp vs timestamptz**: use `date` for calendar days,
  `timestamptz` for events with timezone context.
- **date_trunc('month', d)**: bucket any date to month-start.
- **EXTRACT(DOW)**: 0 = Sunday, 6 = Saturday.
- **generate_series**: essential for zero-filled time series.
- **LAG/LEAD on months**: comparisons across periods.
- **`end - start` on dates** returns integer (days).
- **`age(a, b)`** returns a human-readable interval.

## Business insight

- **Q8**: claim declaration delay — regulatory compliance signal.
- **Q9**: delay per claim type — process bottleneck identification.
- **Q14**: MoM premium growth — portfolio expansion tracking.
- **Q18**: active contracts on a date — portfolio snapshot.
- **Q19**: cohort analysis foundation for retention.

## Files

- `sql/04_analytics/06_date_time.sql`
- `docs/15_date_time.md`
