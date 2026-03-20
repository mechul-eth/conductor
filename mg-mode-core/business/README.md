# Business Intelligence — Per-Project Knowledge Store

> MG_MODE learns about your business, your market, and your product through every interaction. This directory holds that intelligence. You own it. It never leaves your repository.

## What This Is

This directory is a living knowledge base. As you work with MG_MODE, it captures and organizes what it learns about:

- **You** — your expertise, preferences, how you work
- **Your business** — what you're building, your model, your constraints
- **Your market** — competitors, positioning, trends, risks
- **Your product** — features, architecture, roadmap decisions

This intelligence makes every future interaction smarter. Instead of starting from scratch on each prompt, MG_MODE knows your context.

## Files

| File | Contains | Created When |
|------|----------|-------------|
| `README.md` | This file — directory overview, rules, privacy guarantees | Always present |
| `user-profile.md` | Your expertise, preferences, communication style | Filled progressively from interactions |
| `core.md` | Business model, product vision, target audience, stage | Onboarding or auto-scan + ongoing |
| `market.md` | Competitors, market landscape, positioning, risks | When you share competitive data |
| `insights.md` | Key decisions, patterns, competitive learnings, session log | Ongoing — grows with every session |

## How It Starts

MG_MODE detects whether it's being added to an existing codebase or a fresh project:

- **Existing codebase:** Scans README, package configs, docs, and directory structure. Presents extracted intelligence as a batch for your approval. Fills business/ with what it learned — you correct or confirm.
- **Fresh project:** Asks 3 onboarding questions (what, for whom, competitors). You answer in detail or skip.

Either way, you approve every write. The system never assumes — it proposes.

## Dynamic Growth

This directory grows as your business grows. When any file gets complex enough, new sub-files are created (always with your approval):

```
business/
├── README.md          # This file (always present)
├── user-profile.md    # Always present
├── core.md            # Always present
├── market.md          # Always present
├── insights.md        # Always present
├── competitors/       # Created when 3+ competitors have detailed profiles
│   └── {name}.md
├── products/          # Created when multiple product lines need tracking
│   └── {product}.md
├── segments/          # Created when multiple distinct user segments exist
│   └── {segment}.md
└── research/          # Created when external URLs/docs need organized summaries
    └── {topic}.md
```

## Rules

1. **You approve every write.** MG_MODE proposes changes. You confirm before they persist.
2. **Everything is tagged.** Each piece of intelligence has a source: `[user-stated]`, `[user-implied]`, `[system-generated]`, or `[external]`.
3. **You can edit or delete anything.** These are your files. Change them anytime.
4. **Nothing leaves this repo.** No external transmission. No cross-project sharing. Fully isolated.

## How It Helps

When you say "build me a pricing page," MG_MODE already knows:
- Your business model (from `core.md`)
- Your competitors' pricing approach (from `market.md` or `competitors/`)
- Your technical strengths and gaps (from `user-profile.md`)
- Past architecture decisions that affect this feature (from `insights.md`)

That context shapes role selection, prompt generation, and the quality of what gets delivered.
