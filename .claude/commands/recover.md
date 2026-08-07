# /recover

## Purpose
Executes emergency recovery for production incidents by triaging the incident, containing the damage, executing rollback if needed, and creating a post-mortem. This command activates the emergency recovery workflow to handle SEV1 and SEV2 incidents.

## Preconditions
- Production incident has occurred
- Incident severity has been assessed (SEV1, SEV2, SEV3, or SEV4)
- Incident owner has been assigned
- Emergency communication channels are established
- Rollback plan exists for the affected release

## Steps

### Step 1: Incident Triage (project_orchestrator)
Assess and triage the incident:

1. **Incident Assessment**
   - Confirm incident severity level
   - Assess business impact
   - Assess user impact
   - Assess scope (affected services, users, regions)

2. **Initial Diagnosis**
   - Gather available error logs and metrics
   - Identify symptoms vs root cause
   - Identify when the incident started
   - Identify any recent changes (deployments, config changes)

3. **Communication Setup**
   - Activate incident communication channel
   - Notify stakeholders
   - Set up regular update cadence (every 30 min for SEV1/2)
   - Document incident timeline

**Output:** Incident triage report

### Step 2: Containment (project_orchestrator)
Contain the incident to prevent further damage:

1. **Immediate Actions**
   - If SEV1: Execute rollback immediately
   - If SEV2: Consider rollback if fix will take > 1 hour
   - If SEV3/4: Implement mitigations while investigating

2. **Rollback Execution** (if applicable)
   - Execute documented rollback plan
   - Monitor rollback for success
   - Verify service recovery
   - Communicate rollback to users

3. **Mitigation Implementation** (if not rolling back)
   - Implement temporary fixes
   - Disable affected features
   - Increase capacity if applicable
   - Implement circuit breakers

**Output:** Containment action report

### Step 3: Investigation (project_orchestrator)
Investigate root cause:

1. **Data Collection**
   - Collect detailed logs
   - Collect metrics and traces
   - Collect database query logs
   - Collect external service logs

2. **Root Cause Analysis**
   - Analyze collected data
   - Identify root cause
   - Identify contributing factors
   - Verify hypothesis with tests

3. **Specialist Consultation** (as needed)
   - Consult backend_architect for backend issues
   - Consult database_architect for database issues
   - Consult devops_engineer for infrastructure issues
   - Consult security_officer for security incidents

**Output:** Root cause analysis report

### Step 4: Resolution (project_orchestrator)
Implement permanent fix:

1. **Fix Development**
   - Develop fix for root cause
   - Test fix in staging environment
   - Verify fix addresses root cause
   - Ensure no regressions

2. **Fix Deployment**
   - Deploy fix to production
   - Monitor for success
   - Verify incident resolved
   - Monitor for side effects

3. **Verification**
   - Verify service health
   - Verify SLOs met
   - Verify user-facing functionality restored
   - Monitor for recurrence

**Output:** Fix deployment report

### Step 5: Post-Mortem Creation (project_orchestrator)
Create post-mortem document:

1. **Post-Mortem Content**
   - Incident summary and timeline
   - Impact assessment
   - Root cause analysis
   - Resolution steps
   - Lessons learned
   - Action items with owners and deadlines

2. **Post-Mortem Review**
   - Review post-mortem with team
   - Ensure focus on process, not blame
   - Verify action items are actionable
   - Assign owners and deadlines

3. **Documentation**
   - Store post-mortem in `docs/post-mortem/`
   - Update `.claude/memory/lessons_learned.md`
   - Update runbooks if needed
   - Update monitoring/alerting if needed

**Output:** Post-mortem document

### Step 6: Incident Closure (project_orchestrator)
Close incident and communicate:

1. **Final Communication**
   - Communicate resolution to stakeholders
   - Communicate resolution to users
   - Update status dashboards
   - Close incident communication channel

2. **Metrics Update**
   - Record MTTD (Mean Time To Detect)
   - Record MTTR (Mean Time To Resolve)
   - Update incident metrics
   - Review trends

3. **Follow-Up**
   - Track action items from post-mortem
   - Schedule follow-up meeting
   - Review process improvements

**Output:** Incident closure report

## Agents Involved

**Delegation Chain:**
```
User
  ↓
project_orchestrator (incident coordination)
  ↓
Specialist agents (as needed for investigation):
  - backend_architect (if backend issue)
  - database_architect (if database issue)
  - devops_engineer (if infrastructure issue)
  - security_officer (if security incident)
  ↓
project_orchestrator (resolution & post-mortem)
  ↓
User (confirmation)
```

## Outputs

**Files Created:**
- `docs/post-mortem/incident_{date}_{severity}.md` - Post-mortem document
- `docs/incident/incident_{date}_{severity}_report.md` - Incident report
- `.claude/memory/lessons_learned.md` - Updated with incident lessons
- `.claude/memory/decisions.md` - Updated with incident decisions

