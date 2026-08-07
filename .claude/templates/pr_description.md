# Template: pr_description

## Purpose
Pull request descriptions provide context for code changes, explain the why behind the what, and guide reviewers through the changes. Well-structured PR descriptions enable faster, more effective code reviews.

## Structure

### Required Sections

**Summary**
- Brief description of what this PR changes
- One or two sentences maximum

**Changes**
- List of major changes included in this PR
- Organized by component or feature area

**Motivation**
- Why is this change being made?
- What problem does it solve?
- What is the context?

**Testing**
- How was this change tested?
- What test coverage was added?
- How can reviewers verify the changes?

### Optional Sections

**Breaking Changes**
- List any breaking changes
- Provide migration guide if needed

**Screenshots**
- Screenshots for UI changes
- Before/after comparisons

**Checklist**
- Checklist of items completed before PR submission
- Reference to Definition of Done

**Related Issues**
- Links to related issues or tickets
- References to related PRs

## Filled Example

### PR #123: Implement Product Service with CRUD Operations

**Summary**
This PR implements the Product Service with full CRUD operations, database schema, migrations, and comprehensive testing.

**Changes**

**Backend:**
- Added Product Service with CRUD endpoints (Create, Read, Update, Delete)
- Implemented product validation and business logic
- Added request ID logging for all endpoints
- Implemented proper error handling and HTTP status codes

**Database:**
- Created products table with normalized schema
- Created product_categories table for categorization
- Created migration 003_create_products.sql
- Created migration 004_create_product_categories.sql
- Added indexes for frequently queried columns

**Testing:**
- Added unit tests for Product Service (coverage: 92%)
- Added integration tests for API endpoints
- Added migration tests with rollback verification
- Added test factories for product data generation

**Documentation:**
- Updated OpenAPI specification with Product Service endpoints
- Added API documentation with examples
- Updated README with Product Service information
- Added changelog entry

**Motivation**
This PR implements the Product Service as outlined in Sprint 1. The Product Service is a core component of the e-commerce platform, enabling sellers to manage their product inventory and buyers to discover and view products. This service follows the architecture defined in ADR-001 and implements the backend standards from CLAUDE.md chapter 10.

**Testing**

**Unit Tests:**
- Product creation with validation
- Product updates with partial updates
- Product deletion with soft delete
- Product queries with filtering and pagination
- Business logic for price validation
- Business logic for inventory management

**Integration Tests:**
- API endpoint testing for all CRUD operations
- Error response validation
- Authentication and authorization testing
- Database integration with transaction rollback

**Manual Testing:**
- Tested API endpoints with Postman
- Verified error handling for invalid inputs
- Verified authentication requirements
- Verified database constraints

**Test Coverage:**
- Overall: 88%
- Critical paths: 100%
- Business logic: 92%

**Breaking Changes**
None

**Checklist**
- [x] Code follows project style guide
- [x] Code complexity within limits
- [x] No commented-out code
- [x] No TODO comments without tickets
- [x] Unit tests written and passing
- [x] Integration tests written and passing
- [x] Coverage meets minimum (88% overall, 100% critical)
- [x] No flaky tests
- [x] API documentation updated
- [x] README updated
- [x] Changelog updated
- [x] Code comments added for non-obvious logic
- [x] Security review completed
- [x] No hardcoded secrets
- [x] Input validation implemented
- [x] Output sanitization implemented
- [x] Dependencies audited
- [x] Performance budgets met
- [x] All automated checks passing

**Related Issues**
- Closes #45 - Implement Product Service
- Related to ADR-001 - System Architecture
- Related to Sprint 1 Plan

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
