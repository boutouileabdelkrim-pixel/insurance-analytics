# Phase 26 — Triggers

## Purpose
Automate audit and integrity rules via PostgreSQL triggers.

## Triggers catalog

| Trigger | Table | Timing | Event | Purpose |
|---------|-------|--------|-------|---------|
| trg_contracts_audit | core.contracts | AFTER | INSERT/UPDATE/DELETE | Log all changes to audit.contracts_history |
| trg_claims_audit | core.claims | AFTER | INSERT/UPDATE/DELETE | Log all changes to audit.claims_history |
| trg_check_premium | core.contracts | BEFORE | INSERT/UPDATE | Block negative premium |
| trg_check_claim_delay | core.claims | BEFORE | INSERT/UPDATE | Warn on negative delay |

## Audit tables
- `audit.contracts_history` — stores old_data / new_data as JSONB.
- `audit.claims_history` — same for claims.
- Columns: history_id, <pk>, operation, old_data, new_data, changed_at, changed_by.


## Trigger function: TG_OP
- `TG_OP` = 'INSERT' / 'UPDATE' / 'DELETE'.
- `NEW` = row after change.
- `OLD` = row before change.
- Return `NEW` (BEFORE/AFTER INSERT/UPDATE), `OLD` (DELETE), `NULL` (AFTER, to skip).

## RAISE levels
- `RAISE NOTICE` — informational.
- `RAISE WARNING` — non-blocking.
- `RAISE EXCEPTION` — blocks transaction.

## Key learnings
- `to_jsonb(NEW)` serializes the row.
- Audit tables use JSONB for schema flexibility.
- Triggers are powerful but can hide logic: document them.
- Use `BEFORE` to validate/modify, `AFTER` to record.

## Files
- `sql/05_advanced/04_create_triggers.sql`
- `docs/26_triggers.md`
