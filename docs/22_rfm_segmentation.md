# Phase 22 — RFM / Segmentation (Insurance)

## Purpose
Segment clients using RFM extended with Sinistrality and Profitability.

## Axes
- R — Recency (days since last contract)
- F — Frequency (number of contracts)
- M — Monetary (total premium)
- S — Sinistrality (total damage)
- P — Profitability = M - S

## Scoring
Each axis scored 1–5 via NTILE(5).

## Segments
| Segment | Rule |
|---------|------|
| Champions | R≥4 & F≥4 & M≥4 |
| Loyal High-Value | R≥3 & M≥4 |
| New Promising | R≥4 & F≤2 |
| At Risk High-Value | R≤2 & M≥3 |
| Lost Low-Value | R≤2 & M≤2 |
| High-Risk | S≥4 |
| Standard | Otherwise |

## Query file
`sql/04_analytics/13_rfm_segmentation.sql`

## Key learnings
- NTILE(5) for quintile scoring.
- CASE for segment assignment.
- Multi-CTE for full pipeline.
- Window aggregates for share of total.

## Business actions per segment
- Champions → loyalty program, VIP.
- Loyal High-Value → cross-sell.
- New Promising → onboarding.
- At Risk High-Value → retention offers.
- Lost Low-Value → low priority.
- High-Risk → risk review / repricing.
