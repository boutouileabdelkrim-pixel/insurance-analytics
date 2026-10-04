# Data Dictionary

Complete reference of all tables and columns in the `core` schema.

## Core tables (4)

### clients

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| client_id | TEXT | PK | Client unique identifier |
| client_name | TEXT | NOT NULL | Client full name |
| client_age | NUMERIC(5,1) | CHECK 0-120 | Age (nullable) |
| gender | CHAR(1) | CHECK 'M'/'F'/NULL | Gender |
| csp_id | INTEGER | FK → ref_csp | Socio-professional category |

### contracts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| contract_id | TEXT | PK | Contract unique identifier |
| client_id | TEXT | FK → clients | Contract holder |
| product_id | INTEGER | FK → ref_products | Insurance product |
| channel_id | INTEGER | FK → ref_channels | Distribution channel |
| city_id | INTEGER | FK → ref_cities | Contract location |
| start_date | DATE | | Subscription date |
| end_date | DATE | | End date |
| annual_premium_eur | NUMERIC(12,2) | CHECK ≥ 0 | Annual premium in EUR |
| status_id | INTEGER | FK → ref_contract_statuses | Current status |

### claims

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| claim_id | TEXT | PK | Claim unique identifier |
| contract_id | TEXT | FK → contracts | Related contract |
| occurrence_date | DATE | | Date of incident |
| declaration_date | DATE | | Date of declaration |
| claim_type_id | INTEGER | FK → ref_claim_types | Claim type |
| damage_amount_eur | NUMERIC(12,2) | CHECK ≥ 0 | Estimated damage in EUR |
| indemnified_amount_eur | NUMERIC(12,2) | CHECK ≥ 0 | Amount indemnified in EUR |
| status_id | INTEGER | FK → ref_claim_statuses | Current status |
| expert_id | TEXT | | Expert identifier |
| liability_id | INTEGER | FK → ref_liabilities | Liability type |

### vehicles

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| contract_id | TEXT | PK, FK → contracts | 1-1 with contract |
| brand_id | INTEGER | FK → ref_vehicle_brands | Vehicle brand |
| model | TEXT | | Model name |
| year | INTEGER | CHECK 1900-2100 | Manufacturing year |
| power | INTEGER | CHECK > 0 | Power in HP |
| fuel_type_id | INTEGER | FK → ref_fuel_types | Fuel type |
| current_value_eur | NUMERIC(12,2) | CHECK ≥ 0 | Current value in EUR |
| color_id | INTEGER | FK → ref_vehicle_colors | Color |
| usage_id | INTEGER | FK → ref_vehicle_usages | Usage type |
| previous_claims | INTEGER | CHECK ≥ 0 | Previous claim count |

## Reference tables (13)

### ref_products
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| product_id | SERIAL | PK | |
| product_name | TEXT | NOT NULL UNIQUE | Product name |

Values: Auto, Home, Life, Health.

### ref_channels
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| channel_id | SERIAL | PK | |
| channel_name | TEXT | NOT NULL UNIQUE | Channel name |

Values: Broker, Agency, Web, Phone.

### ref_csp
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| csp_id | SERIAL | PK | |
| csp_name | TEXT | NOT NULL UNIQUE | CSP name |

### ref_risk_zones
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| risk_zone_id | SERIAL | PK | |
| risk_zone_name | TEXT | NOT NULL UNIQUE | Zone name |

Values: Low, Medium, High.

### ref_cities
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| city_id | SERIAL | PK | |
| city_name | TEXT | NOT NULL | City name |
| postal_code | TEXT | NOT NULL | Postal code |
| risk_zone_id | INTEGER | FK → ref_risk_zones | Risk level |

Unique: (city_name, postal_code).

### ref_contract_statuses
| Column | Type | Constraints |
|--------|------|-------------|
| status_id | SERIAL | PK |
| status_name | TEXT | NOT NULL UNIQUE |

Values: Active, Renewed, Expired, Cancelled, Suspended.

### ref_claim_types
| Column | Type | Constraints |
|--------|------|-------------|
| claim_type_id | SERIAL | PK |
| claim_type_name | TEXT | NOT NULL UNIQUE |

Values: Collision, Theft, Fire, Glass_damage, Vandalism, Storm, Water_damage.

### ref_claim_statuses
| Column | Type | Constraints |
|--------|------|-------------|
| status_id | SERIAL | PK |
| status_name | TEXT | NOT NULL UNIQUE |

Values: Open, In_progress, Expert_review, Closed, Rejected.

### ref_liabilities
| Column | Type | Constraints |
|--------|------|-------------|
| liability_id | SERIAL | PK |
| liability_name | TEXT | NOT NULL UNIQUE |

Values: Insured, Third_party, Shared, Force_majeure.

### ref_fuel_types
| Column | Type | Constraints |
|--------|------|-------------|
| fuel_type_id | SERIAL | PK |
| fuel_type_name | TEXT | NOT NULL UNIQUE |

Values: Gasoline, Diesel, Hybrid, Electric.

### ref_vehicle_brands
| Column | Type | Constraints |
|--------|------|-------------|
| brand_id | SERIAL | PK |
| brand_name | TEXT | NOT NULL UNIQUE |

### ref_vehicle_usages
| Column | Type | Constraints |
|--------|------|-------------|
| usage_id | SERIAL | PK |
| usage_name | TEXT | NOT NULL UNIQUE |

Values: Personal, Professional, Mixed.

### ref_vehicle_colors
| Column | Type | Constraints |
|--------|------|-------------|
| color_id | SERIAL | PK |
| color_name | TEXT | NOT NULL UNIQUE |

## Schemas

| Schema | Purpose |
|--------|---------|
| raw | Raw imported CSV (all TEXT) |
| staging | Cleaned and typed data |
| core | Normalized relational model (17 tables) |
| analytics | Views, materialized views |
| audit | Audit trail (triggers) |
