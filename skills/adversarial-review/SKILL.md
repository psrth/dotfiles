---
name: adversarial-review
description: Two-model adversarial code review — a Claude reviewer and the Codex CLI review the same diff independently, findings are merged, deduped, and adversarially verified, then reported as Critical/Minor/Comment. Invoke with /adversarial-review on a diff, branch, or PR.
disable-model-invocation: true
---

# adversarial-review — Claude + Codex, verified findings only

Two independent reviewers see the same diff; neither sees the other's findings. Everything they raise is then verified against the actual code before it reaches the user. The output is findings you can act on, not a pile of maybes.

## 0 — Scope the diff

Resolve what's being reviewed, in this order: explicit PR number (`gh pr diff <n>`), explicit ref/range, current branch vs its base (`git diff <base>...HEAD`), else uncommitted work (`git diff HEAD`). Write the diff to a scratch file. Skim it once; if anything about intent is genuinely unanswerable from code and context (e.g. "is this behavior change deliberate?"), ask the user those clarifying questions now — then don't ask again.

## 1 — Fan out (parallel, independent)

Both reviewers get the same review prompt:

> Go through the changes in this diff, along with the surrounding code and any external references to this code snippet.
>
> **1. Explain this diff** — the changes introduced with relevant code snippets, logical impact, potential business impact.
>
> **2. Code review** — carefully find any and all bugs, potential oversights, any flag you may have at all. Group into Critical, Minor, Comment. Review call sites that reference this code and dependent code upstream and downstream — a thorough review.

- **Claude reviewer:** an Agent (general-purpose) pointed at the repo with the diff path and the prompt. It must read surrounding code and call sites, not just the diff.
- **Codex reviewer:** `codex exec review --base <base> -o <scratch>/codex-review.md "<prompt>"` from the repo root (`--uncommitted` when reviewing uncommitted work; plain `codex exec -s read-only` with the diff file as context when reviewing a PR that isn't checked out). Run in the background; it takes minutes.

## 2 — Merge and verify

1. Collect both reports. Dedupe findings that point at the same defect; keep the clearer writeup and tag it `both`.
2. **Verify every finding yourself against the code** — open the file, trace the call path, check whether the claimed input can actually occur. Verdict per finding: CONFIRMED (with the failing scenario) or REJECTED (with why — reviewer hallucinations get dropped, not softened into Comments).
3. Where the reviewers disagree on severity or one flags what the other blessed, investigate that spot extra hard — disagreement is signal.

## 3 — Report

1. **Explain the diff** — synthesized once (not per-reviewer): changes with snippets, logical impact, business impact.
2. **Findings** — grouped **Critical / Minor / Comment**, each with: `file:line`, one-sentence defect, the concrete failing scenario, which reviewer(s) found it (`claude` / `codex` / `both`), and the verification verdict. Then a short "Rejected in verification" list (finding + why) so the user can audit the filter.
3. End with a verdict line: ship / ship after criticals / needs rework.

Reviewing is read-only — never fix findings in the same run unless the user then asks.
