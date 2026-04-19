# business/research/ — Market & User Research Notes

> Create one file per organized research topic. Conductor loads these when a role activates whose work depends on the topic — usually product, strategy, marketing, or design.

## When to Create a File Here

Per `CONDUCTOR.md` §Dynamic Growth, create a research file when:

- The user shares 3+ external URLs or documents on the same topic.
- A research effort produces synthesized findings that should outlive a single session.
- Conductor needs to ground future decisions in the same body of evidence.

For one-off shared links, summarize in `insights.md` instead.

## File Structure

Use `_template.md` as the starting point. Each research file has these sections:

1. **Topic** — one line: what was researched, why.
2. **Sources** — list of links, documents, interviews. Tag each with `[external]`, `[user-stated]`, `[user-shared-link]`.
3. **Key findings** — bullet list of the load-bearing conclusions.
4. **Open questions** — what's still unclear.
5. **Implications** — how this should shape decisions.
6. **Last updated** — date + who.

Keep each file under 300 lines. Aim for digestible synthesis, not raw notes.

## Cross-References

This directory is referenced from:

- `business/README.md`
- `business/ROUTING.md` (when a role row loads research context)
- `business/insights.md` (cross-link individual decisions back to the research that informed them)
- `business/market.md` (when research informs positioning or competitive intelligence)
