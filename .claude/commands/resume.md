---
description: Resumes a project exactly where it was left off after token exhaustion, a closed session, or a context reset, using the live checkpoint instead of re-explaining. Use when the user says resume or continue.
argument-hint: "[--auto]"
---
# Command: /resume

## Purpose
Resume a project exactly where it was left off — after token exhaustion, a closed session, or a context reset. Uses the live checkpoint (`.claude/memory/progress.md`) instead of requiring the user to re-explain anything.

## No delegation (inline by design)

Resuming is a read-and-orient operation: read `.claude/memory/progress.md`, restore the checkpoint, report where things stand. That is **inline by design** — spawning subagents for it is over-delegation (see `.claude/DELEGATION_BRIDGE.md` §6).

Once oriented, hand off to the command that owns the next unit of work (`/new-sprint`, `/review`, `/ship`). **That** is where roles get materialized as real subagents.

## Steps
1. Read `.claude/memory/progress.md` (the live checkpoint) FIRST.
2. Read `.claude/memory/decisions.md`, `lessons_learned.md`, `tech_debt.md`.
3. Read `git log --oneline -10` and `git status --short`.
4. Read `.claude/memory/token_ledger.md` (if present) for the last-known budget.
5. Produce a **"where we are"** summary (≤ 10 lines): stage, sprint, done, in-progress, next 3 actions, blockers, budget.
6. Wait for the user's ✅ before continuing (or proceed if `/resume --auto` was requested).

## Output contract
```
📍 Where we are
- <stage / sprint / status>
- Done: ...
- In progress: ...
- Next: 1) ... 2) ... 3) ...
- Blockers: ...
- Budget: ...

🎯 Proposed next 3 actions:
1. ...
2. ...
3. ...
```

## Success criteria
- The user does not have to re-explain anything.
- The next 3 actions are concrete and immediately executable.

---

<!-- CASF v1.1 · /resume -->
