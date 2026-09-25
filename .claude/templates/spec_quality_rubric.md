# Template: spec_quality_rubric

## Purpose
This rubric measures the **quality of a generated `project.md` / ProjectSpec**. It is the metric the `spec_quality_reviewer` agent uses to decide whether a spec is "rico" (rich, complete, buildable) or thin. The benchmark is the 61-section spec in `.claude/examples/PROJECT_SPEC.md` (Loyalify) — the *quality bar*, not a literal checklist to copy.

A spec that scores high here should let a reviewer scaffold the whole app (folders, entities, endpoints, states, security, delivery) **without guessing**.

## Scoring model
Each dimension is scored **0–4** (0 = absent, 2 = partial, 4 = excellent). Dimensions are weighted; the weighted sum (0–100) is the **Spec Quality Score**.

| # | Dimension | Weight | What "excellent" (4) looks like |
|---|---|---|---|
| 1 | **Product vision & business objective** | 8 | One-paragraph vision + the real problem + value proposition + how money/user flows. |
| 2 | **Target users / personas segmented** | 8 | Every role enumerated (owner, employee, customer, admin) with **explicit permissions and prohibitions**. |
| 3 | **Core UX flow** | 8 | End-to-end journey written as ordered steps ("Business creates account → … → Customer redeems reward"), mobile-first awareness. |
| 4 | **Domain systems** | 12 | The domain-specific mechanics (QR, loyalty program, rewards, points, transactions, campaigns, referrals) specified with **states, thresholds, and rules** — not just "a CRUD". |
| 5 | **Data model + integrity** | 12 | Entities with fields/types, identity, audit (`created_at`), referential integrity, and **immutable ledgers** (transactions/audit) where money/points move. |
| 6 | **Auth + authorization (RBAC)** | 8 | Auth flow, token strategy, and a **role→capability matrix** (who can/cannot do what). |
| 7 | **API contract** | 8 | Endpoints, verbs, status codes, pagination, and error shapes; versioning. |
| 8 | **Security & privacy** | 8 | Secrets handling, input validation, encryption in transit/rest, tenant isolation, PII/privacy (e.g. DNI). |
| 9 | **Infra + delivery** | 8 | Deployment (Docker), CI/CD, observability, health checks, backups, cost optimization. |
| 10 | **Frontend + UX + a11y + i18n** | 8 | Real screens (not "Home/About"), responsiveness, accessibility, currency/localization. |
| 11 | **Scope discipline** | 6 | Explicit **MVP definition** + **non-goals** (what NOT to build) + architectural decision rule ("prefer modular monolith"). |
| 12 | **Success criteria & production-readiness** | 6 | Measurable success + a concrete "definition of production ready". |

**Total weight = 100.**

## Red-line failures (auto-fail regardless of score)
A spec fails the review if **any** of these is true (these block a build):

- ❌ No **Data Model** (or empty/generic entities for an ambitious app).
- ❌ No **architecture** declared (folder layout + layers + communication + persistence).
- ❌ No **auth/RBAC** for a multi-user or money-handling app.
- ❌ No **stack** that matches ambition (e.g. a CRM spec says "static HTML").
- ❌ Scope creep with no MVP/non-goals on an ambitious SaaS.

## Passing thresholds
- **≥ 80 → EXCELLENT ("rico")**: ship to materializer as-is.
- **60–79 → GOOD**: ship; `spec_quality_reviewer` returns the top gaps as non-blocking.
- **40–59 → THIN**: must be enriched (feedback loop or LLM re-generation) before build.
- **< 40 → INSUFFICIENT**: reject; do not build.

## Rubric application (how the reviewer scores)
1. Parse the spec into its sections (match against the `## ` headers of `project.md`).
2. For each of the 12 dimensions, score 0–4 and **cite the specific section** that earned/docked points.
3. Apply the red-line checks. Any red-line → hard fail, regardless of score.
4. Emit: `{ score, weightedByDimension, redLines, topGaps[] (ordered), verdict }`.

## Gap → fix mapping (so the reviewer's output is actionable)
| Gap detected | Suggested fix |
|---|---|
| Missing Data Model | Add entities + fields + types + identity/audit (`applyFeedback` or re-generate). |
| No RBAC | Add role matrix (owner/employee/customer/admin) + `auth` in spec config. |
| Static stack for ambitious app | Force stack React + Node/Express + PostgreSQL in spec. |
| No states/rules in domain | Add enumerated states (Active/Inactive/Archived) and business rules (1 PEN = 1 point). |
| No immutability on ledger | Add `PointTransaction`/audit entity with earn/redeem types. |
| Scope creep | Add `## Non-goals` + `## MVP definition`. |

---

<!-- CASF v1.0 · generated 2026-09-22 -->
