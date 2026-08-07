# /start-project

## Purpose
Bootstraps a new project by gathering requirements through a bounded discovery interview, running feasibility analysis, and producing an initial project specification and Sprint 0 plan. This is the flagship command that initiates the CASF framework for a new project.

## Preconditions
- Repository must be empty or contain only the CASF framework structure
- No existing project specification or sprint plans
- `.claude/memory/` directory must exist and be empty or contain only seed content
- User must be available for a discovery interview (approximately 15 turns)

## Steps

### Step 1: Discovery Interview (project_orchestrator)
Conduct a bounded interview with the user to gather project requirements. The interview must:

1. **Problem Understanding** (2-3 turns)
   - What problem are you trying to solve?
   - Who are the target users?
   - What is the value proposition?

2. **Requirements Gathering** (3-4 turns)
   - What are the key features?
   - What are the non-functional requirements (performance, security, scalability)?
   - What are the technical constraints or preferences (languages, frameworks)?
   - What is the timeline and budget?

3. **Feasibility Assessment** (2-3 turns)
   - What are the known risks or uncertainties?
   - Are there any regulatory or compliance requirements?
   - What defines success for this project?

4. **Validation** (1-2 turns)
   - Summarize requirements back to user for confirmation
   - Identify any gaps or ambiguities

**Output:** Project requirements document

### Step 2: Architectural Planning (chief_engineer)
Delegate to chief_engineer for initial architectural design:

1. Analyze requirements and constraints
2. Propose high-level system architecture
3. Recommend technology stack
4. Identify major architectural decisions
5. Create ADR-001 for initial architecture

**Output:** ADR-001: Initial System Architecture

### Step 3: Specialist Delegation (project_orchestrator)
Delegate in parallel to specialist agents for domain-specific planning:

**Parallel Delegation:**
- **backend_architect:** API structure and service design
- **frontend_architect:** UI architecture and component strategy
- **database_architect:** Data model and migration strategy
- **security_officer:** Initial threat assessment and security requirements
- **qa_engineer:** Test strategy and coverage requirements
- **devops_engineer:** CI/CD pipeline and infrastructure requirements
- **documentation_writer:** Documentation structure and standards

**Output:** Domain-specific design documents

### Step 4: Specification Creation (project_orchestrator)
Integrate all specialist inputs into a comprehensive project specification using the spec template:

1. Compile requirements from discovery interview
2. Integrate architectural decisions from ADR-001
3. Incorporate specialist domain designs
4. Define success criteria and metrics
5. Identify risks and mitigation strategies
6. Create Sprint 0 plan with initial tasks

**Output:** Project specification document, Sprint 0 plan

### Step 5: Memory Initialization (project_orchestrator)
Initialize project memory files:

1. Record initial decision in `.claude/memory/decisions.md`
2. Seed `.claude/memory/lessons_learned.md` with canonical lessons
3. Initialize `.claude/memory/tech_debt.md` with schema documentation

**Output:** Initialized memory files

### Step 6: Review and Approval (project_orchestrator)
Present the complete project package to the user for review:

1. Present project specification
2. Present Sprint 0 plan
3. Present ADR-001 and domain designs
4. Request user approval to proceed
5. Address any questions or concerns

**Output:** User approval to begin Sprint 0

## Agents Involved

**Delegation Chain:**
```
User
  ↓
project_orchestrator (entry point)
  ↓
chief_engineer (architecture)
  ↓
Specialist agents (parallel):
  - backend_architect
  - frontend_architect
  - database_architect
  - security_officer
  - qa_engineer
  - devops_engineer
  - documentation_writer
  ↓
project_orchestrator (integration)
  ↓
User (approval)
```

## Outputs

**Files Created:**
- `docs/spec/project_specification.md` - Comprehensive project specification
- `docs/adr/001-initial-architecture.md` - Initial architecture ADR
- `docs/sprint/sprint_0_plan.md` - Sprint 0 plan
- `.claude/memory/decisions.md` - Initial decision log
- `.claude/memory/lessons_learned.md` - Seeded lessons
- `.claude/memory/tech_debt.md` - Initialized tech debt register

