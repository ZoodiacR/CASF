# /ship

## Purpose
Executes the release workflow by running quality gates, updating changelog, tagging the release, and deploying to production. This command manages the complete release process from green main branch to production deployment with rollback safety.

## Preconditions
- Main branch must be green (all quality gates passing)
- Release branch must be created and stabilized
- All quality gates must pass (CI/CD, security, performance)
- Release notes must be prepared
- Rollback plan must be documented and tested
- Production deployment window must be available (if applicable)

## Steps

### Step 1: Pre-Release Verification (project_orchestrator)
Verify all pre-release requirements:

1. **Quality Gate Verification**
   - Verify all CI/CD checks pass
   - Verify security scans pass
   - Verify performance budgets met
   - Verify test coverage requirements met
   - Verify license compliance

2. **Release Checklist Verification**
   - Version number updated
   - Changelog updated
   - Release notes prepared
   - Rollback plan documented
   - Post-release monitoring plan ready

3. **Staging Deployment Verification**
   - Staging deployment successful
   - Smoke tests pass on staging
   - Performance tests pass
   - Security scan passes on staging
   - Manual QA approval (if required)

**Output:** Pre-release verification report

### Step 2: Release Preparation (project_orchestrator)
Prepare for release:

1. **Version Management**
   - Update version number following SemVer
   - Create version tag
   - Push tag to remote

2. **Changelog Finalization**
   - Finalize CHANGELOG.md
   - Verify all changes are documented
   - Categorize changes (Added, Changed, Deprecated, Removed, Fixed, Security)
   - Reference issue/PR numbers

3. **Release Notes Generation**
   - Generate release notes from changelog
   - Add upgrade/migration guides if needed
   - Add known issues if any
   - Prepare communication materials

**Output:** Release package with version tag and changelog

### Step 3: Deployment Execution (devops_engineer)
Execute deployment with rollback safety:

1. **Canary Deployment** (if applicable)
   - Deploy to canary subset (e.g., 10% of traffic)
   - Monitor canary for errors
   - Verify SLOs not violated
   - Gradually increase traffic if healthy

2. **Full Deployment**
   - Deploy to production
   - Monitor deployment for errors
   - Verify health checks pass
   - Verify monitoring indicates normal operation

3. **Post-Deployment Verification**
   - Run smoke tests on production
   - Verify critical user journeys work
   - Verify SLOs not violated
   - Verify no performance regressions

**Output:** Deployment execution report

### Step 4: Post-Release Monitoring (devops_engineer)
Monitor release for issues:

1. **Immediate Monitoring** (first 30 minutes)
   - Monitor error rates
   - Monitor latency
   - Monitor SLO compliance
   - Monitor alerting

2. **Extended Monitoring** (24-48 hours)
   - Continue monitoring all metrics
   - Watch for edge case issues
   - Monitor user feedback
   - Monitor system behavior under load

3. **Rollback Readiness**
   - Keep rollback plan ready
   - Monitor for rollback triggers
   - Be prepared to rollback if issues detected

**Output:** Monitoring report

### Step 5: Release Completion (project_orchestrator)
Complete release process:

1. **Finalize Release**
   - Mark release as complete
   - Archive release artifacts
   - Update documentation if needed

2. **Update Project Memory**
   - Record release decision in `.claude/memory/decisions.md`
   - Record any lessons learned in `.claude/memory/lessons_learned.md`
   - Update tech debt register if needed

3. **Communicate Release**
   - Send release announcement
   - Share release notes with stakeholders
   - Update status dashboards
   - Celebrate successful release

**Output:** Release completion report

### Step 6: Retrospective (project_orchestrator)
Conduct brief release retrospective:

1. **What Went Well**
   - Identify successful aspects of release
   - Identify processes that worked well

2. **What Could Be Improved**
   - Identify challenges or issues
   - Identify process improvements

3. **Action Items**
   - Create action items for improvements
   - Assign owners and deadlines
   - Update lessons learned

**Output:** Release retrospective document

## Agents Involved

**Delegation Chain:**
```
User
  ↓
project_orchestrator (coordination & verification)
  ↓
devops_engineer (deployment & monitoring)
  ↓
code_reviewer (final quality verification)
  ↓
project_orchestrator (completion & retrospective)
  ↓
User (confirmation)
```

