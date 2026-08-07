# /new-sprint

## Purpose
Plans and executes a sprint by defining sprint goals, breaking down tasks, delegating to specialist agents, enforcing quality gates, and conducting a sprint retrospective. This command manages the complete sprint lifecycle from planning to completion.

## Preconditions
- Project specification must exist
- Previous sprint must be completed (or this is Sprint 0)
- Sprint plan template must be available in `.claude/templates/sprint_plan.md`
- Current project state must be recorded in `.claude/memory/`

## Steps

### Step 1: Sprint Planning (project_orchestrator)
Conduct sprint planning with the user:

1. **Review Previous Sprint** (if applicable)
   - Review completed tasks and deliverables
   - Review blockers and risks from previous sprint
   - Review lessons learned

2. **Define Sprint Goals** (1-2 turns)
   - What are the primary objectives for this sprint?
   - What defines success for this sprint?
   - What are the must-have vs nice-to-have items?

3. **Task Breakdown** (2-3 turns)
   - Break down sprint goals into actionable tasks
   - Estimate effort for each task
   - Identify dependencies between tasks
   - Assign priorities (must-have, should-have, could-have)

4. **Resource Planning** (1 turn)
   - Identify which specialist agents are needed
   - Plan parallel execution where possible
   - Identify potential bottlenecks

**Output:** Sprint plan with goals, tasks, and assignments

### Step 2: Task Delegation (project_orchestrator)
Delegate tasks to specialist agents based on sprint plan:

1. **Analyze Task Dependencies**
   - Identify tasks that can run in parallel
   - Identify tasks that must run sequentially
   - Create execution timeline

2. **Delegate to Specialist Agents**
   - Backend tasks → backend_architect
   - Frontend tasks → frontend_architect
   - Database tasks → database_architect
   - Security tasks → security_officer
   - Testing tasks → qa_engineer
   - DevOps tasks → devops_engineer
   - Documentation tasks → documentation_writer

3. **Provide Context for Each Task**
   - Clear task description with acceptance criteria
   - Relevant specifications and ADRs
   - Dependencies and integration points
   - Expected output format

**Output:** Delegated tasks with specialist assignments

### Step 3: Execution Monitoring (project_orchestrator)
Monitor task execution and provide status updates:

1. **Track Progress**
   - Monitor task completion status
   - Identify blockers and risks
   - Coordinate dependencies between tasks

2. **Provide Status Updates**
   - Regular status updates to user (at least daily equivalent)
   - Highlight completed tasks
   - Flag blockers requiring attention
   - Adjust timeline if needed

3. **Resolve Blockers**
   - Escalate blockers to chief_engineer for technical decisions
   - Re-prioritize tasks if needed
   - Adjust sprint scope if timeline is at risk

**Output:** Progress reports and blocker resolution

### Step 4: Quality Gate Enforcement (code_reviewer)
Enforce quality gates before sprint completion:

1. **Code Review**
   - Review all code changes from the sprint
   - Verify Definition of Done compliance
   - Block merges that violate standards

2. **Quality Gate Verification**
   - Verify all automated quality gates pass
   - Verify test coverage requirements are met
   - Verify security scans pass
   - Verify documentation is updated

3. **Remediation**
   - Return failing work to specialist agents for fixes
   - Re-verify after remediation
   - Block sprint completion until gates pass

**Output:** Quality gate pass/fail status

### Step 5: Sprint Completion (project_orchestrator)
Verify sprint completion and prepare for handoff:

1. **Verify Deliverables**
   - Confirm all sprint goals are met
   - Verify all tasks are complete
   - Verify all quality gates pass

2. **Update Project Memory**
   - Record decisions in `.claude/memory/decisions.md`
   - Record lessons learned in `.claude/memory/lessons_learned.md`
   - Update tech debt register if needed

3. **Prepare Release Package**
   - Assemble all deliverables
   - Prepare changelog entries
   - Prepare release notes

**Output:** Completed sprint package

### Step 6: Sprint Retrospective (project_orchestrator)
Conduct sprint retrospective with the user:

1. **What Went Well**
   - Identify successes from the sprint
   - Identify processes that worked well

2. **What Didn't Go Well**
   - Identify challenges and failures
   - Identify process issues

3. **Improvements**
   - Identify process improvements for next sprint
   - Update lessons learned
   - Adjust project practices if needed

**Output:** Retrospective document and lessons learned

## Agents Involved

**Delegation Chain:**
```
User
  ↓
project_orchestrator (planning & coordination)
  ↓
Specialist agents (parallel/sequential as needed):
  - backend_architect
  - frontend_architect
  - database_architect
  - security_officer
  - qa_engineer
  - devops_engineer
  - documentation_writer
  ↓
code_reviewer (quality gates)
  ↓
project_orchestrator (completion & retrospective)
  ↓
User (review & approval)
```

