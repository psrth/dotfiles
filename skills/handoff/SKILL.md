---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# handoff - prepare all our hard work into a digestible format for another agent.

**Deliverable**: A handoff document summarising the current conversation so that a fresh agent can continue the work. Save to the user's desktop as `handoff-<repo_name>-<session_title>.md`.

## Scope

The user will pass the scope as an argument - in case they forget, ALWAYS ask them first before proceeding with creating a handoff document.

- **PRD:** a handoff that will be used by an agent that's going to do a deep dive of your document, and iterating with the user on the specifications of the implementation before preparing a final PRD for another agent to implement. In this case, you want to surface how the conversation with the user flowed (surfacing intent), any analysis / research we did (evidence, with guidance on how to reproduce / where to find), any conclusions that we came to (okay if we didn't - specify that there were no conclusions and the agent taking over needs to spec that out with the user).
- **Implementation:** usually when the task is lighter / well scoped in this session already. You may interview the user first if there are questions you need answers to first — but after that, prepare a short note for an agent with no context to proceed with implementation — giving them context on the goals, specific way to implement, reference files etc, and a clear deliverable.
- **Session:** the heaviest handoff of all. Almost similar to the /compact skill, where you basically want to be dumping everything that we learnt, explored, or discussed in this session. The user intends to pickup this conversation with another agent with the assumption that it has the exact same context as you do.

## Tips

- Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.
- Redact any sensitive information, such as API keys, passwords, or personally identifiable information.