## Outputs

**Files Created:**
- `CHANGELOG.md` - Updated with release changes
- `docs/release/release_{version}.md` - Release notes
- `docs/release/release_{version}_retrospective.md` - Release retrospective
- `.claude/memory/decisions.md` - Updated with release decision
- `.claude/memory/lessons_learned.md` - Updated with release lessons

**Artifacts Produced:**
- Version tag
- Release notes
- Deployment execution report
- Monitoring report
- Release completion report
- Release retrospective

## Success Criteria

1. **Pre-Release Verification:** All quality gates pass and checklist items complete
2. **Release Preparation:** Version tagged, changelog finalized, release notes prepared
3. **Deployment Successful:** Deployment to production successful with no errors
4. **Post-Release Monitoring:** No critical issues detected in monitoring period
5. **Release Completed:** Release marked complete and artifacts archived
6. **Memory Updated:** Project memory updated with release information
7. **Retrospective Conducted:** Release retrospective conducted and documented

## Failure Recovery

**If Pre-Release Verification Fails:**
- If quality gates fail, address issues before proceeding
- If checklist items incomplete, complete them before release
- If staging deployment fails, fix issues and redeploy to staging

**If Deployment Fails:**
- If canary deployment fails, rollback immediately
- If full deployment fails, execute rollback plan
- If post-deployment verification fails, rollback and investigate

**If Post-Release Issues Detected:**
- If critical issues detected, rollback immediately
- If non-critical issues detected, assess risk and decide on rollback vs hotfix
- If SLOs violated, rollback and investigate

**If Rollback Required:**
- Execute rollback plan immediately
- Monitor rollback for success
- Investigate root cause of failure
- Plan fix and re-release

## Example Run

**User:** /ship

**project_orchestrator:** I'll execute the release workflow for version 1.0.0. Let me start with pre-release verification.

**project_orchestrator:** Pre-Release Verification:
- ✅ All CI/CD checks passing
- ✅ Security scans passing
- ✅ Performance budgets met
- ✅ Test coverage: 88% (above 80% minimum)
- ✅ License compliance verified
- ✅ Version number updated to 1.0.0
- ✅ Changelog updated
- ✅ Release notes prepared
- ✅ Rollback plan documented and tested
- ✅ Staging deployment successful
- ✅ Smoke tests passing on staging
- ✅ Performance tests passing
- ✅ Security scan passing on staging
- ✅ Manual QA approved

**project_orchestrator:** Pre-release verification complete. Preparing release.

**project_orchestrator:** Release Preparation:
- Version: 1.0.0
- Tag: v1.0.0 created and pushed
- Changelog: Finalized with all changes documented
- Release notes: Generated with upgrade guide

**project_orchestrator:** Delegating deployment to devops_engineer.

**devops_engineer:** Executing deployment:
- Canary deployment: 10% traffic
- Monitoring canary: No errors, SLOs met
- Increasing traffic: 50% traffic
- Monitoring: No errors, SLOs met
- Full deployment: 100% traffic
- Monitoring: No errors, SLOs met
- Smoke tests: Passing
- Health checks: All passing

**devops_engineer:** Deployment successful. Starting post-release monitoring.

**devops_engineer:** Post-Release Monitoring (30 minutes):
- Error rates: Normal (0.1%)
- Latency: Normal (p95: 200ms)
- SLOs: All met
- Alerting: No alerts

**devops_engineer:** Extended Monitoring (24 hours):
- Error rates: Normal throughout
- Latency: Normal throughout
- SLOs: All met throughout
- User feedback: Positive
- System behavior: Normal under load

**project_orchestrator:** Release complete. Updating project memory.

**project_orchestrator:** Release Retrospective:
**What Went Well:**
- Canary deployment caught no issues
- Rollback plan was ready but not needed
- Monitoring showed no regressions

**What Could Be Improved:**
- Staging smoke tests could be more comprehensive
- Release communication could be earlier

**Action Items:**
- Expand staging smoke test coverage (assigned to qa_engineer)
- Improve release communication timeline (assigned to documentation_writer)

**User:** Excellent release. Version 1.0.0 is live.

**project_orchestrator:** Release 1.0.0 complete. Version tagged, deployed, and monitored. Lessons learned recorded. Ready for next development cycle.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
