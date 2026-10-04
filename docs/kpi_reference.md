# KPI Reference

Catalog of all insurance KPIs computed in this project.

## Portfolio KPIs

| KPI | Formula | Interpretation |
|-----|---------|----------------|
| Total premium | SUM(annual_premium_eur) | Revenue from premiums |
| Average premium | AVG(annual_premium_eur) | Mean contract value |
| Contracts count | COUNT(contract_id) | Portfolio size |
| Clients count | COUNT(DISTINCT client_id) | Customer base |

## Claims KPIs

| KPI | Formula | Interpretation |
|-----|---------|----------------|
| Claim frequency | claims / contracts | Risk exposure |
| Severity | AVG(damage_amount_eur) | Average cost per claim |
| Total damage | SUM(damage_amount_eur) | Gross claim cost |
| Total indemnified | SUM(indemnified_amount_eur) | Net payout |

## Profitability KPIs

| KPI | Formula | Interpretation |
|-----|---------|----------------|
| Loss ratio | indemnified / premium | < 1 profitable; > 1 loss |
| Expense ratio | overhead / premium | Assumed 25% in this project |
| Combined ratio | loss ratio + expense ratio | < 1 profitable overall |

## Retention KPIs

| KPI | Formula | Interpretation |
|-----|---------|----------------|
| Retention rate | (Active + Renewed) / total | Loyalty |
| Churn rate | Cancelled / total | Attrition |
| LTV | SUM(premium) / COUNT(DISTINCT client) | Customer value |

## Fraud KPIs

| KPI | Formula | Interpretation |
|-----|---------|----------------|
| Suspicion score | weighted sum of 5 signals | Prioritize investigation |
| Negative-delay claims | declaration < occurrence | Data or fraud anomaly |
| Expert concentration | claims per expert | Network signal |

## Segmentation KPIs (RFM)

| KPI | Formula |
|-----|---------|
| R | Days since last contract |
| F | Number of contracts |
| M | Total premium |
| S | Total damage |

## Dimensions of analysis

- **Time**: year, quarter, month, day-of-week
- **Product**: Auto, Home, Life, Health
- **Channel**: Broker, Agency, Web, Phone
- **Geography**: city, postal code, risk zone
- **Customer**: age band, gender, CSP
- **Status**: Active, Renewed, Expired, Cancelled, Suspended

## Where to find each KPI in SQL

| KPI | File |
|-----|------|
| Portfolio KPIs | `sql/04_analytics/07_insurance_kpis.sql` |
| Loss ratio | `sql/04_analytics/07_insurance_kpis.sql` (KPI 3.1) |
| Frequency, severity | `sql/04_analytics/07_insurance_kpis.sql` (KPI 2.x) |
| Retention, churn | `sql/04_analytics/12_cohort_retention_churn.sql` |
| Fraud score | `sql/04_analytics/11_fraud_analytics.sql` |
| RFM | `sql/04_analytics/13_rfm_segmentation.sql` |
