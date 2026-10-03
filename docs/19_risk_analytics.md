# Phase 19 — Risk Analytics

## Purpose
Map portfolio risk: segmentation, concentration, correlation,
under-priced and high-risk segments.

## Sections
1. Risk by customer profile (age, gender, CSP)
2. Risk by product (frequency, severity, loss ratio)
3. Risk by geography (zone, city)
4. Risk concentration (Pareto)
5. Correlation (vehicle year, previous claims)
6. High-risk segments (product × zone)
7. Under-priced segments (loss ratio > 1)
8. Emerging risk (YoY trend)

## Query file
`sql/04_analytics/10_risk_analytics.sql`

## Key learnings
- Loss ratio > 1: unprofitable segment.
- Combined ratio > 1: overall loss.
- NTILE(100): top 1% concentration.
- LAG on yearly: emerging risk detection.

## Business insight
- Young drivers higher frequency.
- Risk zone loss ratio ranking.
- Product × zone combos to reprice.
- Segments requiring repricing or exit.
