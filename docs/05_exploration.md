# Phase 5 — Exploration des données brutes

## Volumétrie
| Table     | Lignes | Colonnes |
|-----------|--------|----------|
| contracts | 15000  | 14       |
| claims    | 155    | 10       |
| vehicles  | 5390   | 10       |

## Clés candidates
- raw.contracts.contract_id  : clé primaire candidate (unique)
- raw.contracts.client_id    : à vérifier (unique ou non)
- raw.claims.claim_id        : clé primaire candidate
- raw.vehicles.contract_id   : clé étrangère vers raw.contracts

## Granularité
- raw.contracts : 1 ligne = 1 contrat
- raw.claims    : 1 ligne = 1 sinistre
- raw.vehicles  : 1 ligne = 1 véhicule

## Catégories observées
### product
(à compléter avec les valeurs observées en 5.5.A)

### status (contrats)
(à compléter en 5.5.B)

### gender
(à compléter en 5.5.C)

### claim_type
(à compléter en 5.5.G)

## Problèmes de qualité détectés
1. Dates en formats mixtes (YYYY-MM-DD, DD/MM/YYYY, ...)
2. Montants en TEXT avec devises mixtes (€, EUR, $)
3. Valeurs manquantes sur : (csp, expert_id, ...)
4. Catégories hétérogènes sur : (gender, ...)

## Relations entre tables
- claims.contract_id    → contracts.contract_id  (orphelins : X)
- vehicles.contract_id  → contracts.contract_id  (orphelins : X)

## Hypothèses métier
1. ...
2. ...
3. ...
