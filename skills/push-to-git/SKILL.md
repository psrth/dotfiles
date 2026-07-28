---
name: push-to-git
description: Ship the current work — terse commits, push, PR when needed. Use when the user invokes /push-to-git or says "ship it" / "commit this", or when finished work is ready to go out.
---

# push-to-git — working tree → confirmed plan → pushed

One stop, then end to end: propose the full plan, get a single go, execute without further pauses. The hard stop regardless: working-tree contents that are clearly not part of the current work (unrelated files, secrets, giant binaries) get excluded and called out — never committed silently.

## 1. Understand the diff

- Changes from this session → proceed. Picking up from fresh context → `git status` + `git diff` first; understand what the change _does_ before writing a word about it.

## 2. Propose the plan — the one stop

Present in a single message, then wait for the go. The user edits any part by name; a bare yes executes everything exactly as shown.

- **Target** — branch + PR by default; a repo whose main history is linear direct-to-main (no merge commits) gets a commit straight to main and no PR. Say which and why.
- **Branch name** (when branching) — `<type>/<high-level-summary>`, e.g. `feat/new-user-profile-endpoint`. Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`.
- **Commit message(s)** — full text, per the rules below. Two clearly independent changes → two commits.
- **Exclusions** — anything in the tree being left out, named.

## 3. Commit

- Stage the related work including untracked files that belong to it; exclude debris (scratch files, `.env`, logs).

### Rules

**Subject line:**

- `<type>(<scope>): <imperative summary>`
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding"
- ≤50 chars when possible, hard cap 72
- No trailing period
- Match project convention for capitalization after the colon

**Body (only if needed):**

- Skip entirely when subject is self-explanatory
- Add body only for: non-obvious _why_, breaking changes, migration notes, linked issues
- Always include body for: breaking changes, security fixes, data migrations, anything reverting a prior commit — future debuggers need the context
- Hard cap 4 lines. Compress: a measurement is one line ("13 MB → 131 kB per lane"), a behavior delta is one line. Written for `git blame` archaeology, not for the reviewer.
- Detail has one home: the investigation story, full numbers, and open items go in the PR report — a paragraph never appears in both
- Wrap at 72 chars
- Bullets `-` not `*`
- Reference issues/PRs at end: `Closes #42`, `Refs #17`

**What NEVER goes in:**

- "This commit does X", "I", "we", "now", "currently" — the diff says what
- "As requested by..." — use Co-authored-by trailer
- "Generated with Claude Code" or any AI attribution
- Emoji
- Restating the file name when scope already says it
- The investigation narrative — that's the PR report's job

### Examples

Diff: new endpoint for user profile with body explaining the why

- ❌ "feat: add a new endpoint to get user profile information from the database"
- ✅

  ```
  feat(api): add GET /users/:id/profile

  Mobile client needs profile data without the full user payload
  to reduce LTE bandwidth on cold-launch screens.

  Closes #128
  ```

Diff: breaking API change

- ✅

  ```
  feat(api)!: rename /v1/orders to /v1/checkout

  BREAKING CHANGE: clients on /v1/orders must migrate to /v1/checkout
  before 2026-06-01. Old route returns 410 after that date.
  ```

## 4. Push & PR

1. **Push** with `-u` to origin. Main-target repos stop here.
2. **PR — when needed.** No open PR for the branch and `gh` works → create one (note: the GitHub repo name may differ from the local dir — trust `git remote -v`). PR exists → push updates; comment only if the change alters the PR's story. The PR body ships without a human look — **open the PR body**.
3. **PR Title: <type>: human description — feat: start tracking app uninstall events (#3013)**
4. **PR Report:** context, change/fix, go live and monitoring plan, notes (pending, risks, etc)

eg.

```
## Context
- Two full iap-catalog-seed jobs for the same offer can run concurrently and interleave per-day catalog writes (plain HSET, last-writer-wins per day).
- Incident (Jul 22, Yarn Loop iOS/AOS): the admin curve editor saves in two writes ~1s apart — performance_targets via PUT /admin/games/:id, then roas_extended_curves_* via POST /admin/boosted-offers-configuration/:id. The blind job's writes landed last on D1-36, leaving a mixed-mode catalog.

## Fix
1. Coalesce admin-save reseeds — enqueueIapCatalogSeedForOffer gains coalesce: jobId bucketed to a 15s window + 15s delay, so N saves in a burst collapse into ONE job (BullMQ jobId dedup) that runs after the burst settles and reads the FINAL row state
2. Per-offer seed mutex — processIapCatalogOffer is now a wrapper that takes ge:fs:iap:seed-lock:{bid} (SET NX EX 300) around the seed. A competing job requeues itself with a 15s delay and a bounded lockWaits counter (20 waits ≈ lock TTL, then it fails loudly to :failed).
3. Observability — the per-offer seed summary log now records extendedMode / extendedSeeded / effectiveMaxDay, so a run seeding from a partially-consistent row is directly visible

## Go-live and monitoring plan
1. Merge this PR.
2. Merge the companion reco-admin change that collapses the curve editor's two saves into one updateBoostedOffersConfiguration call.
3. Monitor via grep on GCP logs every 15 minutes post deploy.

## Notes
- Behavior deltas to be aware of: admin curve saves now reflect in catalogs after ~15-30s (delay window) instead of ~seconds
```
