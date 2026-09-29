# 🤖 CASF — Claude Autonomous Software Framework

> A modular, agent-based framework that turns Claude Code (or any capable AI coding agent) into a coordinated team of 14 senior engineers working on your project autonomously — with checkpoints, memory, and quality gates. Ships as an installable Claude Code plugin.

---

## 📖 Table of Contents

1. [What is CASF?](#-what-is-casf)
2. [Why CASF?](#-why-casf)
3. [Core Concepts](#-core-concepts)
4. [Architecture](#-architecture)
5. [Project Structure](#-project-structure)
6. [Installation & Setup](#-installation--setup)
7. [Publishing & Releases](#-publishing--releases)
8. [The 14 Agents](#-the-14-agents)
9. [Slash Commands](#-slash-commands)
10. [Workflows](#-workflows)
11. [How to Use It](#-how-to-use-it)
12. [Prompt Library](#-prompt-library)
13. [Best Practices](#-best-practices)
14. [FAQ](#-faq)
15. [Roadmap](#-roadmap)
16. [License](#-license)

---

## 🎯 What is CASF?

**CASF (Claude Autonomous Software Framework)** is an opinionated file-based framework that transforms Claude Code into a **coordinated team of specialized AI engineers**. Instead of prompting the AI over and over with the same rules, CASF stores all engineering principles, agent definitions, workflows, and memory in a versioned directory structure that Claude Code reads automatically in every session.

Think of it as **"Rails for AI-assisted development"**: convention over configuration, sensible defaults, and a clear structure that scales from a weekend project to a serious product.

### At a Glance

- 🧠 **14 specialized agents** (orchestrator, context manager, cost accountant, architects, security, QA, DevOps, etc.)
- ⚡ **7 slash commands** (`/start-project`, `/new-sprint`, `/review`, `/ship`, `/recover`, `/resume`, `/status`)
- 🔄 **4 orchestrated workflows** (sprint, quality gate, release, emergency recovery)
- 📚 **6 reusable templates** (ADR, sprint plan, PR, post-mortem, spec)
- 💾 **Persistent memory** (progress checkpoint, decisions, lessons learned, tech debt, token ledger)
- 🐳 **Docker** (framework + generated apps + CASF Studio, all containerized)
- 🖥️ **CASF Studio** (the web UI: prompt → rich spec → materialized app, with live preview + cost accounting)

---

## 🚀 Why CASF?

### The Problem

Working with AI coding assistants at scale exposes recurring pain points:

- ❌ Repeating the same instructions in every session
- ❌ Loss of context between sessions
- ❌ Inconsistent code style across features
- ❌ No memory of past decisions ("why did we choose Redis over Postgres for X?")
- ❌ Feeling like you're the only one holding everything together
- ❌ The AI wanders off-spec and you don't notice until it's too late

### The CASF Solution

| Problem | CASF Answer |
|---|---|
| Repeating rules every session | Rules live in `CLAUDE.md`, loaded automatically |
| Context loss | `.claude/memory/` persists decisions, lessons, tech debt |
| Style inconsistency | Agents enforce specific chapters of `CLAUDE.md` |
| No decision trail | Every architectural choice logged as an ADR |
| Lone wolf feeling | 14 agents delegate work with defined handoffs |
| AI drifting off-spec | Quality gates and Definition of Done block bad output |

---

## 🧭 Core Concepts

### 1. Separation of "how" vs "what"

- **`CLAUDE.md`** = the *how* → rules, principles, engineering standards (project-specific but based on a reusable template)
- **`project.md`** (in CASF Studio) / **`project_spec.md`** (classic) = the *what* → what we're building, always project-specific. The spec is a human-readable Markdown artifact that both the human and the framework can read and edit.

### 2. Agents as personas, not as processes

Each agent is a **Markdown definition** of a role, its triggers, inputs, outputs, and quality gates. When the orchestrator delegates a task, Claude Code takes on that persona and follows the constraints of that agent's file.

### 3. Memory as first-class citizen

`.claude/memory/` holds five persistent files:
- `progress.md` → **live checkpoint** (single source of truth for resume)
- `decisions.md` → every non-trivial choice with rationale
- `lessons_learned.md` → what worked, what didn't
- `tech_debt.md` → tracked debt with severity and plan
- `token_ledger.md` → token consumption and cost ledger

The AI reads these at the start of every session, so knowledge compounds.

### 4. Checkpoints > full autonomy

CASF prefers **bounded autonomy**: the AI can work freely within a task or sprint, but must stop and get approval at defined boundaries. This gives you speed without losing control.

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      YOU (the human)                          │
└───────────────────────────┬──────────────────────────────────┘
                            │ boot prompt
                            ▼
┌──────────────────────────────────────────────────────────────┐
│              project_orchestrator (entry point)               │
│  Reads CLAUDE.md + project_spec.md, plans, delegates          │
└─────┬────────┬────────┬────────┬────────┬────────┬───────────┘
      │        │        │        │        │        │
      ▼        ▼        ▼        ▼        ▼        ▼
  ┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐
  │Chief ││Backend││Front-││ DB   ││Secu- ││ QA   │ ... (10 total)
  │Engr. ││Arch. ││end   ││Arch. ││rity  ││Engr. │
  └──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘
     │       │       │       │       │       │
     └───────┴───────┴───┬───┴───────┴───────┘
                         ▼
              ┌──────────────────────┐
              │  code_reviewer       │
              │  (final gate)        │
              └──────────┬───────────┘
                         ▼
              ┌──────────────────────┐
              │ .claude/memory/      │
              │ (persistent state)   │
              └──────────────────────┘
```

---

## 📁 Project Structure

This is the layout of the CASF repo. Entries marked ★ form the **plugin surface** — the
components Claude Code loads when CASF is installed as a plugin.

```
CASF/
├── .claude-plugin/
│   ├── plugin.json                  # ★ Plugin manifest
│   └── marketplace.json             # ★ Marketplace catalog (plugin@marketplace)
├── agents/                          # ★ 14 subagents (plugin root — NOT .claude/)
│   ├── project_orchestrator.md
│   ├── chief_engineer.md
│   ├── context_manager.md
│   ├── cost_accountant.md
│   ├── backend_architect.md
│   ├── frontend_architect.md
│   ├── database_architect.md
│   ├── security_officer.md
│   ├── qa_engineer.md
│   ├── devops_engineer.md
│   ├── documentation_writer.md
│   ├── code_reviewer.md
│   ├── architecture_reviewer.md
│   └── spec_quality_reviewer.md
├── CLAUDE.md                        # Master config (loaded by Claude Code)
├── README.md
├── LICENSE
├── Dockerfile
├── .claude/
│   ├── README.md                    # Framework internal readme
│   ├── skills/casf-framework/
│   │   └── SKILL.md                 # ★ The constitution, delivered as a skill
│   ├── commands/                    # ★ Slash commands
│   │   ├── start-project.md
│   │   ├── new-sprint.md
│   │   ├── review.md
│   │   ├── ship.md
│   │   ├── recover.md
│   │   └── status.md
│   ├── workflows/                   # Multi-step processes
│   │   ├── sprint_workflow.md
│   │   ├── emergency_recovery.md
│   │   ├── quality_gate.md
│   │   └── release_workflow.md
│   ├── templates/                   # Reusable document templates
│   │   ├── adr.md
│   │   ├── sprint_plan.md
│   │   ├── pr_description.md
│   │   ├── post_mortem.md
│   │   └── spec_template.md
│   ├── prompts/                     # Ready-to-use prompt library
│   │   └── catalog.md
│   ├── CLAUDE.en.md                 # English constitution (not auto-loaded)
│   ├── memory/                      # Persistent context
│   │   ├── progress.md              # live checkpoint (resume)
│   │   ├── decisions.md
│   │   ├── lessons_learned.md
│   │   ├── tech_debt.md
│   │   └── token_ledger.md
│   ├── logs/                        # Session logs (optional)
│   ├── DESIGN_SYSTEM.md             # Visual language for generated apps
│   ├── DESIGN_SYSTEM.en.md
│   ├── PATRON_DE_DISENO.md          # Architecture blueprint
│   └── examples/
│       └── PROJECT_SPEC.md          # Rich spec benchmark (Loyalify)
├── sprints/                         # Sprint plans (created as you go)
├── docs/
│   ├── adr/                         # Architecture Decision Records
│   ├── sprint/                      # Sprint plans (sprint_1_plan.md, …)
│   ├── GITHUB_GUIDE.md              # How the repos were published
│   └── VENTAJAS_COMPETITIVAS.md     # Business & competitive-advantage doc
└── post-mortems/                    # Incident reports
```

---

## ⚙️ Installation & Setup

### Requirements

- **Claude Code** (v2.1.x or later) — or another capable agentic assistant (Cursor, Windsurf, Aider…)
- **Git** for version control
- Node.js 20+ *only if* you want to run CASF Studio (the web UI)

### Option A — Install as a Claude Code plugin (recommended)

CASF ships as a plugin: **14 subagents**, **7 slash commands**, and the constitution delivered
as a skill (a plugin's `CLAUDE.md` is not loaded as context, so the operating rules ship as
`skills/casf-framework/SKILL.md`).

```bash
claude plugin marketplace add ZoodiacR/CASF
claude plugin install casf@casf
```

Or from inside a Claude Code session:

```
/plugin marketplace add ZoodiacR/CASF
/plugin install casf@casf
```

Confirm the components actually loaded:

```bash
claude plugin details casf
```

You should see `Skills (8)` and `Agents (14)`. Once installed, the agents are available in
every project — invoke them as `@casf:code-reviewer`, `@casf:security-officer`, and so on.

### Option B — Clone it and use it as a project

```bash
git clone https://github.com/ZoodiacR/CASF.git
cd CASF
```

Opening that folder in Claude Code loads `CLAUDE.md` automatically, so the constitution and
the `.claude/` conventions apply to that project. This is the mode CASF Studio uses: it runs
headless Claude Code sessions with the repo as the working directory.

> Want the framework's subagents available to Claude Code itself? Install the plugin
> (Option A) — subagents live in the plugin's root `agents/` directory, not in `.claude/`.
> See [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json).

### Next step — get a spec

- Run `/start-project` for the bounded discovery interview, **or**
- Write `project_spec.md` yourself using [`.claude/templates/spec_template.md`](.claude/templates/spec_template.md).

Then let the orchestrator build it in slices, with the adversarial review loop. 🚀

---

## 📦 Publishing & Releases

CASF is **its own marketplace**: `.claude-plugin/plugin.json` is the plugin manifest and
`.claude-plugin/marketplace.json` is the catalog, with a single entry whose `source` is `"./"` —
the repository root. That is the pattern the docs prescribe for publishing from the plugin's own
repository, and per [Publish and distribute a plugin](https://code.claude.com/docs/en/plugins/publish.md):
*"Once the file is in the repository, the plugin is published, with no submission form."*

So **there is nothing to submit**: the plugin became installable the moment the repository went
public. Reach is the only thing left to decide (see *Reach a wider audience* below).

### One-line install (Claude Code v2.1.275+)

```
/plugin install casf --marketplace ZoodiacR/CASF
```

### Pre-release checklist

Run both before every release, and in CI:

```bash
claude plugin validate --strict .   # --strict also fails on warnings
claude plugin details casf          # expect: Skills (8) · Agents (14)
```

| Check | Why it matters |
|---|---|
| **`version` bumped** in `plugin.json` | It is the plugin's **cache key**. Push commits without bumping it and `claude plugin update` answers *"is already at the latest version"* — users keep the old copy |
| **`name` unchanged** | A renamed plugin is a *different* plugin to every existing install (`Plugin "…" not found in marketplace`). Set `displayName` for the label instead |
| `description` / `author` / `homepage` / `repository` set | What users see in `/plugin` and on the marketplace. `homepage` must parse as a URL |
| `validate --strict` clean | Unknown manifest fields and a missing `version` are warnings here and failures at the submission portal |

> **Instead of bumping `version`,** you can omit it: Claude Code then versions the plugin by commit
> SHA. Pick one and stay consistent.

### Tag a release

Tags are only needed when another plugin declares a version range on CASF. `claude plugin tag`
validates that `plugin.json` and the enclosing marketplace entry agree on the version.

```bash
claude plugin tag --push        # creates the casf--v1.0.0 git tag
```

### Reach a wider audience

| Route | Who can install | What it takes |
|---|---|---|
| **This marketplace** — current | Anyone who can reach this repo | Nothing. Already live |
| **[Anthropic's directory](https://code.claude.com/docs/en/plugins/publish.md)** | People browsing claude.ai and Cowork | A **paid claude.ai plan**, submitting from [claude.ai/directory/manage](https://claude.ai/directory/manage) |

> Two caveats before submitting there: `claude-plugins-official` does **not** accept submissions
> through that portal, and **agents and commands are Claude Code-only** — they do not load on
> claude.ai or in Cowork. What travels through the directory from CASF are the **skills**.

### How users get updates

The install id is `casf@casf` — that is `plugin@marketplace`. Users pull new versions with:

```bash
claude plugin update casf@casf
```

Auto-update is **off by default** for a third-party marketplace; each user turns it on for theirs.

---

## 👥 The 14 Agents

| Agent | Role | Enforces |
|---|---|---|
| **project_orchestrator** | Top-level coordinator, entry point, delegates work | Everything |
| **context_manager** | Session continuity, live progress checkpoint, resume | Context Management (Ch. 5) |
| **cost_accountant** | Token & cost tracking, budget alerts, ledger | Cost/observability |
| **chief_engineer** | Senior tech lead, resolves conflicts, signs ADRs | Architecture standards |
| **backend_architect** | APIs, services, data flow, background jobs | Backend rules (Ch. 10) |
| **frontend_architect** | UI architecture, components, state, a11y | Frontend rules (Ch. 11) |
| **database_architect** | Schema, migrations, indexes, query perf | DB rules (Ch. 12) |
| **security_officer** | Threat modeling, auth, secrets, OWASP | Security rules (Ch. 13) |
| **qa_engineer** | Test strategy, coverage, regression | Testing rules (Ch. 14) |
| **devops_engineer** | CI/CD, deploys, observability, rollback | Deployment rules |
| **documentation_writer** | README, ADRs, API docs, changelogs | Documentation rules (Ch. 15) |
| **code_reviewer** | Final PR gate, blocks bad merges | Definition of Done |
| **architecture_reviewer** | Adversarial post-implementation review, refactor vs hardening | Ch. 26 (evidence mode) |
| **spec_quality_reviewer** | Scores generated specs against the rubric before any build | Spec quality gate |

---

## ⚡ Slash Commands

Trigger these by asking the AI to "execute /command-name". Each command is a defined workflow with agents, steps, and success criteria.

| Command | Purpose |
|---|---|
| `/start-project` | Bootstraps a new project via a bounded discovery interview |
| `/new-sprint` | Plans and executes a full sprint |
| `/review` | Full code + architecture review of a changeset |
| `/ship` | Runs quality gates and releases to target environment |
| `/recover` | Emergency incident response (triage → contain → rollback → post-mortem) |
| `/resume` | Resume a project exactly where it left off (reads progress.md) |
| `/status` | Prints project dashboard: sprint, blockers, debt, decisions |

---

## 🔄 Workflows

| Workflow | Trigger | Outcome |
|---|---|---|
| **sprint_workflow** | Start of a sprint | Plan → execute → retrospective |
| **quality_gate** | Before merge/deploy | Automated + manual checks pass |
| **release_workflow** | On `/ship` | Version bump → tag → deploy → smoke test |
| **emergency_recovery** | Incident detected | Contain → rollback → post-mortem |

---

## 🖥️ CASF Studio (the web product)

CASF Studio is the companion web app that turns the framework into a product: a chat interface where the user writes a prompt, the LLM converts it into a rich `ProjectSpec` (`project.md`), and the **materializer** turns that spec into a working app — with live preview, cost accounting, and a sprint workflow all visible in the UI.

```
prompt → [LLM] → project.md (rich spec)
            │
            ▼
   design decisions (interactive or hands-free)
            │
            ▼
   materializer → full app (CRUD + backend + auth + i18n + Docker)
            │
            ▼
   live preview iframe + token/cost dashboard + memory
```

Key Studio features:
- **Rich specs from brief prompts** (enrichment pass guarantees commercial quality)
- **Interactive design decisions** (currency/theme/language/auth) or **hands-free** mode
- **Editable spec** — the `project.md` can be adjusted by natural-language feedback *or* edited directly
- **Token & cost accounting** per LLM, with admin/user role visibility
- **Persistent memory** (`memory.md` + `state.json`) with a "resume" button
- **Docs tab** that renders the framework's own artifacts (progress, sprints, blueprint) live

## 🐳 Docker

Everything ships containerized:

| Target | Dockerfile | Notes |
|---|---|---|
| **CASF framework** | `Dockerfile` | Packages `.claude/` + `CLAUDE.md` as a mountable volume |
| **CASF Studio** | `backend/Dockerfile` + `frontend/Dockerfile` + `docker-compose.yml` | nginx proxies `/api` → backend |
| **Generated apps** | auto-generated in `materializer.ts` | full-stack → Node+Postgres; static → nginx |

---

## 🎮 How to Use It

### Typical daily flow

```
1. Open Claude Code in your project folder
   → It auto-loads CLAUDE.md

2. Paste a boot prompt (see Prompt Library)
   → Claude activates as project_orchestrator

3. Give it a mission
   → e.g. "Execute /new-sprint with goal: user auth"

4. Approve checkpoints
   → Plan approved → code written → tests written → reviewed

5. Commit and iterate
   → .claude/memory/ updated automatically
```

### Execution modes

Choose based on your comfort level:

| Mode | Autonomy | Checkpoints | When to use |
|---|---|---|---|
| **Manual** | Low | Every step | Learning the framework, high-risk changes |
| **Checkpoints** | Medium | Phase boundaries | **Default recommended mode** |
| **Autonomous** | High | Only on blockers | Mature projects, well-tested framework |

---

## 📚 Prompt Library

All prompts below are ready to copy-paste. The full set lives in `.claude/prompts/catalog.md`.

---

### 🌟 Prompt 0 — CASF Filler Prompt (first-time setup)

Use this **once**, right after running the bootstrap script, to have the AI fill every stub file.
