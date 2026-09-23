# PROJECT SPECIFICATION
# Loyalify — QR Loyalty SaaS

Version: 1.0
Status: MVP Development
Product Type: Multi-Tenant SaaS
Primary Market: Small and medium businesses in Peru
Architecture: Modular Monolith
Deployment: Docker Compose
Primary Goal: Build a low-cost commercial loyalty platform

---

# 1. PRODUCT VISION

Loyalify is a multi-tenant SaaS platform that allows businesses to create and operate digital customer loyalty programs using QR codes.

The objective is to replace physical loyalty cards with a simple digital experience.

A business should be able to:

1. Create an account.
2. Configure its loyalty program.
3. Generate a unique QR code.
4. Display the QR code at its physical location.
5. Allow customers to scan the QR code.
6. Register or identify themselves.
7. Accumulate points or loyalty stamps.
8. Redeem rewards.
9. Monitor customer activity.
10. Analyze loyalty performance.

The platform must require minimal technical knowledge from business owners.

The entire onboarding process should be possible without developer intervention.

---

# 2. BUSINESS OBJECTIVE

Loyalify will operate as a subscription SaaS.

Businesses subscribe to a plan and receive access to the platform.

The platform must support:

- Free trials.
- Subscription plans.
- Customer limits.
- Feature limits.
- Multiple employees.
- Multiple locations in higher plans.
- Future payment integrations.

The system must be designed so that adding payment providers later does not require rewriting the core business logic.

---

# 3. TARGET USERS

## 3.1 Business Owner

The business owner manages the loyalty program.

Examples:

- Barber shops.
- Restaurants.
- Cafes.
- Beauty salons.
- Gyms.
- Retail stores.
- Pet shops.
- Small local businesses.

The owner should be able to configure the system without technical knowledge.

---

## 3.2 Employee

Employees can perform operational actions such as:

- Register customers.
- Add points.
- Validate rewards.
- View customer information.

Employees must have restricted permissions.

They must not be able to:

- Change subscription plans.
- Delete the business.
- Change ownership.
- Access platform administration.

---

## 3.3 Customer

The customer interacts with the loyalty program.

The customer should be able to:

- Register.
- Log in.
- View points.
- View rewards.
- View transaction history.
- Redeem rewards.
- View their loyalty status.

The customer experience should be optimized for mobile devices.

---

## 3.4 Platform Administrator

The platform administrator manages the SaaS itself.

The administrator can:

- View businesses.
- Suspend businesses.
- Manage plans.
- View platform statistics.
- View system logs.
- Manage platform settings.
- Manage feature flags.

The platform administrator must not need direct database access for normal administrative operations.

---

# 4. CORE USER EXPERIENCE

The primary customer flow is:

Business creates account

↓

Business configures loyalty program

↓

System generates QR

↓

Business prints/displays QR

↓

Customer scans QR

↓

Customer opens mobile web experience

↓

Customer registers/logs in

↓

Customer joins loyalty program

↓

Business records purchase

↓

Customer receives points

↓

Customer accumulates points

↓

Customer unlocks reward

↓

Customer redeems reward

---

# 5. QR CODE SYSTEM

Each business must have a unique public QR code.

Example:

https://app.example.com/b/{business-public-id}

The QR must contain only a public identifier or public URL.

Do not expose internal database identifiers where avoidable.

The QR must:

- Be permanent.
- Be downloadable.
- Be printable.
- Support PNG.
- Support SVG.
- Support PDF generation where practical.
- Be regeneratable.
- Remain associated with the business.

Regenerating the QR must not delete customer data.

---

# 6. LOYALTY PROGRAM

A business can configure a loyalty program.

MVP should support a points-based loyalty system.

Example:

Customer spends S/50.

Business configuration:

1 PEN = 1 point.

Customer receives:

50 points.

The business must be able to configure:

- Points per monetary unit.
- Minimum transaction value.
- Reward thresholds.
- Reward descriptions.
- Reward status.

Example:

100 points → Free coffee.

250 points → 20% discount.

500 points → Premium reward.

---

# 7. REWARD SYSTEM

Rewards belong to a business.

A reward contains:

- ID.
- Business ID.
- Name.
- Description.
- Points required.
- Status.
- Quantity limit if applicable.
- Expiration if applicable.
- Created date.
- Updated date.

