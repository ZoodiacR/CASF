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

*Project-specific lessons will be recorded here as the project progresses.*

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
