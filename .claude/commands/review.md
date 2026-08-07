# /review

## Purpose
Runs a comprehensive code and architecture review across the current changeset. This command activates the code_reviewer and relevant specialist agents to validate that changes meet all quality standards, follow established patterns, and comply with the Definition of Done.

## Preconditions
- Uncommitted changes or a pull request must exist
- Project specification and relevant ADRs must be available
- Quality gate infrastructure must be configured
- CI/CD pipeline results must be available (if applicable)

## Steps

### Step 1: Context Gathering (project_orchestrator)
Gather context for the review:

1. **Identify Changes**
   - List all modified files
   - Identify the scope of changes (feature, bugfix, refactor)
   - Identify affected components and services

2. **Gather Relevant Context**
   - Feature specification or requirement
   - Relevant ADRs and architectural decisions
   - Previous code review feedback (if applicable)
   - CI/CD pipeline results

3. **Determine Review Scope**
   - Identify which specialist agents need to be involved
   - Determine depth of review (full review vs targeted review)
   - Identify any special considerations (security, performance, etc.)

**Output:** Review context document

### Step 2: Code Review (code_reviewer)
Conduct comprehensive code review:

1. **Code Quality Review**
   - Verify style guide compliance
   - Check complexity limits
   - Verify SOLID principles
   - Check for code duplication (DRY)
   - Verify error handling
   - Check type safety

2. **Standards Compliance**
   - Verify backend standards (chapter 10) if applicable
   - Verify frontend standards (chapter 11) if applicable
   - Verify database standards (chapter 12) if applicable
   - Verify security standards (chapter 13) if applicable
   - Verify testing standards (chapter 14) if applicable

3. **Definition of Done Verification**
   - Verify all DoD criteria are met
   - Check test coverage
   - Check documentation updates
   - Check ADR creation for architectural changes

**Output:** Code review report with findings

### Step 3: Specialist Reviews (project_orchestrator)
Delegate to specialist agents for domain-specific reviews:

**Conditional Delegation:**
- **backend_architect:** If backend code changed (API design, service layer, async processing)
- **frontend_architect:** If frontend code changed (components, state management, accessibility)
- **database_architect:** If database schema or queries changed
- **security_officer:** If security-sensitive code changed (auth, input validation, data handling)
- **qa_engineer:** If tests changed or coverage is in question
- **devops_engineer:** If infrastructure or deployment code changed
- **documentation_writer:** If documentation needs verification

**Output:** Specialist review reports

### Step 4: Integration Review (code_reviewer)
Integrate all review findings:

1. **Consolidate Findings**
   - Combine code review findings
   - Incorporate specialist review findings
   - Identify conflicting feedback
   - Prioritize issues by severity

2. **Categorize Issues**
   - **Blocking:** Must fix before merge
   - **Non-blocking:** Should fix but can defer
   - **Suggestions:** Optional improvements

3. **Generate Final Report**
   - Summary of changes
   - Blocking issues with remediation steps
   - Non-blocking suggestions
   - Approval/rejection recommendation

**Output:** Final review report

### Step 5: User Communication (project_orchestrator)
Present review findings to the user:

1. **Present Summary**
   - Scope of changes reviewed
   - Overall assessment
   - Key findings

2. **Present Blocking Issues**
   - List blocking issues
   - Provide remediation steps
   - Estimate effort to fix

3. **Present Suggestions**
   - List non-blocking suggestions
   - Explain rationale
   - Offer to implement if approved

4. **Request Decision**
   - Approve with fixes
   - Approve without fixes (if no blocking issues)
   - Reject and require changes

**Output:** User decision on next steps

### Step 6: Follow-up (project_orchestrator)
Execute based on user decision:

1. **If Approved with Fixes:**
   - Delegate fixes to relevant specialist agents
   - Re-run review after fixes
   - Present updated results

2. **If Approved:**
   - Record review approval
   - Update project memory if needed
   - Proceed with merge or next steps

3. **If Rejected:**
   - Communicate rejection rationale
   - Return changes to author with feedback
   - Await revised changes

**Output:** Review completion and next steps

## Agents Involved

**Delegation Chain:**
```
User
  ↓
project_orchestrator (context gathering & coordination)
  ↓
code_reviewer (primary review)
  ↓
Specialist agents (conditional, domain-specific):
  - backend_architect (if backend changes)
  - frontend_architect (if frontend changes)
  - database_architect (if database changes)
  - security_officer (if security changes)
  - qa_engineer (if test changes)
  - devops_engineer (if infrastructure changes)
  - documentation_writer (if documentation changes)
  ↓
code_reviewer (integration & final report)
  ↓
project_orchestrator (user communication)
  ↓
User (decision)
```

## Outputs

