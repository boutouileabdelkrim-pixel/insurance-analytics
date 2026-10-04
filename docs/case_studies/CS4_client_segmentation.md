# Case Study 4 — Client Segmentation (RFM)

## Business question
How to segment clients into actionable groups? Which to prioritize?

## SQL approach
1. Compute RFM + Sinistrality per client.
2. Score each axis 1-5 via NTILE(5).
3. Assign segments via CASE rules.
4. Measure segment size and value.
5. Identify negative-margin clients.

## Axes
- **R** — Recency (days since last contract)
- **F** — Frequency (number of contracts)
- **M** — Monetary (total premium)
- **S** — Sinistrality (total damage)

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

## Files
- `sql/08_case_studies/04_client_segmentation.sql`

## Key queries

### Q1: Segment size and value
Distribution of clients and average monetary/sinistrality.

### Q2: Segment share of total premium
% of clients vs % of premium per segment.

### Q3: Negative-margin clients
Top 20 clients where claims > premium.

## Recommendations per segment

| Segment | Action |
|---------|--------|
| Champions | VIP loyalty program, referral |
| Loyal High-Value | Cross-sell, upsell |
| New Promising | Onboarding, welcome offers |
| At Risk High-Value | Retention campaign, personal contact |
| Lost Low-Value | Low-priority, automated offers |
| High-Risk | Repricing, risk review |

## Files
- `sql/08_case_studies/04_client_segmentation.sql`
- `docs/case_studies/CS4_client_segmentation.md`
