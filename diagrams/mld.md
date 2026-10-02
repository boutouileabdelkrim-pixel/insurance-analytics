# Logical Data Model (MLD)

Relational schema after applying 1NF, 2NF, 3NF.

## Core tables

```
clients (
    client_id       TEXT          PK
    client_name     TEXT
    client_age      NUMERIC(5,1)
    gender          CHAR(1)
    csp_id          INTEGER       FK -> ref_csp.csp_id
)

contracts (
    contract_id         TEXT       PK
    client_id           TEXT       FK -> clients.client_id
    product_id          INTEGER    FK -> ref_products.product_id
    channel_id          INTEGER    FK -> ref_channels.channel_id
    city_id             INTEGER    FK -> ref_cities.city_id
    start_date          DATE
    end_date            DATE
    annual_premium_eur  NUMERIC(12,2)
    status_id           INTEGER    FK -> ref_contract_statuses.status_id
)

claims (
    claim_id                TEXT       PK
    contract_id             TEXT       FK -> contracts.contract_id
    occurrence_date         DATE
    declaration_date        DATE
    claim_type_id           INTEGER    FK -> ref_claim_types.claim_type_id
    damage_amount_eur       NUMERIC(12,2)
    indemnified_amount_eur  NUMERIC(12,2)
    status_id               INTEGER    FK -> ref_claim_statuses.status_id
    expert_id               TEXT
    liability_id            INTEGER    FK -> ref_liabilities.liability_id
)

vehicles (
    contract_id         TEXT       PK, FK -> contracts.contract_id
    brand_id            INTEGER    FK -> ref_vehicle_brands.brand_id
    model               TEXT
    year                INTEGER
    power               INTEGER
    fuel_type_id        INTEGER    FK -> ref_fuel_types.fuel_type_id
    current_value_eur   NUMERIC(12,2)
    color_id            INTEGER    FK -> ref_vehicle_colors.color_id
    usage_id            INTEGER    FK -> ref_vehicle_usages.usage_id
    previous_claims     INTEGER
)
```

## Reference tables

```
ref_products            (product_id PK, product_name UNIQUE)
ref_channels            (channel_id PK, channel_name UNIQUE)
ref_csp                 (csp_id PK, csp_name UNIQUE)
ref_risk_zones          (risk_zone_id PK, risk_zone_name UNIQUE)
ref_cities              (city_id PK, city_name, postal_code, risk_zone_id FK)
ref_contract_statuses   (status_id PK, status_name UNIQUE)
ref_claim_types         (claim_type_id PK, claim_type_name UNIQUE)
ref_claim_statuses      (status_id PK, status_name UNIQUE)
ref_liabilities         (liability_id PK, liability_name UNIQUE)
ref_fuel_types          (fuel_type_id PK, fuel_type_name UNIQUE)
ref_vehicle_brands      (brand_id PK, brand_name UNIQUE)
ref_vehicle_usages      (usage_id PK, usage_name UNIQUE)
ref_vehicle_colors      (color_id PK, color_name UNIQUE)
```

## Normalization check

### 1NF — Atomic values
All columns contain atomic values (no lists, no arrays).

### 2NF — No partial dependencies
All tables have simple primary keys. No composite keys with partial dependencies.

### 3NF — No transitive dependencies
- Reference data extracted into `ref_*` tables.
- `csp` moved from contracts to clients (belongs to person, not contract).
- `risk_zone` extracted from city into its own reference table.

## Table count
- 4 core tables
- 13 reference tables
- Total: 17 tables
