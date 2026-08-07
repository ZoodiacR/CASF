# 📚 CASF — Prompt Catalog

> Curated collection of ready-to-use prompts for executing projects with the **CASF (Claude Autonomous Software Framework)**.
>
> Each prompt is designed for a specific situation. Pick the one that matches your context, copy it, and paste it as your first message to Claude Code (or any capable AI coding agent).

---

## 📖 Table of Contents

1. [How to Use This Catalog](#-how-to-use-this-catalog)
2. [Prompt Selection Guide](#-prompt-selection-guide)
3. [🔥 Master Prompts — Full Project Execution](#-master-prompts--full-project-execution)
   - [Version A — Autonomous with Checkpoints (RECOMMENDED)](#version-a--autonomous-with-checkpoints-recommended)
   - [Version B — Ultra Short](#version-b--ultra-short)
   - [Version C — Fully Autonomous (Hands-Off Mode)](#version-c--fully-autonomous-hands-off-mode)
   - [Version D — Resume an Existing Project](#version-d--resume-an-existing-project)
4. [Tips & Best Practices](#-tips--best-practices)
5. [Troubleshooting](#-troubleshooting)

---

## 🎯 How to Use This Catalog

### Prerequisites

Before using any of these prompts, you must have:

- ✅ A `project_spec.md` in the root of your project describing **what** you want to build.
- ✅ Claude Code (or equivalent) open in the project's root folder.

### How it works

1. **Pick the prompt** that matches your situation (see [Selection Guide](#-prompt-selection-guide)).
2. **Copy the entire prompt block** (everything inside the `text` code block).
3. **Paste it as your first message** to Claude Code.
4. **Follow the checkpoints** — approve (✅) or redirect as needed.

### The core idea

You don't need long prompts. All the intelligence is already stored in:

- `CLAUDE.md` → the *how* (rules, principles, standards)
- `project_spec.md` → the *what* (project definition)
- `.claude/` → the *team* (agents, workflows, memory)

The prompts below are just **ignition keys**. They tell the AI: *"activate the framework, take the role of the orchestrator, and go."*

---

## 🧭 Prompt Selection Guide

Use this decision tree to pick the right prompt:

```
Are you starting fresh or resuming?
│
├─ 🆕 Starting a project
│   │
│   ├─ How much do you trust your framework?
│   │
│   ├─ Just filled it, unsure → Version A (Checkpoints) ⭐ RECOMMENDED
│   ├─ Solid and battle-tested → Version B (Ultra Short)
│   └─ Extensively tested, want hands-off → Version C (Fully Autonomous)
│
└─ 🔁 Resuming a session → Version D (Resume)
```

### Quick comparison table

| Version | Autonomy | Checkpoints | Best for | Risk Level |
|---------|----------|-------------|----------|------------|
| **A** — Checkpoints ⭐ | Medium | Multiple | Default use, most projects | 🟢 Low |
| **B** — Ultra Short | Medium-High | Minimal | Trusted framework, small projects | 🟡 Medium |
| **C** — Autonomous | Very High | Only on blockers | Mature framework, willing to trust AI | 🔴 High |
| **D** — Resume | Medium | Post-boot check | Continuing prior work | 🟢 Low |

---

## 🔥 Master Prompts — Full Project Execution

---

### Version A — Autonomous with Checkpoints (RECOMMENDED)

#### 🎯 When to use it

**This is the default prompt.** Use it in ~80% of cases:

- ✅ You just finished setting up CASF and want to start building.
- ✅ You want the AI to work efficiently but not go rogue.
- ✅ You value being consulted at key architectural moments.
- ✅ You're working on a serious project where mistakes cost time/money.
- ✅ You're still learning how your framework behaves in practice.

#### ⚙️ How it behaves

- Reads the entire framework at boot.
- Takes on the `project_orchestrator` role.
- Works autonomously **within** each sprint (delegates, writes code, runs tests, commits).
- **Stops for approval** at 5 defined checkpoints (see prompt).
- First output is always a summary + roadmap + optional questions.

#### 📋 The prompt

```text
You are activating the CASF framework for autonomous project execution.

## Boot sequence (mandatory, in order)

1. Read CLAUDE.md in full — this is your operating manual.
2. Read project_spec.md in full — this is what we're building.
3. Read every file under .claude/agents/, .claude/commands/,
   .claude/workflows/, and .claude/templates/.
4. Read .claude/memory/ to load prior context (may be empty on first run).

## Activation

Assume the role of **project_orchestrator** as defined in
.claude/agents/project_orchestrator.md.

From this point on, you coordinate all other agents according to the
delegation rules in CLAUDE.md Chapter 8.

## Mission

Build the project described in project_spec.md, end to end, following:
- The engineering principles in CLAUDE.md
- The sprint workflow in .claude/workflows/sprint_workflow.md
- The Definition of Done in CLAUDE.md Chapter 20
- The quality gates in CLAUDE.md Chapter 21

## Execution mode: AUTONOMOUS WITH CHECKPOINTS

You may work autonomously WITHIN a sprint.
You MUST stop and wait for my ✅ at these checkpoints:

- ✋ After boot sequence → show me your understanding summary.
- ✋ After producing the full sprint plan (before writing code).
- ✋ At the end of every sprint (before starting the next).
- ✋ Before any destructive action (delete, migrate, rewrite > 200 lines).
- ✋ Before /ship.

Within a sprint, you may:
- Delegate freely across agents.
- Create/edit files.
- Run tests.
- Update .claude/memory/ as decisions are made.
- Commit with conventional commit messages.

## First action

Execute the boot sequence and produce:

1. A 15-line summary of what you understood from CLAUDE.md + project_spec.md.
2. The proposed sprint roadmap (Sprint 0 → Sprint N with 1-line goals each).
3. A list of clarifying questions ONLY if strictly necessary
   (max 3 questions — do not ask what you can decide yourself).

Then STOP and wait for my ✅.
```

#### ✅ What to expect after pasting

The AI will produce something like:

```
📖 Understanding summary
Your project is a [X] built with [Y stack]. Key requirements are [...].
The main technical challenges are [...]. RAG will be handled via [...].

🗺️ Proposed roadmap
- Sprint 0: Setup, dependencies, skeleton
- Sprint 1: Core feature A
- Sprint 2: Core feature B
- Sprint 3: Integration + testing
- Sprint 4: Polish + release

❓ Clarifying questions (2)
1. Do you prefer [X] or [Y] for [Z]?
2. Should we support [option]?

⏸️  Waiting for your ✅ to proceed with Sprint 0 planning.
```

Reply with `✅` to proceed, or clarify/redirect if needed.

---

### Version B — Ultra Short

#### 🎯 When to use it

Use it when:

- ✅ You've used CASF before and trust your `CLAUDE.md` fully.
- ✅ Your `project_spec.md` is clear, unambiguous, and complete.
- ✅ You want minimal ceremony — just build.
- ✅ The project is small enough that heavy checkpointing is overkill.
- ✅ You've verified the framework health check passes cleanly.

**Do NOT use it if:**
- ❌ It's your first project with CASF.
- ❌ Your `project_spec.md` has ambiguities.
- ❌ The project is high-stakes (production system, client work, etc.).

#### ⚙️ How it behaves

Same as Version A conceptually, but with far less instruction overhead. Relies entirely on the framework files being complete and correct.

#### 📋 The prompt

```text
Activate CASF. Read CLAUDE.md, project_spec.md, and the entire .claude/ tree.

Assume the role of project_orchestrator and build the project end-to-end
following the framework rules.

Stop for approval at:
- End of boot (show understanding + roadmap)
- End of each sprint
- Before /ship

Begin now.
```

#### ✅ What to expect

Similar first output to Version A, but more concise. The AI infers all the details from your framework files instead of being explicitly told.

> 💡 **Pro tip:** If Version B produces lower-quality output than Version A on the same project, it means your `CLAUDE.md` or agent files are **underdeveloped**. Fall back to Version A and consider running the CASF Filler Prompt again on weak files.

---

### Version C — Fully Autonomous (Hands-Off Mode)

#### 🎯 When to use it

⚠️ **Advanced users only.** Use this prompt when:

- ✅ You've completed 3+ projects with CASF successfully.
- ✅ Your framework is battle-tested and produces reliable output.
- ✅ You want to walk away and check back later.
- ✅ The project is well-scoped with an unambiguous `project_spec.md`.
- ✅ You accept the AI may make judgment calls without asking.
- ✅ You have git history as a safety net for rollback.

**Do NOT use it for:**
- ❌ Production systems without staging environments.
- ❌ Projects with ambiguous requirements.
- ❌ Codebases containing sensitive data or credentials.
- ❌ Any situation where an irreversible mistake would be costly.

#### ⚙️ How it behaves

- Works completely on its own from boot to delivery.
- Only stops on **true blockers** (ambiguity, quality gate failure, destructive action).
- Logs every decision to memory so you can audit later.
- Produces a `DELIVERY_REPORT.md` at the end summarizing everything done.

#### 🛡️ Safety guardrails

Even in this mode, the AI will stop for:
- 🚫 Irreversible destructive actions (deleting data, force-pushing to main, dropping tables).
- 🚫 Truly ambiguous spec requirements it cannot resolve.
- 🚫 Quality gate failures no agent can fix autonomously.

#### 📋 The prompt

```text
Activate CASF in fully autonomous mode.

Boot: read CLAUDE.md, project_spec.md, and all files under .claude/.
Role: project_orchestrator.
Goal: deliver project_spec.md end-to-end.

Rules:
- Do not ask for approval unless you hit a true blocker.
- Stop only for: destructive irreversible actions, ambiguous spec requirements,
  or when a quality gate fails and cannot be resolved by an agent.
- Log every decision to .claude/memory/decisions.md.
- Commit after each completed task with conventional commits.
- At the end, produce a final delivery report at ./DELIVERY_REPORT.md.

Begin the boot sequence now.
```

#### ✅ What to expect

You'll come back to a project that (ideally) is fully built, with:
- Complete implementation matching `project_spec.md`.
- Comprehensive git history with conventional commits.
- A `DELIVERY_REPORT.md` explaining architecture choices, tradeoffs, and next steps.
- Populated `.claude/memory/` with decisions and lessons.
- Tests passing and quality gates green.

> ⚠️ **Reality check:** Even the best framework won't produce perfect autonomous output. Budget time to review, iterate, and fix. Version C is about **speed to first draft**, not about zero human involvement.

---

### Version D — Resume an Existing Project

#### 🎯 When to use it

Use this **every time** you return to a project after closing Claude Code:

- ✅ You closed the session yesterday / last week / last month.
- ✅ You want to reload context without re-explaining everything.
- ✅ You're switching between projects and need to "swap in".
- ✅ You want a status check before continuing.
- ✅ Someone else worked on the project and you need to catch up.

This is arguably the **most important prompt** in the catalog — the one you'll use most often over the lifetime of a project.

#### ⚙️ How it behaves

- Reads the framework as usual.
- **Also reads all memory files** to restore prior context.
- **Reads the latest sprint file** to know where work was paused.
- **Checks git log** to see recent activity.
- Produces a "where we are" summary before proposing next actions.

#### 📋 The prompt

```text
Resume CASF execution.

Boot:
1. Read CLAUDE.md and project_spec.md.
2. Read all of .claude/memory/ — this is your prior context.
3. Read the latest file in ./sprints/ to know where we left off.
4. Read git log --oneline -20 to see recent activity.

Assume the role of project_orchestrator.

Produce:
- A 10-line "where we are" summary.
- The next 3 actions you propose.
- Any blockers detected.

Then wait for my ✅ before continuing.
```

#### ✅ What to expect

```
📍 Where we are
- Currently in Sprint 3 (Feature: user authentication)
- 4/6 tasks completed. Pending: refresh token flow + tests.
- Last commit: "feat(auth): add JWT middleware" (2 days ago)
- No unresolved blockers in .claude/memory/tech_debt.md.
- Latest decision: "Adopted argon2 for password hashing" (see decisions.md #12)

🎯 Next 3 actions
1. Implement refresh token endpoint (backend_architect + security_officer).
2. Write unit tests for token rotation (qa_engineer).
3. Update API docs to include new endpoints (documentation_writer).

⚠️  Blockers
None detected.

⏸️  Waiting for your ✅ to proceed with action 1.
```

Reply `✅` to continue, or redirect with something like *"Let's skip to action 3 first"*.

---

## 💡 Tips & Best Practices

### Choose the right prompt

- **First time using CASF?** → Version A, always.
- **Small side project?** → Version B is fine.
- **Weekend hackathon?** → Try Version C for speed.
- **Coming back after a break?** → Version D, no exceptions.

### Combine prompts across a session

A typical project lifecycle might use multiple prompts in sequence:

```
Day 1  → Version A (start project)
Day 2  → Version D (resume) + task-specific prompts
Day 3  → Version D (resume) + /review prompt
Day 4  → Version D (resume) + /ship prompt
Week 2 → Version A again for the next major feature
```

### Save your favorites

Once you customize a prompt (e.g. add your team's Slack channel for notifications, or specific coding style overrides), save it as a variant in `.claude/prompts/`:

```
.claude/prompts/
├── prompt_catalog.md          ← this file (canonical prompts)
├── my_start_prompt.md         ← your customized version
└── my_resume_prompt.md        ← your resume flavor
```

### Adapt to your model

- **Claude Opus / Sonnet 4.5+**: All 4 versions work well.
- **Claude Haiku or smaller models**: Prefer Version A — the extra structure helps weaker models stay on track.
- **Other agents (Cursor, Windsurf, etc.)**: Version A is safest since it's more explicit about the workflow.

### Track prompt effectiveness

Every few sprints, note in `.claude/memory/lessons_learned.md`:
- Which prompts worked well.
- Which produced weak or off-spec output.
- Any modifications you made that helped.

This is how your framework gets **smarter over time**.

---

## 🚑 Troubleshooting

### The AI ignores checkpoints and just plows ahead

**Cause:** Weak agent definitions or the AI is overconfident.

**Fix:**
1. Run the framework health check (see `README.md` prompt library).
2. Reinforce checkpoints in the prompt (add `MANDATORY:` before each ✋ line).
3. Fall back to Version A if using B or C.

### The AI asks too many clarifying questions

**Cause:** Your `project_spec.md` is ambiguous.

**Fix:**
1. Answer them once, then update `project_spec.md` with the clarifications.
2. Restart with the updated spec — questions should drop drastically.

### The AI produces low-quality output

**Cause:** Framework files (agents, CLAUDE.md) are underdeveloped.

**Fix:**
1. Re-run the CASF Filler Prompt targeting weak files.
2. Manually expand the specific agent/chapter that governs the weak output.
3. Add examples to the relevant agent's "Example Interaction" section.

### Resume prompt (Version D) doesn't remember context

**Cause:** `.claude/memory/` is empty or was not updated in prior sessions.

**Fix:**
1. Instruct the AI: *"Before proceeding, populate `.claude/memory/decisions.md` with everything you can infer from the current codebase and git history."*
2. Going forward, enforce memory updates in the sprint workflow.

### Version C never stops and does something unexpected

**Cause:** You underestimated the ambiguity or the framework has gaps.

**Fix:**
1. **Stop the session immediately** with Ctrl+C or by interrupting.
2. Run `git reset --hard <last known good commit>` if needed.
3. Downgrade to Version A for the next attempt.
4. Add explicit rules to `CLAUDE.md` covering the scenario that went wrong.

---

## 📎 Related Files

- `README.md` — Full framework documentation.
- `CLAUDE.md` — Master configuration (rules the AI follows).
- `project_spec.md` — What you're building.
- `.claude/agents/project_orchestrator.md` — Definition of the entry-point agent.
- `.claude/commands/` — Slash commands referenced by the prompts.
- `.claude/memory/` — Persistent context read by every boot sequence.

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Initial | Four master prompts (A/B/C/D) with usage guidance. |

---

<p align="center">
  <strong>💡 Remember: the framework does the work. The prompt just turns the key.</strong>
</p>

<!-- CASF v1.0 · prompt_catalog.md -->