# business/segments/ — Customer Segments

> Create one file per distinct customer segment. Conductor loads the relevant segment file when a role is activated whose work depends on segment-specific context (sales, marketing, product).

## When to Create a File Here

Per `CONDUCTOR.md` §Dynamic Growth, create a new segment file when:

- Your `market.md#positioning` references 2+ distinct customer groups with materially different needs.
- Product decisions differ by segment (feature scope, pricing, onboarding).
- Sales and marketing speak to the segments with different messaging.

If you only have one undifferentiated audience, keep segmentation in `market.md` and skip this directory.

## File Structure

Use `_template.md` as the starting point. Each segment file has these sections:

1. **Snapshot** — one paragraph: who they are, what they want from you.
2. **Demographics / Firmographics** — facts about the segment.
3. **Jobs-to-be-done** — what they hire the product to do.
4. **Objections** — what stops them from buying / using.
5. **Adoption pattern** — how they find, evaluate, and adopt the product.
6. **Pricing sensitivity** — what they'll pay and why.
7. **Expansion signals** — what signals they're ready to upgrade / expand use.
8. **Churn signals** — what signals they're about to leave.

Keep each file under 150 lines. Loading a segment should be cheap.

## Cross-References

This directory is referenced from:

- `business/README.md`
- `business/ROUTING.md` (when sales / marketing / product rows load segment context)
- `business/market.md#positioning` — segmentation overview lives in `market.md`; details live here

Link back from `market.md` whenever a new file is added here.
