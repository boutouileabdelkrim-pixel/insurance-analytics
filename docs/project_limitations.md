# Project Limitations and Future Work

## Dataset limitations

- **Volume**: ~20,500 rows total — sufficient for demonstration but not
  production-scale (real insurance companies handle millions of claims).
- **Synthetic/derived**: the dataset is designed for practice, not real
  operational data.
- **Simplified product catalog**: only 4 products (Auto, Home, Life, Health).
- **No time-series evolution**: contracts and claims are mostly static.
- **No financial transactions**: no payment schedules, no premium
  installments, no re-insurance.

## Design decisions

- **Vehicles is 1-1 with contracts**: real portfolios may have
  multi-vehicle contracts (fleet insurance).
- **No avenant (amendment) table**: contract changes are not tracked.
- **No broker/agent entity**: only a distribution channel is recorded.
- **Age kept as client_age**: a birth_year would be more robust.
- **No SCD (Slowly Changing Dimensions)**: the model is a snapshot.

## Analytical limitations

- **No true cohort tracking**: cohort analysis uses subscription year,
  not activity over time.
- **LTV is simplified**: no discounting, no survival curves.
- **Fraud score is rule-based**: no statistical model, no ML.
- **No seasonality decomposition**: trends are computed but not adjusted.
- **No confidence intervals**: statistical uncertainty is not modeled.





## Future work

If this project were to be extended:

1. **Add partitioning** on `claims` by `occurrence_date`.
2. **Add EXPLAIN ANALYZE** benchmarks for top 10 queries.
3. **Add a CI pipeline** running `sql/07_tests/` on every push.
4. **Add a star schema** in `analytics` for BI.
5. **Add incremental data loading** (SCD Type 2).
6. **Add statistical models** for fraud detection.
7. **Add a REST API** for programmatic access.
8. **Add dashboards** for business users.

## Lessons learned

- Well-designed normalization pays off for analytical queries.
- Data quality cleaning is 60% of the work.
- Documented SQL scripts are more valuable than one-off queries.
- Git history shows the progressive construction of the project.