**Artifacts Produced:**
- Project requirements document
- High-level system architecture
- Technology stack recommendations
- Domain-specific designs (API, UI, database, security, testing, DevOps, docs)
- Sprint 0 task breakdown
- Risk assessment and mitigation strategies

## Success Criteria

1. **Discovery Complete:** All requirements gathered and validated with user
2. **Architecture Defined:** ADR-001 created and approved by chief_engineer
3. **Specialist Inputs Collected:** All 7 specialist agents have provided domain designs
4. **Specification Complete:** Project specification integrates all inputs comprehensively
5. **Sprint 0 Ready:** Sprint 0 plan has actionable tasks for implementation
6. **Memory Initialized:** All memory files are properly initialized
7. **User Approval:** User approves the project package to proceed

## Failure Recovery

**If Discovery Interview Fails:**
- If user is unavailable, pause and reschedule
- If requirements are unclear, ask focused clarifying questions
- If scope is too large, suggest breaking into phases

**If Architectural Planning Fails:**
- If chief_engineer cannot reach consensus, escalate to user for decision
- If technology stack is unclear, provide options with trade-offs
- If risks are too high, recommend feasibility study

**If Specialist Delegation Fails:**
- If a specialist agent is unavailable, proceed with available agents and follow up later
- If specialist inputs conflict, escalate to chief_engineer for resolution
- If timeline is too tight, prioritize critical specialists (backend, database, security)

**If Specification Integration Fails:**
- If inputs are inconsistent, return to specialists for clarification
- If gaps exist, identify them explicitly in the specification
- If user rejects specification, iterate based on feedback

## Example Run

**User:** /start-project

**project_orchestrator:** I'll help you bootstrap a new project. This will involve a discovery interview to gather requirements, followed by architectural planning and Sprint 0 creation. Let's start with understanding the problem you're trying to solve.

**project_orchestrator:** What problem are you trying to solve with this project?

**User:** We need to build an e-commerce platform for selling handmade crafts. Current solutions are too generic and don't support the unique needs of craft sellers.

**project_orchestrator:** Who are the target users for this platform?

**User:** Two types: craft sellers who want to list their products, and buyers who want to discover and purchase unique handmade items.

**project_orchestrator:** What are the key features you need?

**User:** Seller features: product listings, inventory management, order processing. Buyer features: product discovery, search, checkout, order tracking.

**project_orchestrator:** What are your technical preferences or constraints?

**User:** We prefer Node.js for backend, React for frontend. Need to support payment processing eventually.

**project_orchestrator:** What's your timeline?

**User:** We'd like an MVP in 3 months.

*(Interview continues for approximately 15 turns total)*

**project_orchestrator:** Based on our interview, I'm now delegating to the chief_engineer for initial architectural design.

**chief_engineer:** *(Returns with ADR-001: E-commerce Platform Architecture)*

**project_orchestrator:** Thank you. I'm now delegating in parallel to specialist agents for domain-specific designs.

*(Parallel delegation to 7 specialist agents)*

**project_orchestrator:** I've integrated all specialist inputs into your project specification. Here's the summary:

**Project Specification:**
- **Problem:** E-commerce platform for handmade crafts
- **Users:** Sellers and buyers
- **Features:** Product listings, inventory, orders, search, checkout
- **Tech Stack:** Node.js, React, PostgreSQL
- **Timeline:** MVP in 3 months

**Architecture (ADR-001):**
- 3 services: User Service, Product Service, Order Service
- RESTful APIs with OpenAPI documentation
- PostgreSQL for transactional data
- Event-driven communication for cross-service updates

**Sprint 0 Tasks:**
- Set up project structure and CI/CD
- Implement User Service foundation
- Set up database infrastructure
- Implement authentication system
- Create basic UI components

**Risks:**
- Payment processing complexity (mitigated by deferring to phase 2)
- Search scalability (mitigated by using PostgreSQL full-text search initially)

**Status:** Ready for your approval to begin Sprint 0.

**User:** Approved, let's begin Sprint 0.

**project_orchestrator:** Sprint 0 initiated. Delegating implementation tasks to specialist agents.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
