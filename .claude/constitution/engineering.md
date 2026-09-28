## 9. Code Quality

### Purpose
This chapter defines the baseline code quality standards that all code must meet.

### Rules
1. **Style Consistency:** Follow existing code style in the repository. If no style guide exists, adopt language-accepted conventions (e.g., PEP 8 for Python, ESLint standard for JavaScript).

2. **Readability:** Code must be self-documenting. Prefer clear variable names over comments. Comments should explain "why," not "what."

3. **Complexity Limits:**
   - Maximum cyclomatic complexity: 10 per function
   - Maximum function length: 50 lines
   - Maximum nesting depth: 4 levels
   - Maximum parameter count: 5 parameters

4. **DRY Principle:** Eliminate duplication. If code appears in more than 2 places, extract it to a shared function or module.

5. **SOLID Principles:**
   - Single Responsibility: Each class/function has one reason to change
   - Open/Closed: Open for extension, closed for modification
   - Liskov Substitution: Subtypes must be substitutable for base types
   - Interface Segregation: Clients shouldn't depend on interfaces they don't use
   - Dependency Inversion: Depend on abstractions, not concretions

6. **Error Handling:** All errors must be handled explicitly. No silent failures. Use typed exceptions where available.

7. **Type Safety:** Use static typing where available (TypeScript, Python type hints, Java, etc.). Any type suppression must be justified with a comment.

### Examples
**Good:**
- Extracting duplicate validation logic into a shared utility
- Using TypeScript interfaces to define API contracts
- Adding type hints to Python functions

**Bad:**
- Copy-pasting code with minor variations
- Suppressing type errors without justification
- Functions exceeding 50 lines without decomposition

### References
- See [code_reviewer.md](agents/code_reviewer.md) for quality enforcement
- See [qa_engineer.md](agents/qa_engineer.md) for automated quality checks

---

## 10. Backend Development

### Purpose
This chapter defines backend development standards and practices.

### Rules
1. **API Design:**
   - Use RESTful conventions for HTTP APIs
   - Use OpenAPI/Swagger for API documentation
   - Implement proper HTTP status codes
   - Support content negotiation (JSON, XML if needed)
   - Version APIs via URL path (/v1/resource)

2. **Service Layer Pattern:** Implement a clear service layer for business logic, separate from controllers and data access.

3. **Validation:** Validate all inputs at the service boundary. Never trust client-side validation.

4. **Async Processing:** Use async/await patterns for I/O operations. Avoid blocking the event loop.

5. **Background Jobs:** For long-running tasks, implement background job processing with queues (e.g., Celery, Bull, Sidekiq).

6. **Rate Limiting:** Implement rate limiting on all public endpoints to prevent abuse.

7. **Request Tracing:** Use distributed tracing (e.g., OpenTelemetry) to track requests across services.

8. **Logging:** Logs must include:
   - Request ID for correlation
   - Timestamp
   - Log level (DEBUG, INFO, WARN, ERROR)
   - Structured context (user ID, action, relevant IDs)

### Examples
**Good:**
- Implementing a service layer with clear separation of concerns
- Using async/await for database queries
- Adding request IDs to all log entries

**Bad:**
- Business logic in controllers
- Synchronous I/O in async contexts
- Missing input validation on API endpoints

### References
- See [backend_architect.md](agents/backend_architect.md) for backend architecture
- See [security_officer.md](agents/security_officer.md) for API security

---

## 11. Frontend Development

### Purpose
This chapter defines frontend development standards and practices.

### Rules
1. **Component Architecture:**
   - Design components as reusable, self-contained units
   - Use composition over inheritance
   - Keep components small (< 300 lines)
   - Separate presentational from container components

2. **State Management:**
   - Use centralized state management for global state (Redux, Zustand, Context API)
   - Keep local state in components when appropriate
   - Normalize state shape to avoid duplication
   - Use immutable updates for state changes

3. **Accessibility (a11y):**
   - All interactive elements must be keyboard accessible
   - Use semantic HTML (button, nav, main, etc.)
   - Include ARIA labels where semantic HTML is insufficient
   - Test with screen readers
   - Maintain color contrast ratios (WCAG AA minimum)

