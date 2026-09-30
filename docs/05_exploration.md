# Phase 5 — Raw Data Exploration

## Volumetry
| Table     | Rows  | Columns |
|-----------|-------|---------|
| contracts | 15000 | 14      |
| claims    | 155   | 10      |
| vehicles  | 5390  | 10      |

Total size: 3064 kB

## Candidate keys
- raw.contracts.contract_id  : primary key candidate (unique, 0 dups)
- raw.contracts.client_id    : unique too (0 dups) → 1 client = 1 contract
- raw.claims.claim_id        : primary key candidate (unique)
- raw.vehicles.contract_id   : foreign key to raw.contracts (unique)

## Granularity
- raw.contracts : 1 row = 1 contract
- raw.claims    : 1 row = 1 claim
- raw.vehicles  : 1 row = 1 vehicle

## Categories observed

### contracts.product
- Auto    : 6346
- Home    : 4406
- Life    : 2563
- Health  : 1685

### contracts.status
- Renewed   : 3192
- Cancelled : 3164
- Expired   : 3129
- Active    : 2797
- Suspended : 2718

### contracts.gender
- (empty) : 3096
- Male    : 3029
- Female  : 2993
- M       : 2949
- F       : 2933

### contracts.csp
- Employee      : 3281
- Self_employed : 3059
- Manager       : 3012
- Worker        : 2968
- (empty)       : 1772
- Retired       :  495
- Student       :  235
- Unemployed    :  178

### contracts.channel
- Broker : 3839
- Agency : 3786
- Web    : 3736
- Phone  : 3639

### contracts.risk_zone
- Medium : 6429
- Low    : 4323
- High   : 4248

### claims.claim_type
- Glass_damage : 37
- Vandalism    : 31
- Fire         : 30
- Collision    : 28
- Theft        : 24
- Storm        :  4
- Water_damage :  1

### claims.status
- Closed        : 47
- Rejected      : 43
- Expert_review : 25
- In_progress   : 23
- Open          : 17

### claims.liability
- (empty)       : 47
- Insured       : 41
- Third_party   : 33
- Shared        : 29
- Force_majeure :  5

### vehicles.fuel_type
- Gasoline : 1395
- Diesel   : 1336
- Hybrid   : 1334
- Electric : 1325

### vehicles.brand
- Volkswagen : 1598
- Peugeot    : 1594
- Renault    : 1592
- BMW        :  327
- Mercedes   :  279

### vehicles.usage
- Mixed        : 1833
- Professional : 1785
- Personal     : 1772

## Numeric distributions
- client_age : min 18, max 75, avg 44.4
- power      : min 90, max 200, avg 144.3
- year       : NO NUMERIC VALUE MATCHED regex (see Phase 6 diagnostics)
- previous_claims : NO NUMERIC VALUE MATCHED regex (see Phase 6 diagnostics)

## Date formats detected
### contracts.start_date
- YYYY-MM-DD : 12780
- DD/MM/YYYY :  1483
- DD-MM-YYYY :   737

### contracts.end_date
- YYYY-MM-DD : 12713
- DD/MM/YYYY :  1546
- DD-MM-YYYY :   741

### claims.occurrence_date
- YYYY-MM-DD : 144
- DD/MM/YYYY :  12
- DD-MM-YYYY :   9

### claims.declaration_date
- YYYY-MM-DD : 140
- DD/MM/YYYY :  13
- DD-MM-YYYY :   2

## Currency formats detected
### contracts.annual_premium
- suffix_euro : 11079
- autre       :  1547  ← TO INVESTIGATE
- dollar      :   818
- prefix_euro :   785
- eur_code    :   771

### claims.damage_amount
- suffix_euro : 123
- autre       :  13
- eur_code    :   7
- prefix_euro :   7
- dollar      :   5

### claims.indemnified_amount
- suffix_euro : 67
- null        : 65
- autre       :  9
- eur_code    :  6
- prefix_euro :  4
- dollar      :  4

### vehicles.current_value
- suffix_euro : 4007
- autre       :  574
- eur_code    :  286
- dollar      :  263
- prefix_euro :  260

## Referential integrity
- claims.contract_id → contracts.contract_id : 0 orphans
- vehicles.contract_id → contracts.contract_id : 0 orphans
- contracts with at least one claim : 155
- contracts with at least one vehicle : 5390
- Claims by product: Auto (136), Home (19)
- Life and Health have NO claims (expected)

## Business hypotheses
1. One client = one contract (client_id is unique).
2. Only Auto and Home products generate claims.
3. Date formats are mixed across all date columns.
4. Amounts use multiple currency formats, mostly suffix €.
5. Missing values concentrated in: csp, gender, client_age, liability, expert_id.
6. 'year' and 'previous_claims' in vehicles contain values that don't match numeric regex → to investigate in Phase 6.
