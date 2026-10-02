# Phase 8 — Normalization and Modeling

## 1. Purpose

Formally verify that the relational model designed in Phase 7 satisfies
the first three normal forms (1NF, 2NF, 3NF). Document denormalization
decisions and the modeling approach (OLTP vs analytical).

## 2. Normalization levels

### 2.1 First Normal Form (1NF) — Atomic values

**Rule**: every column contains atomic (indivisible) values. No lists,
no arrays, no repeating groups.

**Verification on our model**:

| Table | Columns checked | Status |
|---|---|---|
| clients | all text and numeric scalars | OK |
| contracts | all text, date, numeric scalars | OK |
| claims | all text, date, numeric scalars | OK |
| vehicles | all text, integer, numeric scalars | OK |
| ref_* | all scalar (id, name) | OK |

**Counter-example avoided**:

In the raw data, the column `city_postal` contained values like
`Paris_75001`. That is a **composite value** (city + postal code in one
column), violating 1NF. We fixed it by splitting into two columns
`city` and `postal_code` in the `staging` schema, then extracting them
into the `ref_cities` reference table in the `core` schema.

**Result**: 1NF is satisfied.

### 2.2 Second Normal Form (2NF) — No partial dependencies

**Rule**: the table is in 1NF AND every non-key column depends on the
**entire** primary key (not just part of it). This rule applies only
when the primary key is composite.

**Verification on our model**:

| Table | Primary key | Type | Partial dependency risk |
|---|---|---|---|
| clients | client_id | simple | none |
| contracts | contract_id | simple | none |
| claims | claim_id | simple | none |
| vehicles | contract_id | simple | none |
| ref_* | id | simple | none |

**All primary keys are simple** (single column). Therefore, partial
dependencies are **impossible by construction**.

**Result**: 2NF is satisfied.

### 2.3 Third Normal Form (3NF) — No transitive dependencies

**Rule**: the table is in 2NF AND no non-key column depends on another
non-key column (no transitive dependency).

**Verification on our model**:

#### Issue 1 — `csp` moved from `contracts` to `clients`

In the staging schema, `contracts` had a column `csp` (socio-professional
category). This is a **transitive dependency**:

- `csp` depends on `client_id`, not on `contract_id`.
- `contract_id` -> `client_id` -> `csp`

We fixed it by moving `csp_id` into the `clients` table.

#### Issue 2 — `risk_zone` extracted from `city_postal`

In the staging schema, `contracts` had `city`, `postal_code`, and
`risk_zone` as three separate columns. This creates a transitive
dependency:

- `risk_zone` depends on `city` (or postal code), not directly on the contract.

We fixed it by creating:
- `ref_cities (city_id, city_name, postal_code, risk_zone_id)`
- `ref_risk_zones (risk_zone_id, risk_zone_name)`

Now `contracts` references `city_id`, and `ref_cities` references
`risk_zone_id`.

#### Issue 3 — Reference values extracted

In the staging schema, columns like `product`, `channel`, `status`,
`claim_type`, etc. stored raw text values repeated on every row. This
creates redundancy. We fixed it by creating `ref_*` tables.

**Result**: 3NF is satisfied.

## 3. Denormalization decisions

### 3.1 No denormalization in `core` schema

The `core` schema remains fully normalized (3NF). This is appropriate
for an OLTP-style storage.

### 3.2 Potential denormalization in `analytics` schema

For analytical queries (KPI, dashboards), we may later create:

- Materialized views that join `contracts + clients + claims` for
  faster loss-ratio computation.
- Pre-aggregated tables (monthly claims, premium by segment).

These belong to the `analytics` schema, not to `core`. They will be
created in Phases 23-24 (Views, Materialized Views).

**Principle**: normalized storage in `core`, denormalized views in
`analytics`.

## 4. Modeling approach: OLTP vs Analytical

### 4.1 Definition

| Criterion | OLTP | Analytical (Star / Snowflake) |
|---|---|---|
| Purpose | Daily transactions | Reporting, analytics |
| Normalization | 3NF | Denormalized dimensions |
| Optimization | Write speed, integrity | Read speed, aggregations |
| Example | Insurance policy system | BI warehouse |

### 4.2 Chosen approach

**Chosen**: **Normalized OLTP model in `core`, with analytical views in `analytics`.**

**Rationale**:
- The dataset represents **operational data** (contracts, claims).
- Integrity is critical (FK, CHECK, UNIQUE).
- Query performance for analytics can be handled later with indexes
  and materialized views.
- A star schema would require duplicate dimensions and complicate
  referential integrity for a modest dataset size (15k contracts).

### 4.3 Implications

- `core` schema: 3NF, with FK and CHECK constraints.
- `analytics` schema: views and materialized views for KPI.
- No physical star schema.

## 5. Final model recap

### 5.1 Tables (17 total)

**Core (4)**:
- `clients`
- `contracts`
- `claims`
- `vehicles`

**Reference (13)**:
- `ref_products`
- `ref_channels`
- `ref_csp`
- `ref_risk_zones`
- `ref_cities`
- `ref_contract_statuses`
- `ref_claim_types`
- `ref_claim_statuses`
- `ref_liabilities`
- `ref_fuel_types`
- `ref_vehicle_brands`
- `ref_vehicle_usages`
- `ref_vehicle_colors`

### 5.2 Normal form achieved

- 1NF: yes
- 2NF: yes
- 3NF: yes
- BCNF: yes (all determinants are candidate keys)

