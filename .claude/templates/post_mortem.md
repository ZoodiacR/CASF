# Template: post_mortem

## Purpose
Post-mortems document incidents, their root causes, and the lessons learned. Post-mortems focus on process improvement rather than blame, enabling the team to learn from incidents and prevent recurrence.

## Structure

### Required Sections

**Incident Summary**
- Brief description of the incident
- Incident severity (SEV1, SEV2, SEV3, SEV4)
- Incident duration
- Business impact

**Timeline**
- Chronological timeline of the incident
- Key events and timestamps
- Detection, containment, investigation, resolution milestones

**Impact Assessment**
- Users affected
- Revenue impact (if applicable)
- Service availability impact
- Data impact (if any)

**Root Cause Analysis**
- Primary root cause
- Contributing factors
- Why the root cause occurred
- How it was identified

**Resolution Steps**
- What was done to resolve the incident
- Temporary fixes (if any)
- Permanent fixes implemented
- Verification of resolution

**Lessons Learned**
- What went well during the incident
- What didn't go well
- Process gaps identified
- Technical gaps identified

**Action Items**
- Specific action items to prevent recurrence
- Owners and deadlines for each action item
- Priority of each action item

### Optional Sections

**Detection and Response**
- How the incident was detected
- How quickly it was detected
- Response effectiveness

**Prevention**
- What could have prevented this incident
- What monitoring or alerts would have helped
- What process changes would have helped

**References**
- Links to related incidents
- Links to relevant documentation
- Links to external resources

## Filled Example

### Post-Mortem: Production Outage Due to Database Migration Failure

**Incident Summary**
- **Description:** Complete service outage caused by a failed database migration during v1.2.0 deployment
- **Severity:** SEV1 (complete service outage)
- **Duration:** 55 minutes (10:00 - 10:55)
- **Date:** 2026-08-06

**Timeline**
- **10:00** - Deployment of v1.2.0 initiated
- **10:05** - Migration 005_add_user_preferences.sql started
- **10:07** - Migration failed with syntax error, database in inconsistent state
- **10:08** - All services started returning 500 errors
- **10:10** - Incident detected via monitoring alerts
- **10:12** - Incident declared SEV1, incident channel activated
- **10:15** - Rollback to v1.1.0 initiated
- **10:18** - Rollback migration executed successfully
- **10:20** - Service v1.1.0 deployed
- **10:22** - Health checks passing, errors decreasing
- **10:25** - Service restored, users able to access application
- **10:30** - Root cause investigation started
- **10:45** - Root cause identified (syntax error in migration)
- **10:50** - Fix developed and tested in staging
- **10:52** - Fixed v1.2.1 deployed
- **10:55** - Migration successful, service stable

**Impact Assessment**
- **Users Affected:** All users (approximately 10,000 active users)
- **Revenue Impact:** Estimated $2,000 in lost transactions
- **Service Availability:** 0% for 18 minutes (10:07 - 10:25)
- **Data Impact:** No data loss, database restored to consistent state via rollback

**Root Cause Analysis**
- **Primary Root Cause:** Syntax error in migration 005_add_user_preferences.sql (missing comma in column definition)
- **Contributing Factors:**
  - Migration was not tested on a copy of production data
  - Staging database schema differed from production (missing indexes)
  - CI/CD pipeline did not include migration syntax validation
  - Migration rollback was not tested before deployment
- **Why It Occurred:** Development pressure led to skipping comprehensive migration testing
- **How It Was Identified:** Database logs showed syntax error, inconsistent state caused all queries to fail

**Resolution Steps**
- **Immediate:** Executed rollback to v1.1.0, service restored
- **Temporary:** None (rollback was immediate and successful)
- **Permanent:**
  - Fixed syntax error in migration
  - Added migration syntax validation to CI/CD pipeline
  - Implemented comprehensive migration testing in staging
  - Added staging-to-production schema parity checks
- **Verification:** Fixed migration (v1.2.1) deployed successfully, service stable

**Lessons Learned**

**What Went Well:**
- Rollback plan was documented and executed successfully
- Incident response was quick (MTTD: 5 minutes)
- Communication channels were activated promptly
- Rollback restored service quickly (MTTR: 15 minutes to restore)

**What Didn't Go Well:**
- Migration testing was insufficient
- Staging environment did not mirror production schema
- CI/CD pipeline lacked migration validation
- Root cause investigation took longer than expected

**Process Gaps:**
- No mandatory migration testing on production-like data
- No staging-to-production schema parity verification
- No migration syntax validation in CI/CD
- Insufficient pre-deployment checklist for database changes

**Technical Gaps:**
- Lack of automated migration syntax checking
- Staging database not representative of production
- No automated rollback testing for migrations

**Action Items**

1. **Improve Staging Migration Testing**
   - Copy production data to staging for migration testing
   - Implement comprehensive migration test suite
   - Owner: database_architect
   - Deadline: 2026-08-13
   - Priority: HIGH

2. **Add Migration Validation to CI/CD**
   - Implement migration syntax validation
   - Add staging-to-production schema parity checks
   - Owner: devops_engineer
   - Deadline: 2026-08-13
   - Priority: HIGH

3. **Review Recent Migrations**
   - Audit all migrations in last 6 months for similar issues
   - Owner: database_architect
   - Deadline: 2026-08-09
   - Priority: MEDIUM

4. **Update Pre-Deployment Checklist**
   - Add mandatory migration testing requirement
   - Add rollback testing requirement for database changes
   - Owner: project_orchestrator
   - Deadline: 2026-08-10
   - Priority: MEDIUM

5. **Enhance Monitoring for Database Issues**
   - Add specific alerts for migration failures
   - Add alerts for database inconsistency
   - Owner: devops_engineer
   - Deadline: 2026-08-15
   - Priority: MEDIUM

**Detection and Response**
- **Detection:** Automated monitoring detected 500 errors within 3 minutes of failure
- **Response Time:** Incident declared SEV1 within 5 minutes of detection
- **Response Effectiveness:** Rollback executed within 10 minutes of incident declaration, effective

**Prevention**
- **What Could Have Prevented This:** Comprehensive migration testing on production-like data would have caught the syntax error
- **Monitoring:** Database-specific migration failure alerts would have enabled faster detection
- **Process:** Mandatory pre-deployment migration testing would have prevented deployment

**References**
- Related Incident: None (first incident of this type)
- ADR-001: System Architecture
- CLAUDE.md Chapter 12: Database Development
- Migration 005_add_user_preferences.sql (fixed version)

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