## Outputs

**Files Created:**
- `docs/sprint/sprint_{n}_plan.md` - Sprint plan
- `docs/sprint/sprint_{n}_retrospective.md` - Sprint retrospective
- `CHANGELOG.md` - Updated with sprint changes
- `.claude/memory/decisions.md` - Updated with sprint decisions
- `.claude/memory/lessons_learned.md` - Updated with sprint lessons

**Artifacts Produced:**
- Sprint goals and task breakdown
- Completed features and deliverables
- Quality gate verification reports
- Changelog entries
- Lessons learned and process improvements

## Success Criteria

1. **Planning Complete:** Sprint goals defined and tasks broken down
2. **Tasks Delegated:** All tasks assigned to specialist agents with clear context
3. **Execution Complete:** All tasks completed and blockers resolved
4. **Quality Gates Pass:** All quality gates pass before sprint completion
5. **Deliverables Verified:** All sprint deliverables meet Definition of Done
6. **Memory Updated:** Project memory updated with decisions and lessons
7. **Retrospective Complete:** Sprint retrospective conducted and documented

## Failure Recovery

**If Planning Fails:**
- If sprint goals are unclear, ask focused questions to clarify
- If task breakdown is too large, suggest breaking into smaller sprints
- If dependencies are complex, create dependency diagram and adjust order

**If Execution Fails:**
- If a specialist agent is blocked, escalate to chief_engineer for resolution
- If timeline is at risk, re-prioritize tasks to focus on must-haves
- If scope creep occurs, push non-essential tasks to next sprint

**If Quality Gates Fail:**
- If code review fails, return work to specialist agent for fixes
- If test coverage is insufficient, add tests before proceeding
- If security scan fails, address vulnerabilities before completion

**If Sprint Cannot Complete:**
- If sprint goals cannot be met, adjust scope with user approval
- If critical blockers cannot be resolved, pause sprint and escalate
- If external dependencies fail, adjust timeline or find alternatives

## Example Run

**User:** /new-sprint

**project_orchestrator:** I'll help you plan and execute Sprint 1. Let's start by reviewing the current state and defining sprint goals.

**project_orchestrator:** Reviewing Sprint 0 completion:
- ✅ Project structure and CI/CD set up
- ✅ User Service foundation implemented
- ✅ Database infrastructure configured
- ✅ Authentication system implemented
- ✅ Basic UI components created

**project_orchestrator:** What are the primary objectives for Sprint 1?

**User:** We need to implement the Product Service so sellers can list products.

**project_orchestrator:** What specific features for the Product Service are must-haves for this sprint?

**User:** Product creation, product listing, product search, and product details.

**project_orchestrator:** Are there any dependencies or risks I should know about?

**User:** We need image upload functionality, which might be complex.

**project_orchestrator:** I'll create the Sprint 1 plan:

**Sprint 1 Goals:**
- Implement Product Service with CRUD operations
- Implement product search functionality
- Implement image upload for products
- Create product listing UI
- Create product detail UI

**Task Breakdown:**
1. Backend: Product Service API design and implementation
2. Database: Product schema and migrations
3. Security: Image upload security review
4. Frontend: Product listing and detail components
5. DevOps: Image storage infrastructure
6. QA: Test strategy and implementation
7. Documentation: API docs and user guides

**project_orchestrator:** Delegating tasks to specialist agents.

*(Parallel delegation to specialist agents)*

**project_orchestrator:** Status update:
- ✅ Product Service API designed and implemented
- ✅ Product schema and migrations created
- ✅ Image upload security reviewed
- ⏳ Frontend components in progress
- ⏳ Image storage infrastructure being set up

*(Status updates continue throughout sprint)*

**project_orchestrator:** All tasks complete. Running quality gates.

**code_reviewer:** *(Quality gate verification)* All quality gates pass. Code review approved.

**project_orchestrator:** Sprint 1 complete. Updating project memory and preparing retrospective.

**project_orchestrator:** Sprint Retrospective:
**What Went Well:**
- Parallel execution of backend and database tasks saved time
- Image upload security review caught potential vulnerabilities early

**What Didn't Go Well:**
- Image storage setup took longer than estimated
- Frontend components had accessibility issues that required rework

**Improvements:**
- Add buffer time for infrastructure tasks
- Include accessibility review earlier in the process

**User:** Approved. Ready for Sprint 2.

**project_orchestrator:** Sprint 1 complete. Lessons learned recorded. Ready for /new-sprint when you're ready to begin Sprint 2.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
