## 20. Definition of Done

### Purpose
This chapter defines the concrete criteria that must be met before any work is considered complete.

### Rules
1. **Code Completion Criteria:**
   - [ ] Code implemented per specification
   - [ ] Code follows project style guide
   - [ ] Code complexity within limits (chapter 9)
   - [ ] No commented-out code
   - [ ] No TODO comments without tickets
   - [ ] No console.log or debug statements

2. **Testing Criteria:**
   - [ ] Unit tests written and passing
   - [ ] Integration tests written and passing
   - [ ] Coverage meets minimum (80%)
   - [ ] Critical paths have 100% coverage
   - [ ] Tests are deterministic and fast
   - [ ] No flaky tests

3. **Documentation Criteria:**
   - [ ] API documentation updated
   - [ ] README updated if needed
   - [ ] Changelog updated
   - [ ] Code comments added for non-obvious logic
   - [ ] ADR created for architectural changes

4. **Security Criteria:**
   - [ ] Security review completed
   - [ ] No hardcoded secrets
   - [ ] Input validation implemented
   - [ ] Output sanitization implemented
   - [ ] Dependencies audited
   - [ ] OWASP compliance verified

5. **Performance Criteria:**
   - [ ] Performance budgets met
   - [ ] No regressions in load tests
   - [ ] Database queries optimized
   - [ ] N+1 queries eliminated
   - [ ] Caching implemented where appropriate

6. **Quality Gate Criteria:**
   - [ ] All automated checks passing
   - [ ] Code review approved
   - [ ] Security scan passed
   - [ ] License compliance verified
   - [ ] Build artifacts generated

### Examples
**Good:**
- Marking a task as done only after all DoD criteria are met
- Creating a checklist for DoD verification
- Blocking merges that don't meet DoD

**Bad:**
- Considering code "done" without tests
- Skipping documentation updates
- Merging without code review

### References
- See [code_reviewer.md](agents/code_reviewer.md) for DoD enforcement
- See [workflows/quality_gate.md](.claude/workflows/quality_gate.md) for quality gate implementation

---

## 21. Quality Gates

### Purpose
This chapter defines the automated and manual quality gates that must be passed at each lifecycle stage.

### Rules
1. **Pre-Commit Gate:**
   - [ ] Linting passes (ESLint, Pylint, etc.)
   - [ ] Formatting passes (Prettier, Black, etc.)
   - [ ] Unit tests pass locally
   - [ ] No committed secrets detected
   - [ ] License compliance check passes

2. **CI Gate (per PR):**
   - [ ] All unit tests pass
   - [ ] Integration tests pass
   - [ ] Coverage threshold met
   - [ ] Security scan passes (Snyk, Dependabot)
   - [ ] Dependency audit passes
   - [ ] Build succeeds
   - [ ] Performance budgets met
   - [ ] E2E tests pass (for critical changes)

3. **Pre-Merge Gate:**
   - [ ] Code review approved by at least one reviewer
   - [ ] Security officer approval (for security changes)
   - [ ] chief_engineer approval (for architectural changes)
   - [ ] Documentation review approved
   - [ ] All CI checks passing
   - [ ] No unresolved conversations in PR

4. **Pre-Deploy Gate (Staging):**
   - [ ] All CI checks passing
   - [ ] Staging deployment successful
   - [ ] Smoke tests pass on staging
   - [ ] Performance tests pass
   - [ ] Security scan passes on staging
   - [ ] Manual QA approval (for user-facing changes)

5. **Pre-Production Gate:**
   - [ ] All staging checks passing
   - [ ] Production deployment successful
   - [ ] Canary deployment healthy (if applicable)
   - [ ] Monitoring confirms no errors
   - [ ] SLOs not violated
   - [ ] Rollback plan tested

6. **Gate Enforcement:**
   - Gates must be automated where possible
   - Manual gates must have clear approval criteria
   - Failed gates must block progress
   - Gate failures must be documented
   - Regular gate maintenance and updates

### Examples
**Good:**
- Blocking PRs that fail CI checks
- Requiring approvals for architectural changes
- Running smoke tests after staging deployment

