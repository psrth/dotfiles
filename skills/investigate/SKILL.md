---
name: investigate
description: Lock down the scope, then fan out subagents to explore hypotheseses until the root cause is proven. Use when the user invokes /investigate, says debug/diagnose, or reports something broken, throwing, failing, flaky, or slow.
---

# Investigate: Surface -> Hypothesis -> Proven Root Cause

- The deliverable is a **diagnosis**: root cause with the evidence chain that proves it, plus a proposed fix.
- Code is never edited during an investigation (this instruction must be relayed to subagents as well!) — throwaway harnesses and probes live in scratch, tagged, and are cleaned up at the end.
- Fix only when asked.

## Steps

1. **Surface the scope**

- The user has provided an issue, discrepancy, data point, or general concern. We want to use the available tooling to validate or recreate the exact scope of what's being raised for investigation.
- This can also involve follow-up questions for the user - eg if unclear what the error, expected behavior, scope is — you can ask the user. Then go to find and validate / recreate it.
- Leverage all the tools at your disposals, using parallel subagents: whether its MCP tools, code exploration, GitHub history, etc.
- Expected output: Exact symptom, onset time, frequency (always / intermittent / once), scope (one user / region / everyone), and what changed around onset — deploys, migrations, config, dependencies, traffic. "When did this last work?" is the highest-value question in debugging: check deploy history and `git log` around onset before reading any code.

2. **Hypothesis List**

- Make a list of and go through all the code snippets that may be related to this issue.
- Unless a bug / issue is immediately obvious — in which case surface it to the user immediately!! — kick of as many subagents to explore different hypotheseses you may have.
- The scope of a hypothesis can be wide, and the subagents can internally explore multiple theories if they may stem from the same code snippet.

3. **Confirmation**

- Once a subagent has reported something, and YOU have independently verified it to be the cause, confirm the issue to the user.
- The bar: you can narrate the full causal chain from cause to symptom with evidence at each link.

4. **Report (in the chat session itself)**

```markdown
## Diagnosis: <one-line root cause>

**Scope:**

- Human: what was observed - simple, easy human explanation
- Technical: what was observed - from a technical standpoint (name modules, code snippets, etc)
- Observed: if possible, provide example(s)
  **Root cause:**
- Human: what was the issue — simple, easy human explanation
- Technical: the defect at file:line / config / data level
  **Evidence chain:** cause → … → symptom, proof at each link
  **Ruled out:** hypothesis — the evidence that killed it (one line each)
  **Blast radius:** what else this defect affects
  **Proposed fix:** the change that fixes it + how to verify
```