**Files Created:**
- `docs/review/review_{timestamp}.md` - Review report
- `.claude/memory/decisions.md` - Updated if decisions made
- `.claude/memory/lessons_learned.md` - Updated if lessons learned

**Artifacts Produced:**
- Code review report with findings
- Specialist review reports
- Blocking issue list with remediation steps
- Non-blocking suggestions
- Approval/rejection recommendation

## Success Criteria

1. **Context Gathered:** All relevant context collected for review
2. **Code Review Complete:** Comprehensive code review conducted
3. **Specialist Reviews Complete:** Relevant specialist agents consulted
4. **Findings Integrated:** All review findings consolidated and prioritized
5. **Report Generated:** Clear final report with actionable findings
6. **User Decision:** User has made decision on how to proceed
7. **Follow-up Executed:** Appropriate follow-up actions taken

## Failure Recovery

**If Context Gathering Fails:**
- If changes cannot be identified, ask user to clarify scope
- If relevant ADRs are missing, proceed with available context and note gaps
- If CI/CD results are unavailable, request manual verification

**If Code Review Fails:**
- If code cannot be reviewed due to complexity, break into smaller reviews
- If standards are unclear, reference CLAUDE.md chapters explicitly
- If conflicts arise in findings, escalate to chief_engineer for resolution

**If Specialist Reviews Fail:**
- If a specialist agent is unavailable, proceed with available agents
- If specialist feedback conflicts, facilitate resolution between agents
- If specialist review is incomplete, note limitation in final report

**If User Rejects Review:**
- If user disagrees with findings, provide additional rationale
- If user requests second opinion, escalate to chief_engineer
- If user wants to proceed despite blocking issues, document risk and require explicit confirmation

## Example Run

**User:** /review

**project_orchestrator:** I'll run a comprehensive review of the current changes. Let me gather context first.

**project_orchestrator:** Identified changes:
- Modified: `src/backend/userService.js` (user login endpoint)
- Modified: `src/frontend/components/LoginForm.jsx` (login form component)
- Modified: `src/database/migrations/003_add_login_attempts.sql` (schema change)
- New: `src/backend/auth.js` (authentication utilities)

**project_orchestrator:** Gathering relevant context:
- Feature: User login with rate limiting
- ADR-001: User Service Architecture
- CI/CD: All checks passing

**project_orchestrator:** Determining review scope:
- Changes affect backend, frontend, and database
- Security-sensitive changes (authentication)
- Need specialist reviews from backend_architect, frontend_architect, database_architect, security_officer

**project_orchestrator:** Conducting code review.

**code_reviewer:** *(Code review)* Code quality issues found:
- Password validation logic duplicated in two places (DRY violation)
- Login endpoint missing request ID in logs (chapter 10 violation)
- Complexity of auth.js exceeds limits (cyclomatic complexity: 12, limit: 10)

**project_orchestrator:** Delegating to specialist agents.

**backend_architect:** *(Review)* API design looks good, but missing rate limiting implementation.
**frontend_architect:** *(Review)* Component accessible, but missing ARIA label on error message.
**database_architect:** *(Review)* Migration is reversible, but missing index on user_id for performance.
**security_officer:** *(Review)* CRITICAL: Password hash uses bcrypt with too few rounds (4 rounds, minimum: 10).

**project_orchestrator:** Integrating findings.

**Final Review Report:**

**Blocking Issues (Must Fix):**
1. **CRITICAL:** Password hash uses insufficient bcrypt rounds (4 rounds, minimum: 10)
   - Remedy: Increase bcrypt rounds to 10
   - Effort: 5 minutes

2. **HIGH:** Missing rate limiting on login endpoint (security requirement)
   - Remedy: Implement rate limiting (5 requests per minute)
   - Effort: 30 minutes

3. **MEDIUM:** Missing index on user_id in login_attempts table (performance)
   - Remedy: Add index in migration
   - Effort: 5 minutes

**Non-Blocking Suggestions:**
1. Extract duplicated password validation logic to shared utility
2. Add request ID to login endpoint logs
3. Refactor auth.js to reduce complexity
4. Add ARIA label to error message in LoginForm

**Recommendation:** REJECT - Address blocking issues before merge

**User:** Please fix the blocking issues.

**project_orchestrator:** Delegating fixes to specialist agents.

*(Fixes implemented)*

**project_orchestrator:** Re-running review after fixes.

**code_reviewer:** *(Re-review)* All blocking issues resolved. Non-blocking suggestions remain.

**project_orchestrator:** Updated Review Report:

**Blocking Issues:** None - all resolved ✅

**Non-Blocking Suggestions:** (unchanged)

**Recommendation:** APPROVE - Ready for merge

**User:** Approved, merge it.

**project_orchestrator:** Review approved. Recording decision in memory and proceeding with merge.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