4. **Performance:**
   - Implement code splitting for large bundles
   - Lazy load images and components
   - Optimize images (WebP, responsive sizes)
   - Use caching strategies (service workers, HTTP caching)
   - Measure Core Web Vitals

5. **Responsive Design:**
   - Mobile-first approach
   - Test on at least 3 breakpoints (mobile, tablet, desktop)
   - Use relative units (rem, em, %) over fixed pixels
   - Touch targets minimum 44x44 pixels

6. **Error Boundaries:** Implement error boundaries to catch and handle component errors gracefully.

### Examples
**Good:**
- Breaking UI into reusable component library
- Implementing lazy loading for route-based code splitting
- Adding ARIA labels to icon-only buttons

**Bad:**
- Monolithic components with mixed concerns
- Hardcoded pixel values for responsive design
- Missing keyboard navigation support

### References
- See [frontend_architect.md](agents/frontend_architect.md) for frontend architecture
- See [qa_engineer.md](agents/qa_engineer.md) for frontend testing

---

## 12. Database Development

### Purpose
This chapter defines database development standards and practices.

### Rules
1. **Schema Design:**
   - Use normalization (3NF minimum) unless denormalization is justified
   - Define foreign key constraints for referential integrity
   - Use appropriate data types (avoid VARCHAR when INT will do)
   - Add indexes for frequently queried columns
   - Document table purposes and relationships

2. **Migration Management:**
   - All schema changes must go through versioned migrations
   - Migrations must be reversible (rollback capability)
   - Never modify existing migrations; create new ones
   - Test migrations on a copy of production data

3. **Query Performance:**
   - Use EXPLAIN/ANALYZE to understand query plans
   - Avoid SELECT *; specify only needed columns
   - Use JOINs efficiently; avoid N+1 queries
   - Implement pagination for large result sets
   - Use connection pooling

4. **Transaction Management:**
   - Keep transactions short and focused
   - Use appropriate isolation levels
   - Handle deadlocks with retry logic
   - Avoid long-running transactions in user-facing code

5. **Data Integrity:**
   - Use database constraints (NOT NULL, UNIQUE, CHECK)
   - Implement soft deletes for audit trails where needed
   - Use triggers only when application logic is insufficient
   - Regularly validate data consistency

6. **Backup and Recovery:**
   - Implement automated backups (daily minimum)
   - Test restore procedures regularly
   - Document backup retention policy
   - Use point-in-time recovery for critical databases

### Examples
**Good:**
- Creating a migration for every schema change
- Adding foreign key constraints for referential integrity
- Using EXPLAIN to optimize slow queries

**Bad:**
- Manually modifying schema without migrations
- Skipping foreign keys for "performance"
- N+1 query patterns in application code

### References
- See [database_architect.md](agents/database_architect.md) for database architecture
- See [devops_engineer.md](agents/devops_engineer.md) for backup infrastructure

---

## 13. Security

### Purpose
This chapter defines security standards that must be followed across all layers of the application.

### Rules
1. **Authentication:**
   - Use industry-standard protocols (OAuth 2.0, OpenID Connect)
   - Implement PKCE for public clients
   - Use secure token storage (HttpOnly cookies, secure storage)
   - Implement token rotation and refresh mechanisms
   - Support multi-factor authentication for sensitive operations

2. **Authorization:**
   - Implement principle of least privilege
   - Use role-based access control (RBAC) or attribute-based (ABAC)
   - Validate authorization on every request (never trust client)
   - Audit all authorization decisions

3. **Data Protection:**
   - Encrypt data at rest (AES-256 minimum)
   - Encrypt data in transit (TLS 1.3 minimum)
   - Hash passwords with strong algorithms (Argon2, bcrypt)
   - Use salt for password hashing
   - Never log sensitive data (passwords, tokens, PII)

4. **Input Validation:**
   - Validate all inputs (whitelist preferred over blacklist)
   - Sanitize outputs to prevent XSS
   - Use parameterized queries to prevent SQL injection
   - Implement CSRF protection for state-changing operations
   - Validate file uploads (type, size, content)

