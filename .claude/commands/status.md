# /status

## Purpose
Prints the current project state including sprint status, open tasks, blockers, technical debt, and decisions log. This command provides a comprehensive overview of project progress and health to help the user understand where things stand.

## Preconditions
- Project must be initialized (Sprint 0 or later)
- Sprint plan must exist (or project spec if before Sprint 0)
- Memory files must exist in `.claude/memory/`
- Git repository must be accessible (for commit status)

## Steps

### Step 1: Gather Project State (project_orchestrator)
Collect current project information:

1. **Lifecycle Stage**
   - Identify current lifecycle stage (Discovery, Design, Build, Ship, Operate, Retrospective)
   - Identify current sprint number
   - Identify sprint progress (tasks complete/total)

2. **Git Status**
   - Check current branch
   - Check for uncommitted changes
   - Check for unpushed commits
   - Check for merge conflicts

3. **Project Memory**
   - Read `.claude/memory/decisions.md` for recent decisions
   - Read `.claude/memory/lessons_learned.md` for recent lessons
   - Read `.claude/memory/tech_debt.md` for tech debt items

**Output:** Project state summary

### Step 2: Sprint Status (project_orchestrator)
Report current sprint status:

1. **Sprint Overview**
   - Current sprint number and goals
   - Sprint start date and end date (if applicable)
   - Sprint progress percentage

2. **Task Status**
   - List completed tasks
   - List in-progress tasks
   - List pending tasks
   - List blocked tasks

3. **Sprint Health**
   - On track / at risk / off track
   - Estimated completion date
   - Potential risks or issues

**Output:** Sprint status report

### Step 3: Blockers and Risks (project_orchestrator)
Identify and report blockers and risks:

1. **Current Blockers**
   - List active blockers
   - Identify owners (which agent is blocked)
   - Identify impact on timeline
   - Identify unblocking steps

2. **Current Risks**
   - List identified risks
   - Assess risk severity (high/medium/low)
   - Identify mitigation strategies
   - Identify contingency plans

**Output:** Blockers and risks report

### Step 4: Technical Debt (project_orchestrator)
Report technical debt status:

1. **Debt Overview**
   - Total number of debt items
   - Debt by severity (critical/high/medium/low)
   - Debt by category (performance, security, architecture, etc.)

2. **Debt Details**
   - List critical debt items
   - List high-severity debt items
   - Identify debt with upcoming deadlines
   - Identify debt owners

3. **Debt Trends**
   - New debt added since last status
   - Debt resolved since last status
   - Overall debt trend (increasing/decreasing/stable)

**Output:** Technical debt report

### Step 5: Recent Decisions (project_orchestrator)
Report recent architectural and product decisions:

1. **Decision Summary**
   - Number of decisions recorded
   - Most recent decisions (last 5)
   - Decisions by category (architecture, product, process)

2. **Decision Details**
   - For each recent decision: summary, date, impact
   - Identify decisions requiring follow-up
   - Identify decisions that may need reversal

**Output:** Recent decisions report

### Step 6: Quality Gate Status (project_orchestrator)
Report quality gate status:

1. **Current Quality Gates**
   - Pre-commit gate status
   - CI gate status
   - Pre-merge gate status
   - Pre-deploy gate status

2. **Gate Failures**
   - List any failing quality gates
   - Identify failure reasons
   - Identify remediation steps

**Output:** Quality gate status report

### Step 7: Compile Status Report (project_orchestrator)
Compile all information into a comprehensive status report:

1. **Executive Summary**
   - High-level project health
   - Current lifecycle stage
   - Sprint status (on track/at risk/off track)
   - Critical blockers or risks

2. **Detailed Sections**
   - Sprint status
   - Blockers and risks
   - Technical debt
   - Recent decisions
   - Quality gate status
   - Git status

3. **Next Steps**
   - Recommended immediate actions
   - Upcoming milestones
   - Items requiring user attention

**Output:** Comprehensive status report

## Agents Involved

**Delegation Chain:**
```
User
  ↓
project_orchestrator (state gathering & reporting)
  ↓
User (review)
```

No specialist agent delegation is required for this command. The project_orchestrator reads and synthesizes information from memory files and project state.

## Outputs

**Files Read:**
- `docs/sprint/sprint_{n}_plan.md` - Current sprint plan
- `.claude/memory/decisions.md` - Decisions log
- `.claude/memory/lessons_learned.md` - Lessons learned
- `.claude/memory/tech_debt.md` - Tech debt register
- Git repository status

**Artifacts Produced:**
- Comprehensive status report
- Sprint status summary
- Blockers and risks summary
- Technical debt summary
- Recent decisions summary
- Quality gate status summary

