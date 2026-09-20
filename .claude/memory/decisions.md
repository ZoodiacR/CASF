# Decisions Log

This file records all architectural and product decisions made during the project. Each decision includes the date, decision summary, rationale, and impact.

## Schema
Each decision entry should include:
- **Date:** ISO date (YYYY-MM-DD)
- **Decision:** Brief summary of the decision
- **Category:** Architecture, Product, Process, or Infrastructure
- **Rationale:** Why this decision was made
- **Impact:** What systems or processes are affected
- **ADR Reference:** Link to ADR if applicable

## Meta-Decision

### 2026-08-06: Adopted CASF Framework
- **Decision:** Adopt the CASF (Claude Autonomous Software Framework) for this project
- **Category:** Process
- **Rationale:** CASF provides a structured approach to software development with specialist agents, quality gates, and defined workflows. This enables consistent, high-quality software delivery with autonomous execution capabilities.
- **Impact:** All development will follow CASF processes, including agent delegation, quality gates, and documentation standards.
- **ADR Reference:** None (framework-level decision)

## Project Decisions

### 2026-09-20: Adopt monorepo for CASF Studio
- **Decision:** CASF Studio (the idea-to-app web product) uses a monorepo: `backend/` (Node + Express + TypeScript) and `frontend/` (React + Vite + TypeScript).
- **Category:** Architecture
- **Rationale:** Clear separation of concerns (API + LLM layer vs. UI), easy to reason about and deploy independently, matches the user's explicit "front y backend separados" requirement.
- **Impact:** `casf-studio/` repository structure; future deployment can host each side independently.

### 2026-09-20: ProjectSpec as Markdown (`project.md`), not JSON
- **Decision:** The spec artifact the LLM produces is a human-readable `project.md` (Markdown), not JSON. The framework parses it internally to materialize code.
- **Category:** Product
- **Rationale:** The user wants the spec to be readable by both the human and the framework. Markdown is legible, versionable, and reviewable; JSON is not.
- **Impact:** `backend/src/spec.ts` parses Markdown via `parseProjectMd`; the generated app stores `project.md` alongside code.

### 2026-09-20: Provider-agnostic LLM layer with zero-cost `mock`
- **Decision:** All LLM access goes through an `LLMProvider` interface; `mock` (deterministic, $0) is the default so the flow works without API keys. OpenAI/Anthropic supported via env vars.
- **Category:** Architecture
- **Rationale:** Enables demo/testing with no spend, avoids vendor lock-in, and feeds the token/cost accounting (`cost_accountant`).
- **Impact:** `backend/src/llm.ts`, `backend/src/cost.ts`; new providers are added as one class.

### 2026-09-20: Add `context_manager` + `cost_accountant` agents
- **Decision:** Two new framework agents: `context_manager` (owns `progress.md`, enables resume after token exhaustion) and `cost_accountant` (tracks tokens/cost for any LLM).
- **Category:** Process
- **Rationale:** Direct response to the user's pain: losing the thread after running out of tokens, and needing transparent cost accounting for monetization.
- **Impact:** `.claude/agents/`, `CLAUDE.md` delegation hierarchy, `/resume` command, `progress.md`, `token_ledger.md`.

### 2026-09-20: GitHub publishing via PAT (manual, guide provided)
- **Decision:** Repos (`casf-studio`, `casf` v1.0) are published to GitHub as PRIVATE, via a Personal Access Token. The MCP server config is in `.cursor/mcp.json`; full instructions in `GITHUB_GUIDE.md`.
- **Category:** Infrastructure
- **Rationale:** No `gh` CLI or token was available in this environment; a documented PAT flow is the most automated path the user can run themselves.
- **Impact:** `.cursor/mcp.json`, `GITHUB_GUIDE.md`.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
