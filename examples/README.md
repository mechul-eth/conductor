# examples/ — Worked Examples

> Copy these as a starting point, study them as a finished reference, or compare yours against them.

## What's here

| Directory | What it shows | Use it as |
|-----------|---------------|-----------|
| `filled-business/` | A fully filled-in `conductor-core/business/` for a fictional B2B SaaS company called "Northwind Notes" | Reference for what a real, plugged-in Conductor looks like before you're done with onboarding |

## How to Use the Filled Business Example

```bash
# Compare your business/ to the example
diff -r conductor-core/business/ examples/filled-business/

# Or copy the example as a starting point (then edit to match YOUR business)
cp -r examples/filled-business/* conductor-core/business/
```

The example is not a template — it's an answered version. Use it to understand:

- How the four baseline files (`core.md`, `market.md`, `user-profile.md`, `insights.md`) work together
- What "good enough to plug in" looks like
- How `ROUTING.md` wires roles to context for a small team
- How an intelligence-domain `foundation.md` gets filled in
- How tagging conventions are applied in practice

## Adding a New Example

We welcome examples for different shapes of business — solo dev, agency, marketplace, regulated industry, etc. To add one:

1. Copy `filled-business/` to `examples/<your-name>/`.
2. Edit every file to fit your shape — be specific, even if fictional. Vague examples don't teach anything.
3. Add a row to the table above describing what it shows.
4. Open a PR.

## Cross-References

Referenced from the top-level `README.md` and `conductor-core/business/README.md` (the "What a filled-in business looks like" line).
