# Lessons Learned

This file records lessons learned throughout the project, including what worked well and what didn't. These lessons inform future decisions and process improvements.

## Schema
Each lesson entry should include:
- **Date:** ISO date (YYYY-MM-DD)
- **Lesson:** What was learned
- **Category:** Process, Technical, Architecture, or Communication
- **Context:** Situation or project phase where the lesson was learned
- **Action:** What should be done differently in the future

## Canonical Lessons

### LL-001: Test Early and Often
- **Date:** 2026-08-06
- **Lesson:** Writing tests before or alongside implementation (TDD) catches bugs earlier and results in better code design. Waiting until the end to write tests leads to gaps in coverage and harder-to-test code.
- **Category:** Process
- **Context:** General software development best practice
- **Action:** Adopt test-driven development or at minimum, write tests concurrently with implementation. Never mark a task as done without tests.

### LL-002: Document Decisions as They're Made
- **Date:** 2026-08-06
- **Lesson:** Documenting architectural and product decisions immediately after they're made prevents knowledge loss and enables future understanding. Relying on memory leads to forgotten context and conflicting interpretations.
- **Category:** Process
- **Context:** General software development best practice
- **Action:** Create an ADR for every significant architectural decision. Record all decisions in the decisions log. Never make architectural decisions without documentation.

### LL-003: Invest in CI/CD Early
- **Date:** 2026-08-06
- **Lesson:** Setting up CI/CD pipelines early in the project prevents technical debt in deployment processes and enables fast, reliable releases. Manual deployment processes become fragile and don't scale.
- **Category:** Process
- **Context:** General software development best practice
- **Action:** Implement CI/CD pipeline in Sprint 0 or Sprint 1. Automate all quality gates. Never rely on manual deployment processes.

## Project-Specific Lessons

### LL-004: Token exhaustion loses the thread — checkpoint incrementally
- **Date:** 2026-09-20
- **Lesson:** A long autonomous session that runs out of tokens/context loses all in-flight state, and the user cannot easily resume. Waiting until the end to write a summary is insufficient — by then the state is already gone.
- **Category:** Process
- **Context:** First real use of CASF to build CASF Studio; the user explicitly reported losing the thread after token exhaustion.
- **Action:** `context_manager` must update `progress.md` BEFORE starting and AFTER finishing every task (or every 5 actions). The `progress.md` file is the single source of truth for resume. Enforce `/resume` as the canonical way to pick up work.

### LL-005: A human-readable spec beats JSON for reviewability
- **Date:** 2026-09-20
- **Lesson:** Representing the project spec as Markdown (`project.md`) — even though the engine needs structured data internally — massively improves the human's ability to review and trust the generated output. JSON is machine-friendly but not human-friendly.
- **Category:** Communication
- **Context:** User requested the spec be "understandable by us two" (human + framework), not JSON.
- **Action:** Prefer Markdown for any artifact that a human must read or sign off. Parse/derive structure programmatically as needed.

### LL-006: A zero-cost deterministic provider unlocks testing
- **Date:** 2026-09-20
- **Lesson:** A `mock` LLM provider (deterministic, $0) makes the entire pipeline testable and demoable without API keys, and catches integration bugs (e.g. name derivation from the wrong input) early.
- **Category:** Technical
- **Context:** Building the provider-agnostic LLM layer for CASF Studio.
- **Action:** Always ship a mock/fake provider alongside real ones; run smoke tests against it before touching paid APIs.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
