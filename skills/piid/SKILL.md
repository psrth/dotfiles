---
name: piid
description: project intent and implementation doc — a deep interview that produces a single build spec exhaustive enough for a fresh model to implement blind. Invoke with /piid before building anything non-trivial.
disable-model-invocation: true
---

# piid — interview until aligned, then write the whole build

Deliverable: `piid-<slug>.md` in cwd — a **Project Intent and Implementation Document**, in two components:

1. **Project Intent** — interview the user to establish the _why_ and the _what_. Go as deep as possible.
2. **Project Implementation** — with the why and the what settled, detail the _how_, surfacing the important questions and trade-offs before outlining a scaffold someone can build from.

`references/template.md` is the target shape. Read it first: the interview exists to fill it.

**Hard gate:** no implementation, scaffolding, or code edits this session. The only deliverable is an approved document.

## Two readers

- **The user** approves intent. Their attention is the scarce resource.
- **A blind implementer** — a fresh model holding this document and the repo, nothing else. It was not in the interview, has not read the code, and cannot ask you anything.

Blind is the demanding reader, and it settles most questions of craft on its own: whatever it would have to guess is whatever you have to write down.

## Ask intent · look up facts · decide mechanics

Folding implementation into intent multiplies the open decisions, and most of them are not the user's. Asking anyway turns an interview into an interrogation.

- **Intent → ask.** Anything with a product, cost, risk, or preference consequence. Soft vs hard delete. Whether v2 exists. What the user sees when it fails.
- **Facts → look up.** Current behavior, where things live, existing patterns, feasibility. Recon settles these.
- **Mechanics → decide and log.** Names, file placement, argument order, test layout. Match the surrounding code, record it _(author's call)_, and surface the set at the alignment check as a list the user can veto.

## 1 · Recon

Map the ground before the first question — `Explore` subagents for breadth. Complete when you can name:

- the call path through the area, `path:line` at each hop
- **the pattern to mirror** — the closest existing feature. The highest-value thing you will find; the implementer copies it instead of inventing.
- the data model as it stands: types, nullability, indexes, migration conventions
- every caller in the blast radius
- test conventions, and the exact build / test / lint / migrate commands as the repo spells them

This lands in the document near-verbatim. Recon you keep to yourself is recon you wasted.

## 2 · Interview

Number every question and hold the numbers stable across rounds — the user answers by number, inline, out of order. Each question carries your recommended answer and the reason for it: _"Recommend 30-day soft delete — matches how posts already work (`models/post.py:88`)."_

Order beats coverage. Split the scope first if this is really several projects, then problem, then approach — and hang everything else off the approach, since locking the shape early makes every later question cheaper.

Second-order thinking throughout: "implement X" is a hypothesis about the solution, and the interview is what tests it.

Restate locked vs open after each round. Flag contradictions rather than absorbing them. "Just pick" → pick, mark _(defaulted)_, move on.

The interview ends when Open Questions is empty, not at a question quota.

## 3 · Write

Skeleton and craft: `references/template.md`.

The document carries two jobs at once — it reads as a story front to back, and it works as a step-by-step guide with a terminal open. Carry the reasoning as well as the verdicts: a reader who disagrees should be able to see what was already considered.

## 4 · Blind review

Before the user sees anything, re-read the document cold, in character as the implementer. Done when:

- every noun resolves — no name, shape, location, or order left to invent
- every path, symbol, and command named is verified present in the repo
- step N depends only on steps 1..N-1
- every line reads exactly one way
- later sections agree with earlier decisions
- Open Questions is empty, or honestly populated

Guess points are defects. Fix them inline. This pass is not a skim.

## 5 · Align, then ship

Present the decision log, the _(author's call)_ list to veto, and five lines on what gets built. On confirmation write the file, and point the user at it as the thing to hand the implementer. Wobble is an open question — loop back to its cluster.

A document a fresh model executes end to end without asking you anything is done. One that reads well and hides a TBD is not.