Reward states:

- Active.
- Inactive.
- Archived.

Customers can redeem active rewards if they have enough points.

---

# 8. POINT TRANSACTIONS

Points must never be modified silently.

Every point change must create a transaction.

Transaction types:

- Earn.
- Redeem.
- Adjustment.
- Expiration.
- Bonus.
- Referral.

Example:

Customer:

100 points.

Purchase:

+50.

Balance:

150.

Reward:

-100.

Balance:

50.

The system must maintain an auditable history.

---

# 9. CUSTOMER MODEL

A customer belongs to one or more loyalty programs.

At minimum store:

- ID.
- Name.
- Phone.
- Email.
- Password hash where authentication requires it.
- Status.
- Created date.
- Updated date.

Do not collect unnecessary personal information.

The platform must follow data minimization principles.

---

# 10. CUSTOMER REGISTRATION

Customer registration should be extremely simple.

Required MVP fields:

- Name.
- Phone or email.
- Password.

The platform should prepare the architecture for:

- Google OAuth.
- Passwordless login.
- WhatsApp-based authentication.

These integrations are not required for MVP.

---

# 11. BUSINESS ONBOARDING

Business registration flow:

Step 1:

Create account.

Step 2:

Business information.

Fields:

- Business name.
- Business category.
- Country.
- Currency.
- Contact email.

Step 3:

Configure loyalty program.

Step 4:

Create first reward.

Step 5:

Generate QR.

Step 6:

Show onboarding completion.

The business should be able to start operating immediately.

---

# 12. BUSINESS PROFILE

Each business can configure:

- Name.
- Description.
- Logo.
- Contact information.
- Address.
- Website.
- Social media.
- Business category.
- Currency.
- Timezone.

MVP should default to:

Country: Peru

Currency: PEN

Timezone: America/Lima

However, these must be configurable in the architecture.

---

# 13. BRANDING

Businesses should be able to customize their loyalty experience.

MVP:

- Logo.
- Primary color.
- Secondary color.
- Business name.

Future:

- Custom domain.
- Custom fonts.
- White-label mobile experience.

---

# 14. BUSINESS DASHBOARD

The business dashboard must provide an overview.

Metrics:

- Total customers.
- New customers.
- Active customers.
- Points issued.
- Points redeemed.
- Rewards redeemed.
- Customer retention indicators.

The dashboard should display useful information without overwhelming the user.

---

# 15. CUSTOMER MANAGEMENT

Business users can:

- Search customers.
- Filter customers.
- View customer profile.
- View points balance.
- View transaction history.
- Add points.
- Remove points through an auditable adjustment.
- View redeemed rewards.

Pagination is required.

Do not load all customers into memory.

---

# 16. EMPLOYEE MANAGEMENT

Business owners can create employees.

Employee fields:

- Name.
- Email.
- Role.
- Status.

Roles:

OWNER

ADMIN

EMPLOYEE

Permissions must be enforced on the backend.

Frontend restrictions alone are insufficient.

---

# 17. MULTI-TENANCY

Multi-tenancy is a core architectural requirement.

A tenant represents a business organization.

Every tenant's data must be isolated.

Tenant-aware resources include:

- Customers.
- Rewards.
- Transactions.
- Campaigns.
- Employees.
- Locations.
- Settings.
- QR codes.
- Analytics.

No tenant may access another tenant's data.

Tenant isolation must be enforced at the service/repository layer and validated at API boundaries.

Never rely solely on frontend filtering.

---

# 18. MULTI-LOCATION SUPPORT

MVP may support a single location per business.

However, the architecture must be prepared for multiple locations.

Future model:

Business

↓

Locations

↓

Employees

↓

Transactions

Customers

The database must not make multi-location support impossible later.

---

# 19. CAMPAIGNS

Campaigns are not required for the first MVP release.

The architecture should reserve a module for future campaigns.

Possible future campaigns:

- Birthday bonus.
- Double points day.
- Inactive customer campaign.
- Referral campaign.
- Weekend promotion.

Do not implement this module unless required by the current roadmap.

---

# 20. REFERRALS

Referral functionality is future scope.

Potential flow:

Customer A receives referral link.

↓

Customer B registers.

↓

Customer B completes qualifying action.

↓

Customer A receives bonus points.

The architecture should allow future implementation without coupling referrals directly to the core points engine.

