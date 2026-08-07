# 🤖 CASF — Claude Autonomous Software Framework

> A modular, agent-based framework that turns Claude Code (or any capable AI coding agent) into a coordinated team of 10 senior engineers working on your project autonomously — with checkpoints, memory, and quality gates.

---

## 📖 Table of Contents

1. [What is CASF?](#-what-is-casf)
2. [Why CASF?](#-why-casf)
3. [Core Concepts](#-core-concepts)
4. [Architecture](#-architecture)
5. [Project Structure](#-project-structure)
6. [Installation & Setup](#-installation--setup)
7. [The 10 Agents](#-the-10-agents)
8. [Slash Commands](#-slash-commands)
9. [Workflows](#-workflows)
10. [How to Use It](#-how-to-use-it)
11. [Prompt Library](#-prompt-library)
12. [Best Practices](#-best-practices)
13. [FAQ](#-faq)
14. [Roadmap](#-roadmap)
15. [License](#-license)

---

## 🎯 What is CASF?

**CASF (Claude Autonomous Software Framework)** is an opinionated file-based framework that transforms Claude Code into a **coordinated team of specialized AI engineers**. Instead of prompting the AI over and over with the same rules, CASF stores all engineering principles, agent definitions, workflows, and memory in a versioned directory structure that Claude Code reads automatically in every session.

Think of it as **"Rails for AI-assisted development"**: convention over configuration, sensible defaults, and a clear structure that scales from a weekend project to a serious product.

### At a Glance

- 🧠 **10 specialized agents** (orchestrator, architects, security, QA, DevOps, etc.)
- ⚡ **6 slash commands** (`/start-project`, `/new-sprint`, `/review`, `/ship`, `/recover`, `/status`)
- 🔄 **4 orchestrated workflows** (sprint, quality gate, release, emergency recovery)
- 📚 **5 reusable templates** (ADR, sprint plan, PR, post-mortem, spec)
- 💾 **Persistent memory** (decisions, lessons learned, tech debt)
- 🎛️ **3 execution modes** (fully autonomous, checkpoints, manual)

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
| Lone wolf feeling | 10 agents delegate work with defined handoffs |
| AI drifting off-spec | Quality gates and Definition of Done block bad output |

---

## 🧭 Core Concepts

### 1. Separation of "how" vs "what"

- **`CLAUDE.md`** = the *how* → rules, principles, engineering standards (project-specific but based on a reusable template)
- **`project_spec.md`** = the *what* → what we're building, always project-specific

### 2. Agents as personas, not as processes

Each agent is a **Markdown definition** of a role, its triggers, inputs, outputs, and quality gates. When the orchestrator delegates a task, Claude Code takes on that persona and follows the constraints of that agent's file.

### 3. Memory as first-class citizen

`.claude/memory/` holds three append-only files:
- `decisions.md` → every non-trivial choice with rationale
- `lessons_learned.md` → what worked, what didn't
- `tech_debt.md` → tracked debt with severity and plan

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

After running the bootstrap script, your project will look like this:

```
your-project/
├── CLAUDE.md                        # Master config (loaded by Claude Code)
├── project_spec.md                  # What we're building
├── README.md                        # This file (or your project's README)
├── .claude/
│   ├── README.md                    # Framework internal readme
│   ├── agents/                      # 10 specialist agents
│   │   ├── project_orchestrator.md
│   │   ├── chief_engineer.md
│   │   ├── backend_architect.md
│   │   ├── frontend_architect.md
│   │   ├── database_architect.md
│   │   ├── security_officer.md
│   │   ├── qa_engineer.md
│   │   ├── devops_engineer.md
│   │   ├── documentation_writer.md
│   │   └── code_reviewer.md
│   ├── commands/                    # Slash commands
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
│   │   └── README.md
│   ├── memory/                      # Persistent context
│   │   ├── decisions.md
│   │   ├── lessons_learned.md
│   │   └── tech_debt.md
│   └── logs/                        # Session logs (optional)
├── sprints/                         # Sprint plans (created as you go)
├── docs/
│   └── adr/                         # Architecture Decision Records
└── post-mortems/                    # Incident reports
```

---

## ⚙️ Installation & Setup

### Requirements

- **Claude Code** (or another capable agentic coding assistant: Cursor, Windsurf, Aider…)
- **Git** for version control
- **Bash** (Linux/Mac/WSL) or **CMD/PowerShell** (Windows) to run the bootstrap script

### Setup in 3 steps

#### 1️⃣ Bootstrap the skeleton

**Linux / Mac / WSL:**
```bash
chmod +x bootstrap_casf.sh
./bootstrap_casf.sh
```

**Windows (CMD):**
```cmd
bootstrap_casf.bat
```

This creates all folders and stub Markdown files.

#### 2️⃣ Fill the framework with the Filler Prompt

Open Claude Code in the project folder and paste the **CASF Filler Prompt** (see [Prompt Library](#-prompt-library) below). The AI will materialize every stub file with production-grade content across 7 phases, waiting for your approval at each phase boundary.

#### 3️⃣ Write your `project_spec.md`

Either:
- Write it yourself using `.claude/templates/spec_template.md`, **or**
- Use the `/start-project` interview to have the AI collect requirements from you.

Now you're ready to build. 🚀

---

## 👥 The 10 Agents

| Agent | Role | Enforces |
|---|---|---|
| **project_orchestrator** | Top-level coordinator, entry point, delegates work | Everything |
| **chief_engineer** | Senior tech lead, resolves conflicts, signs ADRs | Architecture standards |
| **backend_architect** | APIs, services, data flow, background jobs | Backend rules (Ch. 10) |
| **frontend_architect** | UI architecture, components, state, a11y | Frontend rules (Ch. 11) |
| **database_architect** | Schema, migrations, indexes, query perf | DB rules (Ch. 12) |
| **security_officer** | Threat modeling, auth, secrets, OWASP | Security rules (Ch. 13) |
| **qa_engineer** | Test strategy, coverage, regression | Testing rules (Ch. 14) |
| **devops_engineer** | CI/CD, deploys, observability, rollback | Deployment rules |
| **documentation_writer** | README, ADRs, API docs, changelogs | Documentation rules (Ch. 15) |
| **code_reviewer** | Final PR gate, blocks bad merges | Definition of Done |

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

All prompts below are ready to copy-paste. Store them in `Prompt Catalog.md` for quick access.

---

### 🌟 Prompt 0 — CASF Filler Prompt (first-time setup)

Use this **once**, right after running the bootstrap script, to have the AI fill every stub file.