**Bad:**
- Bypassing quality gates for "urgent" changes
- Failing gates without documentation
- Manual gates without clear criteria

### References
- See [workflows/quality_gate.md](.claude/workflows/quality_gate.md) for gate implementation
- See [code_reviewer.md](agents/code_reviewer.md) for pre-merge gate

---

## 22. Release Management

### Purpose
This chapter defines release processes and version management.

### Rules
1. **Versioning:**
   - Use Semantic Versioning (SemVer 2.0.0)
   - MAJOR: Breaking changes
   - MINOR: New features, backward compatible
   - PATCH: Bug fixes, backward compatible
   - Pre-release tags: alpha, beta, rc

2. **Release Branching:**
   - Use Git Flow or similar branching strategy
   - Main branch is always deployable
   - Release branches for stabilization
   - Feature branches for development
   - Hotfix branches for emergency fixes

3. **Release Checklist:**
   - [ ] Version number updated
   - [ ] Changelog updated
   - [ ] Release notes prepared
   - [ ] All quality gates passed
   - [ ] Staging deployment verified
   - [ ] Rollback plan documented
   - [ ] Release announcement prepared
   - [ ] Post-release monitoring plan ready

4. **Release Deployment:**
   - Deploy during low-traffic windows (optional)
   - Use canary deployments for major releases
   - Monitor deployment closely
   - Have rollback plan ready
   - Communicate release to stakeholders

5. **Rollback Procedure:**
   - Document rollback steps for each release
   - Test rollback procedure regularly
   - Automate rollback where possible
   - Include database migration rollback
   - Verify rollback success

6. **Post-Release:**
   - Monitor for issues for 24-48 hours
   - Fix critical issues immediately
   - Document lessons learned
   - Update runbooks if needed
   - Celebrate successful releases

### Examples
**Good:**
- Following SemVer for version bumps
- Using canary deployments for major releases
- Documenting rollback procedures

**Bad:**
- Skipping quality gates for releases
- Deploying without rollback plan
- No post-release monitoring

### References
- See [workflows/release_workflow.md](.claude/workflows/release_workflow.md) for release process
- See [devops_engineer.md](agents/devops_engineer.md) for deployment automation

---

## 23. Incident Response

### Purpose
This chapter defines incident response procedures for production issues.

### Rules
1. **Incident Severity Levels:**
   - **SEV1:** Critical system down, complete outage
   - **SEV2:** Major functionality degraded, significant impact
   - **SEV3:** Minor functionality degraded, limited impact
   - **SEV4:** Cosmetic issues, no functional impact

2. **Incident Response Process:**
   - **Detect:** Monitoring alerts or user reports
   - **Acknowledge:** Assign severity and owner
   - **Investigate:** Gather data, identify root cause
   - **Mitigate:** Implement temporary fix
   - **Resolve:** Implement permanent fix
   - **Post-Mortem:** Document and learn

3. **Communication During Incident:**
   - Notify stakeholders promptly
   - Provide regular updates (every 30 minutes for SEV1/2)
   - Be transparent about impact and ETA
   - Use predefined communication channels
   - Document all decisions

4. **Rollback Criteria:**
   - Rollback immediately for SEV1 incidents
   - Consider rollback for SEV2 if fix will take > 1 hour
   - Always have rollback plan ready
   - Test rollback in staging if time permits
   - Communicate rollback to users

5. **Post-Mortem Requirements:**
   - Create post-mortem within 48 hours
   - Focus on process, not blame
   - Include timeline, root cause, impact
   - Document action items with owners
   - Follow up on action items

6. **Incident Metrics:**
   - Track MTTD (Mean Time To Detect)
   - Track MTTR (Mean Time To Resolve)
   - Track incident frequency
   - Track recurring incidents
   - Review metrics quarterly

### Examples
**Good:**
- Following incident response process for SEV1 incidents
- Creating post-mortems without blame
- Tracking incident metrics for improvement

**Bad:**
- Ignoring monitoring alerts
- Blaming individuals in post-mortems
- Not following up on post-mortem action items

### References
- See [workflows/emergency_recovery.md](.claude/workflows/emergency_recovery.md) for incident response
- See [templates/post_mortem.md](.claude/templates/post_mortem.md) for post-mortem format