5. **Dependency Management:**
   - Regularly audit dependencies for vulnerabilities
   - Use locked dependency files (package-lock.json, Cargo.lock)
   - Subscribe to security advisories for dependencies
   - Update dependencies promptly when vulnerabilities are disclosed

6. **Secrets Management:**
   - Never commit secrets to version control
   - Use environment variables or secret management systems
   - Rotate secrets regularly
   - Audit secret access logs
   - Use different secrets per environment

7. **OWASP Compliance:** Follow OWASP Top 10 and ASVS guidelines. Conduct regular security reviews.

### Examples
**Good:**
- Implementing OAuth 2.0 with PKCE for authentication
- Using parameterized queries for all database access
- Storing secrets in environment variables, not code

**Bad:**
- Hardcoding API keys or passwords
- Trusting client-side authorization checks
- Rolling custom crypto instead of using standard libraries

### References
- See [security_officer.md](agents/security_officer.md) for security implementation
- See [backend_architect.md](agents/backend_architect.md) for API security

---

## 14. Testing

### Purpose
This chapter defines testing standards and coverage requirements.

### Rules
1. **Testing Pyramid:**
   - **Unit Tests:** 70% of tests - fast, isolated, test single functions/classes
   - **Integration Tests:** 20% of tests - test component interactions
   - **E2E Tests:** 10% of tests - test critical user journeys

2. **Coverage Requirements:**
   - Unit test coverage: minimum 80%
   - Critical paths: 100% coverage
   - New code: must have tests before merge
   - Bug fixes: must include regression test