---

# 21. NOTIFICATIONS

MVP should not depend on notifications.

Prepare an abstraction for:

- Email.
- SMS.
- WhatsApp.
- Push notifications.

The notification system must use interfaces/providers.

Business logic must not depend directly on a specific provider.

---

# 22. ANALYTICS

MVP dashboard should include basic analytics.

Required metrics:

- Total customers.
- New customers.
- Total points issued.
- Total points redeemed.
- Rewards redeemed.

Future analytics:

- Retention.
- Churn.
- Customer lifetime value.
- Visit frequency.
- Campaign performance.

Analytics queries must not negatively affect transactional operations.

---

# 23. EXPORTS

Business owners should be able to export customer information.

MVP:

CSV.

Future:

Excel.

PDF reports.

Exports must respect tenant isolation and permissions.

---

# 24. AUTHENTICATION

Authentication must support:

- Email/password.
- JWT access token.
- Refresh token.

Passwords must be securely hashed.

Never store plaintext passwords.

Prepare architecture for:

- Google OAuth.
- Passwordless authentication.
- 2FA.

---

# 25. AUTHORIZATION

Use role-based access control.

Roles:

OWNER

ADMIN

EMPLOYEE

PLATFORM_ADMIN

Permissions must be checked server-side.

Never trust role information supplied by the client.

---

# 26. API

Use REST API.

Base path:

/api/v1/

Examples:

POST /api/v1/auth/register

POST /api/v1/auth/login

POST /api/v1/auth/refresh

GET /api/v1/business

PATCH /api/v1/business

GET /api/v1/customers

POST /api/v1/customers

GET /api/v1/customers/{id}

POST /api/v1/points/earn

POST /api/v1/points/adjust

GET /api/v1/rewards

POST /api/v1/rewards

POST /api/v1/rewards/{id}/redeem

GET /api/v1/analytics/dashboard

The final API design must be documented before implementation.

---

# 27. DATABASE

Primary database:

PostgreSQL.

Development may use SQLite where compatible.

ORM:

SQLAlchemy.

Migrations:

Alembic.

Use UUID identifiers.

Recommended core entities:

User

Business

BusinessMember

Customer

LoyaltyProgram

Reward

PointTransaction

RewardRedemption

QRCode

Location

Subscription

AuditLog

Additional entities may be introduced when justified.

---

# 28. DATABASE INTEGRITY

Use:

- Foreign keys.
- Unique constraints.
- Check constraints where appropriate.
- Indexes.
- Transactions.

Point balances must remain consistent with transaction history.

Financial-like operations must be atomic.

Reward redemption must prevent race conditions that could allow double redemption.

---

# 29. AUDIT LOGGING

Important actions must generate audit events.

Examples:

- Login.
- Customer creation.
- Point adjustment.
- Reward creation.
- Reward redemption.
- Employee creation.
- Business configuration changes.

Audit logs must include:

- Actor.
- Business.
- Action.
- Resource.
- Timestamp.
- Relevant metadata.

Never store secrets in audit logs.

---

# 30. SECURITY

Follow OWASP Top 10.

Requirements include:

- Input validation.
- Authentication security.
- Authorization.
- Rate limiting.
- Secure headers.
- CORS configuration.
- Password hashing.
- Secure token handling.
- SQL injection prevention.
- XSS prevention.
- Tenant isolation.

Sensitive configuration must come from environment variables or secure deployment configuration.

Never commit secrets.

---

# 31. INFRASTRUCTURE

The platform must be deployable using Docker Compose.

Initial architecture:

Internet

↓

Cloudflare

↓

Nginx

↓

Frontend

↓

Backend

↓

PostgreSQL

Optional:

Redis

MinIO

---

# 32. COST OPTIMIZATION

Operational cost must be minimized.

The MVP should avoid unnecessary managed cloud services.

Preferred approach:

One VPS.

Docker Compose.

PostgreSQL.

Nginx.

Cloudflare.

Object storage can initially use local persistent storage if acceptable.

The architecture must allow migration to managed infrastructure later.

Do not introduce microservices for MVP.

---

# 33. FRONTEND

Technology:

React.

TypeScript.

Vite.

Material UI.

TanStack Query.

React Hook Form.

Zod.

The frontend must be responsive.

Priority:

Mobile customer experience.

