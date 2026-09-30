# Phase 3 — Local Environment Setup

## System
- OS: Kubuntu (Ubuntu 26.04 LTS)
- PostgreSQL: version 18.6
- Client: pgAdmin 4 + psql

## Database
- Name: insurance_analytics
- Encoding: UTF8
- Locale: en_US.UTF-8

## Schemas
- raw: raw imported data
- staging: cleaned and typed data
- core: target relational model
- analytics: views and analytical objects

## Naming conventions
- Tables: snake_case plural (contracts, claims)
- Columns: snake_case singular (policy_id, claim_date)
- Primary keys: id or <table>_id
- Foreign keys: <referenced_table>_id
- Indexes: idx_<table>_<columns>
- Views: v_<name>
- Materialized views: mv_<name>
- Functions: fn_<name>
- Procedures: sp_<name>
- Triggers: trg_<table>_<action>
- SQL files: NN_<description>.sql
## PostgreSQL users

- `postgres` : superuser (system default)
- `loranos`  : project superuser (local dev), used for all project work
