---
name: casf-framework
description: Operating manual for the CASF framework. Use when the user wants to turn a rough idea into a project spec, scaffold or build a full application, or run the agent delegation and quality-gate loop. Do not use for one-off coding questions.
---

# CASF — Collective Agent Software Framework

CASF turns a **rough idea** into a **production-grade project spec**, and then into a
**working application**. It is not a code generator that guesses: it derives the
architecture from the spec, builds it in reviewable slices, and puts every slice
through an adversarial review before calling it done.

## The pipeline

1. **Spec** — interview the user (bounded, ~15 turns) and emit a rich `PROJECT_SPEC.md`:
   entities, pages, roles, features, UX flow, MVP, **non-goals**.
2. **Spec quality gate** — score the spec with the `spec-quality-reviewer` subagent
   against `${CLAUDE_PLUGIN_ROOT}/.claude/templates/spec_quality_rubric.md`
   (benchmark: `${CLAUDE_PLUGIN_ROOT}/.claude/examples/PROJECT_SPEC.md`).
   A red-line failure (no data model, no architecture, no auth for money-handling)
   **blocks the build** regardless of score.
3. **Build in slices** — implement one slice at a time (`backend` → `frontend` → `root`).
   Never build the whole app in one pass.
4. **Adversarial review per slice** — spawn `architecture-reviewer` to attack the work:
   the reviewer goes to the code and marks each hypothesis CONFIRMED / REFUTED /
   UNVERIFIED with evidence, then returns **REFACTOR** or **HARDENING**.
5. **Fix, then re-review.** Max **2 fix attempts per finding** per slice. After two,
   annotate the finding as `PENDING` and move on. Do not loop forever.
6. **Wildcard slice** — one final pass over everything, including all `PENDING`
   findings, with up to 10 review→fix iterations. Whatever survives becomes explicit
   tech debt (owner + severity + why), never silent risk.
7. **Checkpoint before and after every task.** Update
   `.claude/memory/progress.md` so the work is resumable without re-explaining anything.

## Non-negotiables

- **Architecture over speed.** `frontend/` and `backend/` separated. A single flat
  directory with everything piled together is a failed build, not a shortcut.
- **Layered backend.** `server → app → routes/auth/crud → db`. No monoliths.
- **Real persistence.** A real database. An in-memory `Map()` for a full-stack app is
  not persistence.
- **Validate at the edge.** Whitelist input validation and pagination on the service
  boundary.
- **Respect the non-goals.** Never invent features the spec explicitly excluded.
- **Bilingual UI** (ES/EN) with a toggle, unless the spec says otherwise.
- **The author never reviews its own work.** Reviews are done by a distinct subagent
  with its own context. A review done inline by the author is not a review.

## Delegation

Route work through the `project-orchestrator`. Spawn specialist subagents
(`backend-architect`, `frontend-architect`, `database-architect`, `security-officer`,
`qa-engineer`, …) for domain work, and always spawn independent work in parallel.

The full 25-chapter constitution ships with this plugin:

- `${CLAUDE_PLUGIN_ROOT}/CLAUDE.md` — chapters 1–8 and 26 (identity, principles,
  lifecycle, context, decisions, architecture, delegation, post-implementation review)
- `${CLAUDE_PLUGIN_ROOT}/.claude/constitution/engineering.md` — chapters 9–19
- `${CLAUDE_PLUGIN_ROOT}/.claude/constitution/process.md` — chapters 20–25
- `${CLAUDE_PLUGIN_ROOT}/.claude/PATRON_DE_DISENO.md` — the generated-project layout
  contract every build must follow

Read the relevant chapter before making an architectural decision. Do not guess at
the rules; they are written down.
