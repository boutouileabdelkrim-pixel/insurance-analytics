# Case Study 1 — Product Profitability (Loss Ratio)

## Business question
Which insurance products are profitable? Are there segments where the
loss ratio exceeds 1 (under-priced)?

## SQL approach
1. Compute loss ratio per product: SUM(indemnified) / SUM(premium).
2. Compute combined ratio (loss ratio + assumed 25% expense ratio).
3. Break down by product × risk zone.
4. Identify segments with loss ratio > 1.

## Files
- `sql/08_case_studies/01_product_profitability.sql`

## Definitions
- **Loss ratio** = indemnified / premium. < 1 = profitable, > 1 = loss.
- **Combined ratio** = loss ratio + expense ratio. < 1 = profitable overall.

## Key queries

### Q1: Global loss ratio per product
Returns one row per product with premium, indemnified, loss ratio.

### Q2: Combined ratio
Adds assumed 25% expense ratio. Products with combined ratio > 1 lose money.

### Q3: Loss ratio per product × zone
Reveals geographic risk concentration.

### Q4: Under-priced segments
Segments where loss ratio > 1 → repricing candidates.

## Recommendations (framework)
- **Loss ratio < 0.6**: profitable, grow this product.
- **0.6 ≤ Loss ratio < 1**: healthy, monitor.
- **Loss ratio ≥ 1**: unprofitable → reprice or exit.
- **Combined ratio > 1**: overall loss → urgent action.

## Files
- `sql/08_case_studies/01_product_profitability.sql`
- `docs/case_studies/CS1_product_profitability.md`
