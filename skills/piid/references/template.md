# piid — output template

The artifact is `piid-<slug>.md`. Sections 1–4 are **Project Intent** — the user's approval surface, read once front to back, and they have to carry a reader who knows nothing from "why does this exist" to "why this shape". Sections 5–14 are **Project Implementation** — reference material, executed against rather than read through.

The implementer reads all of it, in order, once. Write the first half as prose that holds together as an argument; write the second half as something you could work down with a terminal open.

Every section is required. If one is genuinely empty, write `None — <reason>` rather than deleting it; a missing section reads as an oversight to a fresh model, and it starts improvising to fill the hole.

## Skeleton

```markdown
# <Feature> — build spec

**Status:** draft | agreed · **Date:** <YYYY-MM-DD>
**Implementer:** read §5 Context before touching §8 Steps. Do not deviate from §11.

## 1. Problem
Who hurts, what it costs them, the evidence with a real source. Two to five sentences.

## 2. Goals / Non-goals
**Goals** — observable outcomes, not activities. Include the success signal.
**Non-goals** — explicit, and each one is load-bearing: it tells the implementer what not to build.

## 3. Approach
The chosen shape in a sentence. Then each runner-up and the specific reason it lost,
priced against this codebase — not in the abstract.

## 4. Behavior
The user-visible change, state by state: before → after. Cover empty, loading, error,
and unauthorized states explicitly. If there's a UI, describe what appears where.

## 5. Context — how this area works today
Written for someone who has never opened this repo. Straight from recon, with real paths.

- **Call path:** entry point → ... → data layer, `path:line` at each hop
- **Pattern to mirror:** the closest existing feature, and why it's the right model to copy
- **Data model as-is:** tables, columns, types, nullability, indexes
- **Invariants:** what must stay true, and what breaks if it doesn't
- **Commands:** build, test, lint, migrate — exact strings, copied from the repo

## 6. Data & schema changes
Exact DDL or model deltas: column names, types, nullability, defaults, indexes, constraints.
Migration file location and the repo's naming convention.
Backfill strategy for existing rows — including "none needed", stated deliberately.
Backward compatibility: what old rows and old clients see between deploy and backfill.

## 7. Interfaces & contracts
Exact signatures for every new or changed function, endpoint, event, or type.
Request and response shapes with field types. Error cases and status codes.
Every existing caller affected, by `path:line`, and what changes for each.

## 8. Implementation steps
Ordered, dependency-correct, each one self-contained and verifiable.

### Step N — <imperative title>
- **Files:** exact paths, each marked new or modified
- **Change:** what to write. Show the code, or cite the pattern at `path:lines` and name
  what to carry over from it.
- **Verify:** the command to run and the expected result, including expected failures
  that a later step will fix.
- **Careful:** anything destructive, irreversible, or easy to get subtly wrong. Omit if none.

## 9. Edge cases
| # | Case | Decided behavior |
|---|------|------------------|

One row per case. Empty, concurrent, unauthorized, partial failure, retry, malformed input,
and data that predates this change. Mark defaulted decisions inline.

## 10. Testing
Exact cases to add, with target file paths and the fixture convention to follow.
The command to run them and what passing output looks like.
What is deliberately not tested, and why.

## 11. Do not touch
Explicit bounds: files, patterns, and behaviors to leave alone. State plainly that there are
to be no opportunistic refactors, renames, dependency bumps, formatting sweeps, or added
abstractions beyond what §8 specifies.

## 12. Rollout & monitoring
Flag name and default. Deploy order relative to the migration. Backfill trigger.
Signals that confirm health. Rollback procedure, and whether the migration is reversible.

## 13. Decision log
| # | Decision | Options considered | Why | Source |
|---|----------|--------------------|-----|--------|

Source is one of: `user` · `(defaulted)` · `(author's call)`.

## 14. Open questions
Empty at signoff. Kept as a section so drift found during implementation has a home.
```

## Writing steps: the difference that matters

A human engineer fills gaps from taste and context. A fresh model fills them by inventing. Compare:

**Insufficient** — a human could work with this; a fresh model will produce something plausible and wrong:

> **Step 3** — Add soft delete to the item repository. Follow the existing pattern and make sure the read paths handle it properly.

**Sufficient:**

> ### Step 3 — Add `softDelete` to the item repository
>
> - **Files:** `src/repos/item_repo.ts` (modified)
> - **Change:** add `softDelete(id: string, now: Date, tx?: Transaction): Promise<void>` that sets `deleted_at = now` and leaves the row in place. Mirror `src/repos/post_repo.ts:41-58` exactly — same `tx` threading, same `NotFoundError` throw when zero rows are affected, same JSDoc shape. Then add `AND deleted_at IS NULL` to the `WHERE` clause in `findById` (`item_repo.ts:22`) and `list` (`item_repo.ts:35`). Those are the only two read paths in this file; `countAll` (`item_repo.ts:51`) is intentionally left counting deleted rows — see §9 row 4.
> - **Verify:** `npm test -- item_repo` — the 4 existing tests pass. The 2 tests added in Step 6 do not exist yet.
> - **Careful:** none.

The difference isn't length, it's that every noun is resolved: which file, which lines, which pattern, which query paths, which deliberate exception, and what the terminal should say afterwards.

## Section-specific traps

- **§5 Context** is the section most often written too thin. If the implementer would have to open five files to reconstruct the call path, the call path belongs in the document.
- **§6 Data** — "add a soft delete column" is not a schema change. Name the column, type, nullability, default, and index.
- **§7 Interfaces** — a signature without its error cases is half a contract.
- **§8 Steps** — "update the tests" is not a step. Name the file, the cases, and the command.
- **§9 Edge cases** — if a case was decided in the interview and doesn't appear as a row, the implementer will decide it again, differently.
- **§11 Do not touch** — feels blunt, prevents most of the collateral damage. Always fill it in.
