---
name: writing-a-skill
description: Author or audit skills. Use when the user wants to build or rework a skill / SKILL.md, or says "audit <skill>" for a read-only review against this guide.
---

# writing-a-skill — house guide for authoring and auditing skills

A skill exists to wrangle determinism out of a stochastic system. **Predictability** — the agent taking the same _process_ every run, not producing the same output — is the root virtue; every lever below serves it. The counterweight: the model's own judgement is strong, so a skill earns its lines only where process variance actually hurts. Constrain the process; trust judgement for the rest. A skill encodes opinions, knowledge, and process particular to you — repo gotchas belong in CLAUDE.md, and what the model already does by default belongs nowhere.

**Bold terms** are defined in [references/glossary.md](references/glossary.md); open it whenever a verdict hangs on a term's exact meaning.

Two branches: **write** (default) and **audit** (`audit <name-or-path>`). Everything after the branches is the bar both grade against.

## Write (default)

1. **Interview first.** Establish what a good run produces, what should trigger the skill, and which branches exist. Settle the name and the invocation mode — model- vs user-invoked is the description decision — before any prose. Recommend each answer; the user vetoes.
2. **Draft in `skills-wip/`.** SKILL.md carries the steps and whatever every branch needs; material only some branches reach goes to `references/` behind a pointer whose wording says when to load it. Each step ends on a checkable completion criterion.
3. **Self-audit.** Run the audit branch on the draft and fix what it finds. Done when a fresh pass raises nothing you wouldn't defend to the user.
4. **Present** the draft with the author's-call decisions listed for veto.

## Audit

Read-only: the deliverable is the chat report, and fixes are applied only when the user asks afterwards.

1. **Resolve and read.** A bare name resolves against `~/.dotfiles/skills/`, `~/.dotfiles/skills-wip/`, then the project's `.claude/skills/`; a path is used as-is. Read every file in the skill's folder — SKILL.md and all its references.
2. **Grade against the bar**, section by section: invocation, description, information hierarchy, splitting, steering, pruning. Done when every section has a verdict — clean ones are declared clean, and every finding names the term it violates.
3. **Report in chat.** Findings ranked by impact, each citing the offending passage (`file:line`) with a concrete rewrite. Close with what already earns its keep.

## Where skills live

- `~/.dotfiles/skills/` — live skills, tracked in git, symlinked into `~/.claude/skills/` (setup.sh recreates the links).
- `~/.dotfiles/skills-wip/` — gitignored drafting area. New skills start here; promotion is a `mv` into `skills/` plus a symlink.
- `<repo>/.claude/skills/` — project-scoped skills.

## Invocation

Two choices, trading different costs:

- A **model-invoked** skill keeps a **description**: the agent can fire it autonomously, other skills can reach it, and you can still type its name. It pays **context load** — the description sits in the window every turn.
- A **user-invoked** skill (`disable-model-invocation: true`) strips the description: only you, typing its name, can fire it, and no other skill can. Zero context load, but it spends **cognitive load** — you are the index that must remember it exists.

Pick model-invocation only when the agent (or another skill) must reach it on its own; a skill that only ever fires by hand should be user-invoked. When user-invoked skills multiply past what you can remember, cure the pile with a **router skill** that names the others and when to reach for each.

## The description

A model-invoked description does two jobs — state what the skill is, and list the **branches** that trigger it. Every word is permanent context load, so it earns even harder pruning than the body:

- Front-load the skill's **leading word** — the description is where it does its invocation work.
- One trigger per branch — synonyms renaming the same branch are **duplication**.
- Keep it to triggers plus any "when another skill needs…" reach clause; identity lives in the body.

## Information hierarchy

A skill's content is **steps** (ordered actions) and **reference** (consulted on demand), mixed freely on a ladder ranked by how immediately the agent needs it: in-skill steps → in-skill reference → disclosed reference behind a **context pointer**. Push too little down and the top bloats; push too much and you hide material the agent needs — that tension is the whole decision.

- Each step ends on a **completion criterion**: checkable (done vs not-done is decidable) and, where it matters, exhaustive ("every modified model accounted for", not "produce a change list"). A demanding criterion drives **legwork**; a vague one invites **premature completion**. All-reference skills carry the bar too ("every rule applied").
- **Progressive disclosure** is the move down the ladder. Branching is the test: inline what every branch needs, push behind a pointer what only some branches reach. The pointer's _wording_, not its target, decides when and how reliably the agent loads it.
- Reference reaches beyond markdown: a spec can be a test suite, a function to port, an HTML mockup, a rubric for verifier agents. Code is the highest-fidelity reference — prefer pointing at it over describing it.
- **Co-location**: keep a concept's definition, rules, and caveats under one heading, so reading one part brings its neighbours with it.

## When to split

**Granularity** — each cut spends one of the two loads, so split only when the cut earns it:

- **By invocation**, when a distinct **leading word** should trigger a skill on its own, or another skill must reach it. The new always-loaded description costs context load; the independent reach has to be worth it.
- **By sequence**, when the steps still ahead (**post-completion steps**) tempt the agent to rush the one in front of it. Keeping them out of view buys more **legwork** on the current task.

## Steering

- **Interfaces over examples.** Worked examples constrain the model to their shape; expressive design steers without fencing — names, parameters, file layout, an enum whose values hint their own use. Keep an example only where format fidelity is itself the point.
- **Leading words.** A compact concept already in the model's pretraining (_lesson_, _fog of war_, _tracer bullets_) that the agent thinks with: repeated as a token, it anchors execution in the body and invocation in the description. Hunt for restatements begging to collapse into one — "fast, deterministic, low-overhead" → a _tight_ loop; "a loop you believe in" → the loop goes _red_.
- **Prompt the positive.** **Negation** names the elephant and makes it more available, not less. State the target behaviour so the banned one is never spoken; keep a prohibition only as a hard guardrail you can't phrase positively, and pair it with what to do instead.

## Pruning

- **Single source of truth** — each meaning lives in one authoritative place, so a behaviour change is a one-place edit.
- **Relevance** — does the line still bear on what the skill does?
- The **no-op** test, sentence by sentence — does this change behaviour versus the default? The test is model-relative, and the default is high: judgement, thoroughness, and standard practice are already there, so most behavioural rules fail it. Delete failing sentences whole rather than trimming words from them.

## Failure modes

For diagnosing a misbehaving skill: **premature completion** (sharpen the completion criterion first — cheap and local; hide post-completion steps by splitting only when the criterion is irreducibly fuzzy _and_ you observe the rush), **duplication** (one meaning, two homes), **sediment** (stale layers settling because adding feels safe and removing feels risky), **sprawl** (too long even when every line is live — the cure is the ladder), **no-op** (paying load to say nothing — fix a weak leading word with a stronger one, not a different technique), **negation** (steering by prohibition).