**Artifacts Produced:**
- Incident triage report
- Containment action report
- Root cause analysis report
- Fix deployment report
- Post-mortem document
- Incident closure report

## Success Criteria

1. **Incident Contained:** Incident is contained and damage minimized
2. **Root Cause Identified:** Root cause is identified and understood
3. **Fix Implemented:** Permanent fix is implemented and deployed
4. **Service Restored:** Service is restored to normal operation
5. **Post-Mortem Created:** Post-mortem is created and reviewed
6. **Lessons Learned:** Lessons are documented and action items assigned
7. **Incident Closed:** Incident is closed and communication complete

## Failure Recovery

**If Containment Fails:**
- If rollback fails, escalate to chief_engineer for emergency intervention
- If mitigation fails, try alternative mitigations
- If situation worsens, escalate to executive leadership

**If Investigation Fails:**
- If root cause cannot be identified, escalate to chief_engineer
- If data is insufficient, implement enhanced monitoring
- If issue is external, contact external vendor support

**If Fix Fails:**
- If fix doesn't resolve issue, rollback and investigate further
- If fix causes regressions, rollback and refine fix
- If fix deployment fails, use alternative deployment method

**If Post-Mortem Process Fails:**
- If team is unavailable, conduct post-mortem asynchronously
- If blame culture emerges, refocus on process improvement
- If action items are not actionable, refine them

## Example Run

**User:** /recover

**project_orchestrator:** I'll execute emergency recovery for the production incident. Let me start with incident triage.

**project_orchestrator:** Incident Triage:
- **Severity:** SEV1 (complete service outage)
- **Impact:** All users unable to access the application
- **Scope:** All services affected
- **Start Time:** 10 minutes ago
- **Recent Changes:** Deployment of v1.2.0 happened 15 minutes ago

**project_orchestrator:** Initial Diagnosis:
- Symptoms: 500 errors on all endpoints
- Recent change: Deployment of v1.2.0 (includes database migration)
- Hypothesis: Database migration may have failed or caused issues

**project_orchestrator:** Setting up communication:
- Incident channel activated
- Stakeholders notified
- Update cadence: Every 30 minutes
- Timeline documentation started

**project_orchestrator:** Executing containment (SEV1 - immediate rollback):

**devops_engineer:** Executing rollback to v1.1.0:
- Rollback initiated
- Database rollback migration executing
- Service v1.1.0 deploying
- Health checks: Passing
- Error rates: Dropping
- Users: Service restored

**project_orchestrator:** Containment successful. Service restored. Investigating root cause.

**project_orchestrator:** Consulting database_architect for migration investigation.

**database_architect:** *(Investigation)* Root cause identified:
- Migration 005_add_user_preferences.sql had a syntax error
- Error caused partial migration, leaving database in inconsistent state
- Partial migration caused all queries to fail

**project_orchestrator:** Root cause analysis complete. Developing fix.

**project_orchestrator:** Fix Development:
- Fixed migration syntax error
- Tested in staging: Migration successful
- Verified rollback migration: Successful
- No regressions detected

**project_orchestrator:** Deploying fix:

**devops_engineer:** Deploying fixed v1.2.1:
- Deployment successful
- Migration successful
- Health checks: Passing
- Error rates: Normal
- SLOs: Met

**project_orchestrator:** Fix verified. Service stable. Creating post-mortem.

**project_orchestrator:** Post-Mortem:
**Incident Summary:** SEV1 outage caused by database migration syntax error
**Timeline:** 
- 10:00 - v1.2.0 deployed
- 10:05 - Outage detected
- 10:15 - Rollback initiated
- 10:20 - Service restored
- 11:00 - Fix deployed
- 11:05 - Incident resolved

**Root Cause:** Migration 005 had syntax error not caught in staging
**Resolution:** Fixed migration syntax, improved staging migration tests
**Lessons Learned:**
- Migration testing in staging was insufficient
- Rollback plan worked well
- Detection time was acceptable (5 minutes)

**Action Items:**
- Improve staging migration tests (assigned to database_architect, due in 1 week)
- Add migration syntax validation to CI/CD (assigned to devops_engineer, due in 1 week)
- Review all recent migrations for similar issues (assigned to database_architect, due in 3 days)

**project_orchestrator:** Post-mortem reviewed and approved. Updating project memory.

**project_orchestrator:** Incident Closure:
- MTTD: 5 minutes
- MTTR: 55 minutes
- Stakeholders notified of resolution
- Users notified of resolution
- Incident channel closed

**User:** Good recovery. Let's implement the action items to prevent recurrence.

**project_orchestrator:** Incident closed. Action items assigned and tracked. Lessons learned recorded. Ready for normal operations.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
