# Phase 3 — Environnement local

## Système
- OS : Kubuntu (Ubuntu 22.04/24.04 LTS)
- PostgreSQL : version 15.x ou 16.x
- Client : pgAdmin 4 + psql

## Base de données
- Nom : insurance_analytics
- Encodage : UTF8
- Locale : en_US.UTF-8

## Schémas
- raw : données brutes
- staging : données nettoyées
- core : modèle relationnel cible
- analytics : vues et objets analytiques

## Conventions de nommage
- Tables : snake_case pluriel (contracts, claims)
- Colonnes : snake_case singulier (policy_id, claim_date)
- Clés primaires : id ou <table>_id
- Clés étrangères : <table_référencée>_id
- Index : idx_<table>_<colonnes>
- Vues : v_<nom>
- Vues matérialisées : mv_<nom>
- Fonctions : fn_<nom>
- Procédures : sp_<nom>
- Triggers : trg_<table>_<action>
- Fichiers SQL : NN_<description>.sql
