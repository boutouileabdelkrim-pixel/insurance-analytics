# Insurance Analytics — SQL / PostgreSQL Portfolio Project

A professional SQL/PostgreSQL project simulating the analytical
workflow of an insurance company: from raw data ingestion to
advanced analytics, business KPIs, and fraud detection.

## Project goals

Demonstrate advanced mastery of:
- Relational database design (3NF normalization)
- Data quality and cleaning
- Analytical SQL (JOINs, CTEs, subqueries, window functions)
- Insurance-specific KPIs (loss ratio, churn, retention)
- Fraud detection with SQL-based rules
- PostgreSQL features (views, materialized views, functions, triggers)
- Performance optimization (indexes)
- Professional documentation

## Tech stack

- **PostgreSQL 18**
- **psql** and **pgAdmin 4**
- **Git / GitHub**
- **Markdown** and **Mermaid** for documentation

## Dataset

- Source: Kaggle — *Insurance Dataset for Data Engineering Practice*
- Size: 3 tables (contracts, claims, vehicles)
- Volume: ~20,500 rows total
- Coverage: Auto, Home, Life, Health insurance

## Repository structure
insurance-analytics/
├── data/ # Raw CSV (not versioned)
├── diagrams/ # MCD and MLD (Mermaid)
├── docs/ # Full project documentation
│ └── case_studies/ # 4 case studies
├── scripts/ # Utility scripts
└── sql/ # All SQL scripts
  ├── 00_setup/ # Database and schemas
  ├── 01_import/ # Raw tables and CSV loading
  ├── 02_staging/ # Data quality and cleaning
  ├── 03_core/ # Target relational model
  ├── 04_analytics/ # Business analyses
  ├── 05_advanced/ # Views, functions, triggers, transactions
  ├── 06_performance/ # Indexes
  ├── 07_tests/ # Data quality tests
  └── 08_case_studies/ # End-to-end case studies


## Data pipeline

1. **Import** — Raw CSV loaded as-is into `raw` schema (all `TEXT`).
2. **Staging** — Cleaned and typed into `staging` schema (dates parsed, currencies normalized, categories standardized).
3. **Core** — Fully normalized into `core` schema (17 tables: 4 core + 13 reference).
4. **Analytics** — Views, materialized views, and analyses in `analytics` schema.

## Key KPIs

- Loss ratio, combined ratio
- Claim frequency and severity
- Retention and churn rates
- Customer lifetime value (LTV)
- Fraud suspicion score

See [docs/kpi_reference.md](docs/kpi_reference.md) for definitions.

## Case studies

1. **Product Profitability** — Loss ratio per product and segment.
2. **Churn Analysis** — Churn drivers by product, channel, age, CSP.
3. **Fraud Detection** — Weighted suspicion score and prioritization.
4. **Client Segmentation** — RFM adapted to insurance.

See [docs/case_studies_summary.md](docs/case_studies_summary.md).

## Documentation

All project documentation is in the [`docs/`](docs/) folder.

## How to reproduce
1. Clone the repository

git clone https://github.com/boutouileabdelkrim-pixel/insurance-analytics.git
cd insurance-analytics
2. Create the database

psql -U postgres -f sql/00_setup/01_create_database.sql
3. Download the dataset from Kaggle into data/raw/
(see docs/04_import.md for the exact source)
4. Import and process

psql -d insurance_analytics -f sql/01_import/01_create_raw_tables.sql
psql -d insurance_analytics -f sql/01_import/02_load_raw_data.sql
psql -d insurance_analytics -f sql/02_staging/00_date_helpers.sql
psql -d insurance_analytics -f sql/02_staging/02_create_staging_tables.sql
psql -d insurance_analytics -f sql/02_staging/03_populate_staging.sql
psql -d insurance_analytics -f sql/03_core/01_create_reference_tables.sql
psql -d insurance_analytics -f sql/03_core/02_create_core_tables.sql
psql -d insurance_analytics -f sql/03_core/03_populate_reference_tables.sql
psql -d insurance_analytics -f sql/03_core/04_populate_core_tables.sql
psql -d insurance_analytics -f sql/03_core/05_verify_integrity.sql
5. Run analyses

psql -d insurance_analytics -f sql/04_analytics/01_sql_fundamentals.sql
psql -d insurance_analytics -f sql/04_analytics/02_joins.sql
... etc.





## Author

**Abdelkrim Boutouile** — Data Scientist / ML Engineer
- GitHub: [@boutouileabdelkrim-pixel](https://github.com/boutouileabdelkrim-pixel)


