# Phase 27 — Transactions and Integrity

## Purpose
Master transactions, savepoints, isolation levels and deadlock handling.

## Key concepts

### BEGIN / COMMIT / ROLLBACK
- `BEGIN` starts a transaction.
- `COMMIT` persists changes.
- `ROLLBACK` cancels all changes.

### SAVEPOINT
- `SAVEPOINT name` marks an intermediate point.
- `ROLLBACK TO SAVEPOINT name` rolls back to it.
- `RELEASE SAVEPOINT name` removes it.

### Isolation levels
| Level | Dirty read | Non-repeatable read | Phantom read |
|-------|-----------|---------------------|--------------|
| READ UNCOMMITTED | allowed (not in PG) | yes | yes |
| READ COMMITTED (default) | no | yes | yes |
| REPEATABLE READ | no | no | yes (not in PG) |
| SERIALIZABLE | no | no | no |

PostgreSQL maps READ UNCOMMITTED to READ COMMITTED.

### Deadlocks
- Two transactions wait on each other's locks.
- PostgreSQL detects and aborts one.
- Prevention: access tables in the same order, keep transactions short.

### Transactions in procedures
- PL/pgSQL procedures (PostgreSQL 11+) can COMMIT/ROLLBACK inside.
- Functions cannot control transactions.

## Business cases

### Indemnification (claims)
- Multiple updates: damage, status, indemnified amount.
- Must be atomic.
- Use SAVEPOINT for partial rollback.

### Contract amendment (avenant)
- Update premium, dates, status.
- Rollback if any constraint fails.

## Files
- `sql/05_advanced/05_transactions.sql`
- `docs/27_transactions.md`
