---
name: piid
description: Project Intent and Implementation Document — turn a basic prompt (business ask, bug report, user feedback, feature idea) through interview, analysis, and review into a detailed ticket that a new developer can execute without further input. Invoke with /piid <request>.
disable-model-invocation: true
---

# piid — the ticket factory

Raw input in — a business request from a PM, user feedback, a bug report, a developer's feature idea. Ticket out: `piid-<slug>.md` in cwd, built from this codebase, senior-developer judgement, and the tools at hand, then handed to a **fresh but smart agent** who executes it without any further input.

The agent settles every craft question. 
1. *Fresh*: they weren't in this conversation and hold no mental model of this area — point them at exactly the files, queries, and logs that build one. 
2. *Smart*: they can write the code themselves — the doc is a guiding hand, not the diff dumped into markdown. Write down what they can't derive (context, decisions, pointers); be helpful when you'd err on the side of specificity (code snippets); leave to them what they can (the code).

**Hard gate:** no implementation or code edits this session — the deliverable is the document.

## Step 1: Understand

Too vague to search on? Ask right away to narrow the radius. Otherwise gather alone — this pass exists to build *your* mental model, so read the related code yourself rather than delegating to subagents. Done when you can name the part of the codebase involved and how a request moves through it. 

If the request embeds a preliminary "how", note it and assume for now that it's wrong. 

## Step 2: Interview — intent only

Short and behavioural. Number the questions, attach your recommended answer to each, and hold numbers stable across rounds — the user answers by number, inline, out of order. Establish:

- the exact problem, anecdotally
- why — the real-world, business reason this needs fixing
- the intended outcome

Facts are never interview questions — look them up. Done when problem, why, and goal are stated in the user's own terms.

## Step 3: Preliminary solution

Form a theory of what to do. Your first answer is usually wrong, so attack it:

- trace the flow end to end
- spin up subagents to validate against live code and data rather than memory: does the theory survive contact? how does it behave at real volumes? which edge cases exist?
- keep the back-of-mind bias **lazy** — the laziest solution that actually works: does this need to exist at all? already in the codebase → reuse before writing; stdlib, native platform, or an installed dependency before new code; the shortest diff that works.

Done when the theory has survived validation or been corrected by it, and every finding that moved it is recorded.

## Step 4: Review with the user

The deep checkpoint, in chat:

- **Blocking** — decisions you can't default: numbered, each with options and a recommendation. These need answers.
- **Non-blocking** — everything you defaulted: one line each stating the sensible default. The user vetoes what they disagree with; otherwise assume good to go.
- Follow-ups that emerged from validation.

Done when every blocking question is answered and the non-blocking list has had its veto pass.

## Step 5: Plan

Decisions locked — plan the implementation, refining or outright rewriting the step-3 theory. Surgical and lazy, harder than before: the plan is the shortest ordered path to the goal. Done when each step is small enough to hand to one agent and check.

## 6 · Write, then cold re-read

Write `piid-<slug>.md` to cwd in this shape — every section lean, §5 only if it has content:

```markdown
# PIID — One Line Title
> **Source request:** <the raw input, verbatim or tightly paraphrased> <requester, date>

# 1. Context
## Problem
## Why this needs a fix
## Goal

# 2. References & Blast Radius
Everything the agent reads, runs, and inspects before touching code. Order it
the way the system moves — a request path, a user journey, a parameter passing
through functions — never alphabetically.

- <one-line description> [path:line where it matters]
- <query to run, log to read>

The closest existing pattern to mirror is the highest-value pointer here.

Footer: date, time, last commit hash, and the line: "If repo behavior has
drifted since this commit, stop, flag it to the user, and rework this piid."

# 3. Analysis
## Solution
The settled solution, as a bulleted list — what and why, not yet step-by-step.

## Iterations
**Preliminary solution:** what we thought at the start, 2–3 lines.
**Findings:** one `<finding>: <decision>` line each — concise, but enough
context that the agent never wonders whether it was thought through.

# 4. Implementation Instructions
Structure as delegation: different codebases → separate agents; same codebase
with narrow parallelizable scopes → subagents; otherwise one agent, in order.

Steps ordered and dependency-correct, each self-contained and verifiable.
Snippets where they disambiguate; the diff itself is the agent's job.

# 5. Miscellaneous
Only if it has content. Future ideas and todos (noted, nothing actionable this
turn), edge cases worth a line, blocks to go-live (e.g. awaiting another
pipeline).
```

Then the cold re-read: in character as the agent — this document, the repo, nothing else. Any point where they'd have to come back and ask is a defect; fix it inline. Done when the agent proceeds start to finish alone.