## Success Criteria

1. **State Gathered:** All relevant project state information collected
2. **Sprint Status Reported:** Current sprint status accurately reported
3. **Blockers Identified:** All blockers and risks identified and reported
4. **Tech Debt Reported:** Technical debt status accurately reported
5. **Decisions Summarized:** Recent decisions summarized
6. **Quality Gates Reported:** Quality gate status accurately reported
7. **Report Compiled:** Comprehensive status report generated

## Failure Recovery

**If Project State Cannot Be Gathered:**
- If sprint plan is missing, report that project is pre-sprint (Discovery/Design stage)
- If memory files are missing, report that memory needs initialization
- If git is unavailable, report git status as unknown

**If Information Is Incomplete:**
- If task status is unclear, report as unknown and suggest updating sprint plan
- If debt items are missing owners, report as unassigned
- If decisions lack impact, report as not assessed

**If Report Compilation Fails:**
- If information conflicts, report the conflict and both versions
- If timeline is unclear, report estimated timeline
- If health assessment is uncertain, report as "unknown" and suggest review

## Example Run

**User:** /status

**project_orchestrator:** I'll gather the current project state and compile a comprehensive status report.

**project_orchestrator:** **Project Status Report**

**Executive Summary:**
- **Project Health:** 🟢 On Track
- **Lifecycle Stage:** Build - Sprint 3
- **Sprint Status:** On Track (60% complete)
- **Critical Blockers:** None
- **Critical Risks:** 1 high risk identified

**Sprint Status:**
- **Current Sprint:** Sprint 3
- **Sprint Goals:** Implement Order Service and checkout flow
- **Progress:** 6 of 10 tasks complete (60%)
- **Sprint End Date:** 2026-08-20 (5 days remaining)

**Task Status:**
**Completed (6):**
- ✅ Order Service API design
- ✅ Order schema and migrations
- ✅ Order Service implementation
- ✅ Payment integration design
- ✅ Checkout UI components
- ✅ Order tests (coverage: 90%)

**In Progress (2):**
- ⏳ Payment integration implementation (backend_architect)
- ⏳ E2E checkout flow tests (qa_engineer)

**Pending (2):**
- ⏸️ Order Service documentation (documentation_writer)
- ⏸️ Performance testing (qa_engineer)

**Blocked (0):**
- None

**Blockers and Risks:**
**Current Blockers:** None

**Current Risks:**
- **HIGH:** Payment provider API rate limits may impact peak load
  - Mitigation: Implement caching and rate limiting
  - Contingency: Negotiate higher limits with provider
- **MEDIUM:** E2E tests may take longer than estimated
  - Mitigation: Prioritize critical user journeys
  - Contingency: Defer non-critical E2E tests to next sprint

**Technical Debt:**
**Debt Overview:**
- Total Items: 8
- Critical: 0
- High: 2
- Medium: 4
- Low: 2

**Critical/High Debt Items:**
- **HIGH:** User Service query performance (N+1 queries)
  - Owner: backend_architect
  - Due: Sprint 4
- **HIGH:** Frontend bundle size exceeds budget
  - Owner: frontend_architect
  - Due: Sprint 4

**Debt Trends:**
- New debt since last status: +1 (frontend bundle size)
- Resolved debt since last status: -1 (Image upload optimization)
- Overall trend: Stable

**Recent Decisions:**
**Last 5 Decisions:**
1. **2026-08-05:** Adopt Stripe for payment processing (ADR-007)
2. **2026-08-03:** Implement order service as separate microservice (ADR-006)
3. **2026-08-01:** Use PostgreSQL full-text search for product search (ADR-005)
4. **2026-07-28:** Add Redis for session management (ADR-004)
5. **2026-07-25:** Implement OAuth 2.0 with PKCE for authentication (ADR-003)

**Quality Gate Status:**
- **Pre-commit Gate:** ✅ Passing
- **CI Gate:** ✅ Passing
- **Pre-merge Gate:** ✅ Passing
- **Pre-deploy Gate:** N/A (no deployment pending)

**Git Status:**
- **Current Branch:** feature/order-service
- **Uncommitted Changes:** 3 files modified
- **Unpushed Commits:** 2 commits
- **Merge Conflicts:** None

**Next Steps:**
1. Complete payment integration implementation (backend_architect)
2. Complete E2E checkout flow tests (qa_engineer)
3. Address high-severity tech debt before Sprint 4
4. Commit and push current changes
5. Prepare for Sprint 3 completion and retrospective

**User:** Good overview. Let's focus on completing the payment integration.

**project_orchestrator:** Status report complete. Delegating payment integration completion to backend_architect.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