---

## 24. Autonomous Execution

### Purpose
This chapter defines when agents may act autonomously without asking, and when they must stop and request approval.

### Rules
1. **Autonomous Actions (No Approval Needed):**
   - Writing code that clearly matches specifications
   - Running tests and linting
   - Creating standard documentation (README, API docs)
   - Implementing well-defined patterns from CLAUDE.md
   - Fixing bugs with clear root causes
   - Refactoring within quality limits
   - Adding logging and monitoring
   - Creating ADRs for clear architectural decisions

2. **Approval Required Actions:**
   - Architectural changes that affect multiple services
   - Breaking changes to public APIs
   - Security decisions that could introduce vulnerabilities
   - Performance optimizations that could introduce risk
   - Database schema changes (migrations)
   - Major refactoring beyond defined patterns
   - Decisions that contradict previous ADRs
   - Actions that could cause data loss
   - Deployment to production
   - Changes to quality gates or CI/CD pipeline

3. **Stop Conditions (Must Request Guidance):**
   - Unclear or conflicting requirements
   - Ambiguity in specifications
   - Missing information needed to proceed
   - Security implications not covered by chapter 13
   - Performance trade-offs not clearly defined
   - User input needed for product decisions
   - Conflicting guidance from CLAUDE.md
   - Situations outside documented patterns

4. **Autonomous Execution Limits:**
   - Maximum autonomous chain: 5 actions
   - After 5 autonomous actions, provide status update
   - Maximum time without update: 10 minutes
   - If uncertain, always ask rather than assume

5. **Risk Assessment:**
   - Assess risk before autonomous action
   - Low risk: standard patterns, clear specs
   - Medium risk: some ambiguity, but clear path
   - High risk: require approval (see above)
   - When in doubt, it's high risk

### Examples
**Good:**
- Autonomously implementing a well-defined feature from a spec
- Asking for approval before making breaking API changes
- Stopping when requirements are unclear

**Bad:**
- Making architectural changes without approval
- Proceeding with ambiguous requirements
- Not stopping when encountering conflicts

### References
- See [project_orchestrator.md](agents/project_orchestrator.md) for autonomous coordination
- See [chief_engineer.md](agents/chief_engineer.md) for architectural approval

---

## 25. Continuous Improvement

### Purpose
This chapter defines how the framework and team processes improve over time.

### Rules
1. **Retrospective Cadence:**
   - Sprint retrospectives after each sprint
   - Release retrospectives after each release
   - Quarterly process retrospectives
   - Incident retrospectives after SEV1/2 incidents

2. **Retrospective Format:**
   - What went well?
   - What didn't go well?
   - What can we improve?
   - Action items with owners and deadlines
   - Follow up on previous action items

3. **Lessons Learned Process:**
   - Document lessons in `.claude/memory/lessons_learned.md`
   - Include context, lesson, and application
   - Review lessons before starting new work
   - Update lessons when patterns change
   - Share lessons across projects

4. **Process Updates:**
   - Update CLAUDE.md based on retrospectives
   - Update agent specifications based on lessons
   - Update templates based on feedback
   - Update workflows based on incidents
   - Communicate process changes to team

5. **Metric Tracking:**
   - Track sprint velocity
   - Track bug rate
   - Track lead time
   - Track deployment frequency
   - Track change failure rate
   - Track mean time to restore
   - Review metrics quarterly

6. **Framework Evolution:**
   - Review CLAUDE.md quarterly
   - Update for new technologies and patterns
   - Incorporate feedback from agents
   - Remove outdated guidance
   - Add new chapters as needed

### Examples
**Good:**
- Conducting sprint retrospectives with action items
- Documenting lessons learned after incidents
- Updating CLAUDE.md based on retrospective insights

**Bad:**
- Skipping retrospectives
- Not following up on action items
- Ignoring lessons from previous projects

### References
- See [templates/post_mortem.md](.claude/templates/post_mortem.md) for incident retrospectives
- See [workflows/sprint_workflow.md](.claude/workflows/sprint_workflow.md) for sprint retrospectives

---