Desktop business dashboard.

---

# 34. CUSTOMER EXPERIENCE

The customer-facing application must be mobile-first.

Primary screen:

Business branding.

Customer identity.

Points balance.

Available rewards.

Recent activity.

The customer should be able to understand their loyalty status within seconds.

---

# 35. BUSINESS EXPERIENCE

The business dashboard should prioritize:

- Simplicity.
- Speed.
- Visibility.

A small business owner should not need technical training.

Common actions should require as few steps as possible.

---

# 36. ACCESSIBILITY

Target WCAG 2.1 AA where practical.

Requirements:

- Keyboard navigation.
- Accessible labels.
- Adequate contrast.
- Screen reader-friendly controls.
- Error messages.
- Focus states.

---

# 37. PERFORMANCE

The application should remain responsive under normal SaaS workloads.

Requirements:

- Pagination.
- Database indexes.
- Efficient queries.
- Lazy loading.
- API caching where justified.
- Frontend code splitting.

Do not optimize prematurely.

Measure first.

---

# 38. TESTING

Required:

Unit tests.

Integration tests.

API tests.

End-to-end tests for critical user journeys.

Critical journeys include:

1. Business registration.
2. Business onboarding.
3. Customer registration.
4. Customer joining loyalty program.
5. Adding points.
6. Reward redemption.
7. Tenant isolation.
8. Authentication.
9. Authorization.

---

# 39. QUALITY GATES

A feature cannot be considered complete if:

- Tests fail.
- Tenant isolation is unverified.
- Authentication is insecure.
- Documentation is missing.
- Database migrations are missing.
- API behavior is undocumented.
- Critical errors are ignored.

---

# 40. CI/CD

Use GitHub Actions.

Pipeline should eventually perform:

1. Install dependencies.
2. Lint.
3. Type check.
4. Unit tests.
5. Integration tests.
6. Build frontend.
7. Build Docker images.

Deployment automation can be introduced after MVP stabilization.

---

# 41. OBSERVABILITY

MVP:

- Structured application logs.
- Health endpoint.
- Database health check.
- Docker health checks.

Future:

- Metrics.
- Tracing.
- Error tracking.
- Centralized logging.

---

# 42. HEALTH CHECKS

Backend must expose:

GET /health

The health response should indicate application health.

A deeper readiness endpoint may verify:

- Database connectivity.
- Required dependencies.

---

# 43. FILE STORAGE

Businesses may upload:

- Logo.
- Branding assets.

MVP can use local persistent storage.

Future storage abstraction should support:

- MinIO.
- S3-compatible storage.

Do not couple business logic directly to filesystem operations.

---

# 44. SUBSCRIPTIONS

MVP may provide plan configuration without real payment processing.

Plans should support:

- Name.
- Price.
- Customer limit.
- Employee limit.
- Feature flags.
- Active status.

Future billing providers:

- Mercado Pago.
- Stripe.
- PayPal.

Payment providers must be isolated behind interfaces.

---

# 45. PLAN LIMITS

The architecture must support plan enforcement.

Example:

FREE

- 100 customers.
- 1 employee.
- 1 location.

BASIC

- 500 customers.
- 5 employees.
- 1 location.

PRO

- 2,000 customers.
- 15 employees.
- Multiple locations.

These values are examples and must be configurable.

Do not hard-code business plan limits throughout the application.

---

# 46. ADMIN PLATFORM

Platform administrators need:

Dashboard.

Businesses.

Users.

Plans.

Subscriptions.

System health.

Audit logs.

Feature flags.

Platform configuration.

Admin APIs must be isolated from business APIs.

---

# 47. FEATURE FLAGS

Prepare a feature flag mechanism.

Possible flags:

campaigns

referrals

advanced_analytics

multiple_locations

custom_branding

ai_insights

Feature flags must be centrally controlled.

---

# 48. FUTURE AI

AI is NOT part of the MVP.

The architecture should allow future services such as:

AI Business Assistant.

Customer churn analysis.

Campaign recommendations.

Customer segmentation.

Automatic promotion generation.

AI-generated business insights.

AI services must never directly manipulate core transactional data without explicit domain operations.

---

# 49. INTERNATIONALIZATION

MVP language:

Spanish.

Architecture should allow:

English.

Portuguese.

Translation strings must not be hard-coded into UI components.

