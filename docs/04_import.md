# Phase 4 — Importation des données

## Dataset
- Nom    : Insurance Dataset for Data Engineering Practice
- Source : Kaggle
- Auteur : kpoviesistphane
- Licence : (A COMPLETER depuis la page Kaggle)

## Fichiers sources
| Fichier       | Lignes CSV | Lignes données | Taille | Description |
|---------------|------------|----------------|--------|-------------|
| contracts.csv | 15001      | 15000          | 1.8 MB | Contrats    |
| claims.csv    | 156        | 155            | 15 kB  | Sinistres   |
| vehicles.csv  | 5391       | 5390           | 390 kB | Véhicules   |

## Emplacement local
~/insurance-analytics/data/raw/

## Tables créées (schéma raw)
- raw.contracts : 14 colonnes (TEXT)
- raw.claims    : 10 colonnes (TEXT)
- raw.vehicles  : 10 colonnes (TEXT)

## Colonnes
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

## Procédure d'import
1. Copie des CSV dans /tmp/raw_import/ (accessible par postgres)
2. chown postgres:postgres + chmod 644
3. Import via COPY :
   COPY raw.<table> FROM '/tmp/raw_import/<table>.csv'
   WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

## Vérification post-import
- contracts : 15000 lignes
- claims    : 155 lignes
- vehicles  : 5390 lignes

## Problèmes de qualité observés (à traiter en Phase 6)
- Dates mixtes : '2023-08-11', '11/08/2023'
- Montants en texte avec symbole € : '1974.98€', '€620.93'
- Valeurs manquantes (csp, expert_id)
- Catégories hétérogènes (gender : 'F', 'M')
