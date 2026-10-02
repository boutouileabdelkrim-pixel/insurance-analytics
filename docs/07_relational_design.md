# Phase 7 — Relational Database Design

## 1. Purpose

Design the target relational model (`core` schema) that will replace the
denormalized `staging` tables.

Principles:
- Normalize to 3NF (no redundant data).
- Separate facts (transactions) from dimensions (references).
- Use surrogate keys where useful.
- Preserve referential integrity through foreign keys.

## 2. Entities

### 2.1 Core entities (facts / master data)

| Entity    | Description                                    |
|-----------|------------------------------------------------|
| clients   | Individuals who buy insurance products         |
| contracts | Insurance policies signed between a client and the company |
| claims    | Declared incidents linked to contracts         |
| vehicles  | Vehicles covered by an Auto contract (1-1)     |

### 2.2 Reference entities (dimensions)

| Entity                 | Values observed                       |
|------------------------|---------------------------------------|
| ref_products           | Auto, Home, Life, Health              |
| ref_channels           | Broker, Agency, Web, Phone            |
| ref_csp                | Employee, Self_employed, Manager, Worker, Retired, Student, Unemployed |
| ref_cities             | (city, postal_code, risk_zone)        |
| ref_risk_zones         | Low, Medium, High                     |
| ref_contract_statuses  | Active, Renewed, Expired, Cancelled, Suspended |
| ref_claim_types        | Collision, Theft, Fire, Glass_damage, Vandalism, Storm, Water_damage |
| ref_claim_statuses     | Open, In_progress, Expert_review, Closed, Rejected |
| ref_liabilities        | Insured, Third_party, Shared, Force_majeure |
| ref_fuel_types         | Gasoline, Diesel, Hybrid, Electric    |
| ref_vehicle_brands     | Volkswagen, Peugeot, Renault, BMW, Mercedes |
| ref_vehicle_usages     | Personal, Professional, Mixed         |
| ref_vehicle_colors     | (various)                             |

## 3. Attributes per entity

### 3.1 clients
- client_id (PK)
- client_name (TEXT)
- client_age (NUMERIC(5,1))
- gender (CHAR(1)) — 'M' or 'F', NULL allowed
- csp_id (FK -> ref_csp)

### 3.2 contracts
- contract_id (PK)
- client_id (FK -> clients)
- product_id (FK -> ref_products)
- channel_id (FK -> ref_channels)
- city_id (FK -> ref_cities)
- start_date (DATE)
- end_date (DATE)
- annual_premium_eur (NUMERIC)
- status_id (FK -> ref_contract_statuses)

### 3.3 claims
- claim_id (PK)
- contract_id (FK -> contracts)
- occurrence_date (DATE)
- declaration_date (DATE)
- claim_type_id (FK -> ref_claim_types)
- damage_amount_eur (NUMERIC)
- indemnified_amount_eur (NUMERIC)
- status_id (FK -> ref_claim_statuses)
- expert_id (TEXT)
- liability_id (FK -> ref_liabilities)

### 3.4 vehicles
- contract_id (PK, FK -> contracts) — 1-1 with contracts
- brand_id (FK -> ref_vehicle_brands)
- model (TEXT)
- year (INTEGER)
- power (INTEGER)
- fuel_type_id (FK -> ref_fuel_types)
- current_value_eur (NUMERIC)
- color_id (FK -> ref_vehicle_colors)
- usage_id (FK -> ref_vehicle_usages)
- previous_claims (INTEGER)

### 3.5 Reference entities
Each `ref_*` table has:
- id (PK, surrogate key)
- name or code (UNIQUE)
- optional description

## 4. Relations and cardinalities

| Source    | Cardinality | Target    | FK                  |
|-----------|-------------|-----------|---------------------|
| clients   | 1 --- N     | contracts | contracts.client_id |
| contracts | 1 --- N     | claims    | claims.contract_id  |
| contracts | 1 --- 1     | vehicles  | vehicles.contract_id |
| contracts | N --- 1     | ref_products | contracts.product_id |
| contracts | N --- 1     | ref_channels | contracts.channel_id |
| contracts | N --- 1     | ref_cities   | contracts.city_id   |
| contracts | N --- 1     | ref_contract_statuses | contracts.status_id |
| clients   | N --- 1     | ref_csp      | clients.csp_id      |
| claims    | N --- 1     | ref_claim_types | claims.claim_type_id |
| claims    | N --- 1     | ref_claim_statuses | claims.status_id |
| claims    | N --- 1     | ref_liabilities | claims.liability_id |
| vehicles  | N --- 1     | ref_vehicle_brands | vehicles.brand_id |
| vehicles  | N --- 1     | ref_fuel_types | vehicles.fuel_type_id |
| vehicles  | N --- 1     | ref_vehicle_usages | vehicles.usage_id |
| vehicles  | N --- 1     | ref_vehicle_colors | vehicles.color_id |
| ref_cities| N --- 1     | ref_risk_zones | ref_cities.risk_zone_id |

## 5. Key design decisions

### Decision 1 — Separate `clients` from `contracts`
Even though the current data shows 1 client = 1 contract, we design 1-N
for realism: a client can subscribe to multiple contracts over time.

### Decision 2 — `vehicles` is 1-1 with `contracts`
Each Auto contract has exactly one vehicle (based on data).
For multi-vehicle contracts (rare), this model would need evolution.

### Decision 3 — `cities` separate with `risk_zone`
City + postal_code + risk_zone are grouped in a reference table
to avoid duplication and enable geographic analysis.

### Decision 4 — Surrogate keys for reference tables
Reference tables use an integer `id` as PK.
The natural key (e.g. product name) is kept as a UNIQUE column.

### Decision 5 — `csp` at `clients` level
Socio-professional category describes the person, not the contract.

### Decision 6 — `age` not stored as birth_year
The dataset only provides `client_age`. Keep it as-is.

## 6. Business questions validated against the model

| # | Business question | Tables involved |
|---|---|---|
| 1 | Loss ratio per product | contracts + claims + ref_products |
| 2 | Monthly claim frequency | contracts + claims |
| 3 | Average premium per segment | contracts + clients + ref_csp |
| 4 | Churn analysis | contracts + ref_contract_statuses |
| 5 | Fraud signals | claims + vehicles |
| 6 | Claims by geography | contracts + ref_cities |
| 7 | Retention by cohort | contracts + clients |
| 8 | Claims by claim type | claims + ref_claim_types |

All business questions from Phase 1 are answerable with this model.

## 7. Next steps (Phase 8)

- Apply 1NF, 2NF, 3NF formally.
- Produce the Logical Model (MLD).
- Generate the CREATE TABLE scripts (Phase 9).

## 8. Logical Data Model (MLD)

The MLD is available at `diagrams/mld.md`.

### Normalization achieved
- 1NF: atomic columns
- 2NF: no partial dependencies
- 3NF: no transitive dependencies

### Total: 17 tables
- 4 core tables: clients, contracts, claims, vehicles
- 13 reference tables: ref_* (products, channels, csp, cities, statuses, types, etc.)
