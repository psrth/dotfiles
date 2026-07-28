---
name: monitor
description: Stand up and run a standing watch over live signals. Use for /monitor plan (pre-merge signal scoping), /monitor start (stand up the watch), when the user wants a deploy, metric, queue, or job watched, asks about a running monitor, or says stand down.
---

# monitor — standing watch with durable state

Not a dashboard tour. A monitor watches the handful of signals a specific concern could break, against captured baselines, with all state on disk — the conversation can die; the monitor must not.

Two entry points into one pipeline: `plan` (step 1–2, best run pre-merge) and `start` (step 3 onward; bare `/monitor` or natural language means start). start without a `plan.md` runs plan first — the interview works post-merge too, instrumentation gaps just cost more to close.

## The monitor directory

Everything lives in `<cwd>/.monitors/<name>/` (gitignored — add the entry if missing):

- `plan.md` — what's watched and why, the signals table (name, source, query, baseline, green/yellow/red thresholds), cadence, and the pre-agreed action on red. The human contract: "I'm back, where are we?" is answerable from here plus the log tail.
- `capture.sh` — standalone: one run appends one timestamped JSONL reading of every signal to `log.jsonl`. Baseline, agent loop, and watcher all go through it, so every reading is like-for-like by construction.
- `watch.sh` — the programmatic watcher: loops over `log.jsonl`, evaluates fresh readings against thresholds, and exits non-zero on breach — or on staleness, since a capture pipeline that died is itself a red. Thresholds live in exactly one machine-readable home that watch.sh reads; plan.md points at it rather than restating numbers.
- `log.jsonl` — append-only readings, the source of truth both loops read.

## `plan` — scope the watch, pre-merge

1. **Define signals with the user.** From the blast radius of the change (diff/PR) or concern, 3–7 signals — each with source (API call, MCP tool, SQL, curl, log grep) and the exact query. At least one business or parity signal — code that returns 200 while doing the wrong thing is the failure mode that matters. Done when the user confirms the signal table, written to plan.md.
2. **Close instrumentation gaps.** For each signal, verify its emitter exists — the log line, metric, or endpoint the query reads. Where the change is unobservable, propose the concrete addition to the PR before merge: a log line here, a counter there, quoted and placed. Done when every signal has an emitter shipped or the gap is explicitly waived in plan.md.

## `start` — stand up the watch

3. **Scaffold capture and baseline through it.** Write the directory, capture.sh first: the baselines are its first readings (plus same-time-yesterday, ad hoc, for cyclical metrics). Record them in plan.md — a number without a baseline is not a signal.
4. **Set thresholds and prove the watcher.** Green/yellow/red per signal, set against the baseline and agreed with the user along with the action on red; then write watch.sh. Done when it has passed on live data and tripped on a synthetic breach.
5. **Automate the dumps.** Default: the agent loop runs capture.sh each tick. When capture must be tighter than the loop cadence or outlive the session, set up cron/launchd with the user — but an MCP-sourced signal can only be captured by the agent, so keep those in the loop and note it in plan.md.
6. **Run both loops.** watch.sh in the background, where its exit wakes the agent. The agent loop (`/loop` or scheduled wake-ups, never a blocking foreground sleep) each tick: run capture if agent-driven, read the fresh readings, emit one terse line per signal — `🟢 checkout p95 412ms (base 390ms)` — and tighten cadence on yellow. No essays while green.

## On wake — breach or staleness

Investigate evidence-first: sample the errors, split by version/region, find the discriminating fact. Report in chat with the evidence and send a push notification so it reaches the user AFK. Watching is read-only — remediation happens only per plan.md's pre-agreed action or an explicit ask. Restart watch.sh after handling.

## Stand down — user-gated

When green has held long enough that the watch stops earning its keep, recommend stand-down with the evidence and keep watching. Only a user yes triggers teardown: kill watch.sh, remove any cron/launchd entries, one final capture, then the summary — per signal, baseline → range observed → verdict, plus anything anomalous-but-benign. The directory stays as the record.

## Rules

- Compare like with like — same window length, same filters as the baseline query.
- A second change shipping mid-watch is called out and re-baselined.
- Resume ("what's the state?") is answered from plan.md plus the log tail, then dead loops are restarted.
