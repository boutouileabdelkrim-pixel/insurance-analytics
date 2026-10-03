# Phase 16 — Insurance KPI Catalog

## Purpose

Define and compute a reference catalog of insurance KPIs, with
breakdowns by dimension. Serve as foundation for Phases 17-22.

## KPI definitions

| KPI | Definition | Formula |
|---|---|---|
| Total premium | Sum of annual premiums | SUM(annual_premium_eur) |
| Average premium | Mean premium per contract | AVG(annual_premium_eur) |
| Claim frequency | Claims per contract | COUNT(claims) / COUNT(contracts) |
| Severity | Mean damage per claim | AVG(damage_amount_eur) |
| Loss ratio | Indemnified / Premium | SUM(indemnified) / SUM(premium) |
| Expense ratio | Overhead / Premium | (assumed 25%) |
| Combined ratio | Loss ratio + Expense ratio | LR + ER |
| Retention rate | Active or Renewed / Closed | |
| Churn rate | Cancelled / Total | |
| LTV (simplified) | Total premium per client | SUM(premium) GROUP BY client |
| Fraud suspicion rate | Suspicious claims / Total claims | |

## Dimensions of analysis

- **Time**: year, quarter, month
- **Product**: Auto, Home, Life, Health
- **Channel**: Broker, Agency, Web, Phone
- **Geography**: city, risk zone
- **Customer**: CSP, gender, age
- **Contract status**: Active, Renewed, Cancelled, Expired, Suspended

## Query catalog

The file `sql/04_analytics/07_insurance_kpis.sql` contains 20 KPIs:

| # | KPI | Section |
|---|---|---|
| 1.1 | Portfolio totals | Portfolio |
| 1.2 | Premium per product | Portfolio |
| 1.3 | Portfolio by risk zone | Portfolio |
| 2.1 | Global claim frequency | Claims |
| 2.2 | Global severity | Claims |
| 2.3 | Frequency & severity per product | Claims |
| 3.1 | Loss ratio per product | Loss ratio |
| 3.2 | Combined ratio | Loss ratio |
| 3.3 | Global loss ratio | Loss ratio |
| 4.1 | Contracts by status | Retention |
| 4.2 | Retention rate | Retention |
| 4.3 | Churn rate | Retention |
| 5.1 | Avg premium per client | Customer |
| 5.2 | Client distribution by contracts | Customer |
| 5.3 | Multi-product clients | Customer |
| 6.1 | Suspicious claims (decl before occ) | Fraud |
| 6.2 | Experts with multiple claims | Fraud |
| 6.3 | High damage vs type avg | Fraud |
| 7.1 | Channel KPI | By dimension |
| 7.2 | Loss ratio by CSP | By dimension |
| 7.3 | Loss ratio by risk zone | By dimension |
| 8.1 | Consolidated dashboard | Dashboard |

## Business interpretation

- **Loss ratio > 1**: product is unprofitable.
- **Combined ratio > 1**: company is losing money on this segment.
- **High claim frequency**: riskier product or underwriting issue.
- **High churn rate**: retention problem, need retention strategy.
- **Multi-product clients**: high-value, target for loyalty programs.
- **Suspicious claims**: triggers for fraud investigation.

## Files

- `sql/04_analytics/07_insurance_kpis.sql`
- `docs/16_insurance_kpis.md`
