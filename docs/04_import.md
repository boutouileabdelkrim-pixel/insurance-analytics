# Phase 4 — Data Import

## Dataset
- Name: Insurance Dataset for Data Engineering Practice
- Source: Kaggle
- Author: kpoviesistphane
- License: (TO BE COMPLETED from Kaggle page)

## Source files
| File          | CSV lines | Data lines | Size   | Description |
|---------------|-----------|------------|--------|-------------|
| contracts.csv | 15001     | 15000      | 1.8 MB | Contracts   |
| claims.csv    | 156       | 155        | 15 kB  | Claims      |
| vehicles.csv  | 5391      | 5390       | 390 kB | Vehicles    |

## Local location
~/insurance-analytics/data/raw/

## Created tables (raw schema)
- raw.contracts : 14 columns (TEXT)
- raw.claims    : 10 columns (TEXT)
- raw.vehicles  : 10 columns (TEXT)

## Columns
### raw.contracts (14)
contract_id, client_id, client_name, product, start_date, end_date,
annual_premium, status, city_postal, risk_zone, client_age, channel,
csp, gender

### raw.claims (10)
claim_id, contract_id, occurrence_date, declaration_date, claim_type,
damage_amount, indemnified_amount, status, expert_id, liability

### raw.vehicles (10)
contract_id, brand, model, year, power, fuel_type, current_value,
color, usage, previous_claims

## Import procedure
1. Copy CSV files to /tmp/raw_import/ (accessible by postgres user)
2. chown postgres:postgres + chmod 644
3. Import via COPY:
   COPY raw.<table> FROM '/tmp/raw_import/<table>.csv'
   WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

## Post-import verification
- contracts : 15000 rows
- claims    : 155 rows
- vehicles  : 5390 rows

## Data quality issues observed (to handle in Phase 6)
- Mixed date formats: '2023-08-11', '11/08/2023', '11-08-2023'
- Text amounts with € symbol: '1974.98€', '€620.93'
- Missing values (csp, expert_id, gender)
- Heterogeneous categories (gender: 'F', 'M', 'Female', 'Male')