3. **Test Quality:**
   - Tests must be independent (order doesn't matter)
   - Tests must be deterministic (same result every run)
   - Tests must be fast (unit tests < 100ms each)
   - Use descriptive test names (should_describe_behavior)

4. **Test Data Management:**
   - Use factories or fixtures for test data
   - Clean up test data after each test
   - Use transaction rollback for database tests
   - Avoid hardcoding test data values

5. **Assertion Strategy:**
   - One assertion per test (when possible)
   - Assert on outcomes, not implementation details
   - Use custom matchers for complex assertions
   - Include helpful failure messages

6. **Testing External Dependencies:**
   - Mock external services in unit tests
   - Use contract tests for service boundaries
   - Use test doubles for slow dependencies
   - Include integration tests with real services where feasible

7. **E2E Testing:**
   - Focus on critical user journeys
   - Use page object model for maintainability
   - Run E2E tests in CI before deployment
   - Keep E2E tests stable and flake-free

### Examples
**Good:**
- Writing unit tests for business logic before implementation
- Using factories to generate test data
- Focusing E2E tests on critical paths (checkout, login)

**Bad:**
- Testing implementation details instead of behavior
- Brittle tests that break on unrelated changes
- Skipping tests for "simple" code

### References
- See [qa_engineer.md](agents/qa_engineer.md) for testing strategy
- See [code_reviewer.md](agents/code_reviewer.md) for test review

---

## 15. Documentation

### Purpose
This chapter defines documentation standards and requirements.

### Rules
1. **Documentation Types:**
   - **README.md:** Project overview, setup, quick start
   - **API Docs:** Auto-generated from OpenAPI/Swagger
   - **ADRs:** Architecture Decision Records in docs/adr/
   - **Changelog:** Version history in CHANGELOG.md
   - **Code Comments:** Explain "why," not "what"
   - **Runbooks:** Operational procedures in docs/runbooks/

2. **README Standards:** Every project must have a README.md with:
   - Project purpose and description
   - Prerequisites and setup instructions
   - Quick start guide (5-minute setup)
   - Architecture overview (diagram preferred)
   - Testing instructions
   - Deployment instructions
   - Contributing guidelines

3. **API Documentation:**
   - Use OpenAPI 3.0 specification
   - Include example requests/responses
   - Document error responses
   - Document authentication requirements
   - Auto-generate from code annotations where possible

4. **Code Documentation:**
   - Document public APIs with docstrings
   - Include examples in docstrings
   - Document non-obvious algorithms
   - Keep comments up to date with code changes

5. **Changelog Maintenance:**
   - Follow Keep a Changelog format
   - Categorize changes (Added, Changed, Deprecated, Removed, Fixed, Security)
   - Reference issue/PR numbers
   - Update for every release

6. **Runbooks:** For operational procedures, document:
   - Deployment procedures
   - Rollback procedures
   - Common troubleshooting steps
   - Incident response procedures

### Examples
**Good:**
- Maintaining a comprehensive README with quick start
- Auto-generating API docs from OpenAPI spec
- Documenting deployment procedures in runbooks

**Bad:**
- Empty or missing README
- Outdated documentation
- Comments that repeat the code

### References
- See [documentation_writer.md](agents/documentation_writer.md) for documentation management
- See [templates/adr.md](.claude/templates/adr.md) for ADR format

---

## 16. DevOps & Infrastructure

### Purpose
This chapter defines infrastructure and DevOps standards.

### Rules
1. **Infrastructure as Code (IaC):**
   - All infrastructure must be defined as code
   - Use Terraform, CloudFormation, or equivalent
   - Version control all IaC
   - Review IaC changes like code changes

2. **Environment Parity:**
   - Development, staging, and production must be as similar as possible
   - Use containerization (Docker) for consistency
   - Use the same configuration management across environments
   - Avoid manual configuration changes

3. **CI/CD Pipeline:**
   - Automated testing on every push
   - Automated builds for passing tests
   - Automated deployments to staging
   - Manual approval for production deployments
   - Pipeline defined as code (GitHub Actions, GitLab CI, etc.)

4. **Configuration Management:**
   - Store configuration in environment variables
   - Use configuration files for non-sensitive config
   - Never commit secrets to version control
   - Document required environment variables

5. **Container Standards:**
   - Use official base images or minimal distroless images
   - Scan images for vulnerabilities
   - Use multi-stage builds to minimize image size
   - Tag images meaningfully (semantic version)
   - Don't run as root in containers

6. **Secrets in CI/CD:**
   - Use CI/CD secret management (GitHub Secrets, GitLab Variables)
   - Rotate CI/CD secrets regularly
   - Audit secret access
   - Use short-lived tokens where possible

### Examples
**Good:**
- Defining infrastructure with Terraform
- Using Docker for consistent environments
- Implementing automated CI/CD pipeline

**Bad:**
- Manually configuring servers
- Committing secrets to CI/CD config
- Inconsistent environments across stages

### References
- See [devops_engineer.md](agents/devops_engineer.md) for DevOps implementation
- See [security_officer.md](agents/security_officer.md) for secrets management

---

## 17. Monitoring & Observability

### Purpose
This chapter defines monitoring and observability standards.

### Rules
1. **Metrics Collection:**
   - Collect RED metrics (Rate, Errors, Duration) for all services
   - Collect USE metrics (Utilization, Saturation, Errors) for resources
   - Use Prometheus or equivalent for metrics
   - Include business metrics (signups, conversions, etc.)

2. **Logging Standards:**
   - Use structured logging (JSON format preferred)
   - Include correlation IDs for request tracing
   - Define log levels (DEBUG, INFO, WARN, ERROR)
   - Avoid logging sensitive data
   - Centralize logs (ELK, CloudWatch, etc.)

3. **Distributed Tracing:**
   - Implement distributed tracing (OpenTelemetry, Jaeger)
   - Trace requests across service boundaries
   - Include timing data for each operation
   - Use traces for performance optimization

4. **Alerting:**
   - Alert on symptoms, not causes (e.g., high latency, not CPU usage)
   - Define alert severity levels (INFO, WARNING, CRITICAL)
   - Include runbook links in alerts
   - Avoid alert fatigue (tune thresholds)
   - Implement on-call rotation for critical alerts

5. **Dashboards:**
   - Create dashboards for each service
   - Include system health metrics
   - Include business metrics
   - Make dashboards accessible to the team
   - Review dashboards regularly for relevance

6. **SLI/SLO Management:**
   - Define Service Level Indicators (SLIs)
   - Set Service Level Objectives (SLOs)
   - Monitor SLO compliance
   - Create error budgets based on SLOs
   - Pause feature development when error budget is exhausted

### Examples
**Good:**
- Implementing Prometheus metrics for all services
- Creating dashboards for service health
- Setting up alerting with runbook links

**Bad:**
- Alerting on every error (alert fatigue)
- Logging sensitive data
- Missing correlation IDs in logs

### References
- See [devops_engineer.md](agents/devops_engineer.md) for monitoring setup
- See [workflows/emergency_recovery.md](.claude/workflows/emergency_recovery.md) for incident response

---

## 18. Performance

### Purpose
This chapter defines performance standards and optimization practices.

### Rules
1. **Performance Budgets:**
   - Define performance budgets for page load, API response, etc.
   - Include budgets in CI/CD pipeline
   - Fail builds that exceed budgets
   - Regularly review and adjust budgets

2. **Database Performance:**
   - Monitor slow query logs
   - Add indexes for frequently queried columns
   - Use connection pooling
   - Implement query caching where appropriate
   - Regularly analyze and optimize queries

3. **Caching Strategy:**
   - Implement caching at multiple levels (CDN, application, database)
   - Use appropriate cache invalidation strategies
   - Monitor cache hit rates
   - Consider cache warming for critical data
   - Use cache headers for static assets

4. **Frontend Performance:**
   - Optimize Core Web Vitals (LCP, FID, CLS)
   - Implement code splitting and lazy loading
   - Optimize images (WebP, responsive sizes)
   - Minimize JavaScript bundle size
   - Use CDN for static assets

5. **API Performance:**
   - Implement pagination for large result sets
   - Use compression (gzip, brotli)
   - Implement HTTP/2 or HTTP/3
   - Use GraphQL for over-fetching/under-fetching issues
   - Consider response compression

6. **Load Testing:**
   - Conduct load testing before major releases
   - Simulate realistic traffic patterns
   - Test beyond expected peak load
   - Identify and fix bottlenecks
   - Document load test results

### Examples
**Good:**
- Setting performance budgets in CI/CD
- Implementing CDN caching for static assets
- Conducting load testing before releases

**Bad:**
- Ignoring performance until users complain
- Over-caching without invalidation strategy
- Missing pagination on large datasets

### References
- See [backend_architect.md](agents/backend_architect.md) for backend performance
- See [frontend_architect.md](agents/frontend_architect.md) for frontend performance

---

## 19. Error Handling

### Purpose
This chapter defines error handling standards across all layers.

### Rules
1. **Error Classification:**
   - **User Errors:** Invalid input, permission denied (400, 401, 403, 404)
   - **Server Errors:** Unexpected failures (500, 502, 503)
   - **Transient Errors:** Temporary failures (retry with backoff)
   - **Permanent Errors:** Non-retryable failures (log and alert)

2. **Error Responses:**
   - Use appropriate HTTP status codes
   - Include error details in response body
   - Provide actionable error messages to users
   - Include correlation IDs for debugging
   - Sanitize error messages (don't expose internals)

3. **Error Logging:**
   - Log all errors with context
   - Include stack traces for server errors
   - Include correlation IDs
   - Log at appropriate levels (ERROR for server, WARN for user)
   - Centralize error logs

4. **Retry Strategy:**
   - Implement exponential backoff for retries
   - Set maximum retry attempts
   - Make retries idempotent
   - Circuit break for repeated failures
   - Don't retry non-idempotent operations by default

5. **Graceful Degradation:**
   - Provide fallback behavior when dependencies fail
   - Show helpful error messages to users
   - Maintain partial functionality when possible
   - Use feature flags to disable broken features

6. **Exception Handling:**
   - Use typed exceptions where available
   - Catch specific exceptions, not generic ones
   - Never silently swallow exceptions
   - Clean up resources in finally blocks
   - Use context managers for resource management

### Examples
**Good:**
- Implementing exponential backoff for retries
- Providing helpful error messages to users
- Logging errors with correlation IDs

**Bad:**
- Returning 200 OK with error in body
- Silently swallowing exceptions
- Exposing stack traces to users

### References
- See [backend_architect.md](agents/backend_architect.md) for backend error handling
- See [qa_engineer.md](agents/qa_engineer.md) for error testing

---