---

# 50. LOCALIZATION

Default market:

Peru.

Default:

Currency: PEN

Timezone: America/Lima

Date format appropriate for Spanish-speaking users.

The system must remain extensible to other countries.

---

# 51. PRIVACY

Collect only necessary customer data.

Provide mechanisms for:

- Account deletion.
- Data correction.
- Data export.

Do not expose private customer information publicly.

Public QR pages must reveal only information necessary for the loyalty experience.

---

# 52. ERROR HANDLING

Errors must be predictable.

API errors should follow a consistent structure.

Never expose:

- stack traces
- database errors
- secrets
- internal infrastructure details

to end users.

Internal logs may contain diagnostic information but must avoid sensitive data.

---

# 53. PROJECT STRUCTURE

Recommended structure:

frontend/

backend/

docker/

docs/

scripts/

tests/

.claude/

Root documentation:

PROJECT_SPEC.md

ROADMAP.md

TASKS.md

CHANGELOG.md

README.md

The final structure may evolve if architectural reasoning justifies it.

---

# 54. DEVELOPMENT PHASES

## Phase 0 — Foundation

Repository.

Documentation.

Development environment.

Docker.

CI.

Architecture.

---

## Phase 1 — Authentication

Users.

Registration.

Login.

JWT.

Refresh tokens.

RBAC.

---

## Phase 2 — Business

Business creation.

Business settings.

Business onboarding.

Tenant isolation.

---

## Phase 3 — Loyalty

Customers.

Loyalty programs.

Points.

Transactions.

Rewards.

---

## Phase 4 — QR

QR generation.

QR public pages.

Customer enrollment.

QR download.

---

## Phase 5 — Dashboard

Customer management.

Reward management.

Transactions.

Dashboard metrics.

---

## Phase 6 — Employees

Business members.

Roles.

Permissions.

Employee operations.

---

## Phase 7 — Analytics

Basic analytics.

Reports.

CSV export.

---

## Phase 8 — Production

Docker.

Nginx.

HTTPS.

Cloudflare.

Backups.

Health checks.

Security hardening.

---

# 55. MVP DEFINITION

The MVP is complete when a real business can:

1. Register.
2. Configure its business.
3. Configure a loyalty program.
4. Create rewards.
5. Generate a QR.
6. Display the QR.
7. Have a customer scan it.
8. Customer registers.
9. Business records a purchase.
10. Customer receives points.
11. Customer reaches reward threshold.
12. Customer redeems reward.
13. Business sees the redemption.
14. Business sees basic analytics.

All of this must work without developer intervention.

---

# 56. NON-GOALS FOR MVP

Do NOT implement unless explicitly added to the roadmap:

- Native mobile applications.
- AI assistant.
- WhatsApp automation.
- SMS campaigns.
- Complex marketing automation.
- POS integrations.
- Advanced billing.
- Kubernetes.
- Microservices.
- Complex event-driven architecture.
- Advanced predictive analytics.

Avoid scope creep.

---

# 57. ARCHITECTURAL DECISION RULE

When a requirement can be implemented using:

Simple modular monolith

OR

Complex distributed architecture

Choose the modular monolith.

Only introduce distributed infrastructure when actual requirements justify it.

---

# 58. DEVELOPMENT RULE

Do not build speculative features.

Build what the current roadmap requires.

However, avoid architectural decisions that make obvious future requirements impossible.

---

# 59. DEFINITION OF PRODUCTION READY

Production readiness requires:

- Tests passing.
- Security review.
- Tenant isolation testing.
- Database migrations.
- Backups.
- Environment configuration.
- Health checks.
- Error handling.
- Logging.
- Documentation.
- Docker deployment.
- HTTPS.
- Recovery procedure.

---

# 60. SUCCESS CRITERIA

Loyalify succeeds when a small business can start a loyalty program without technical assistance.

The system should feel:

Fast.

Simple.

Reliable.

Professional.

Affordable.

The business owner should think:

"I can start using this today."

The customer should think:

"Scanning this QR is worth it."

---

# 61. FINAL PRINCIPLE

Do not build a QR generator.

Build a loyalty platform.

The QR is only the entry point.

The real product is:

Customer retention.

Repeat purchases.

Business insights.

Rewards.

Customer relationships.

The architecture must reflect that vision.