# Decisions Log

This file records all architectural and product decisions made during the project. Each decision includes the date, decision summary, rationale, and impact.

## Schema
Each decision entry should include:
- **Date:** ISO date (YYYY-MM-DD)
- **Decision:** Brief summary of the decision
- **Category:** Architecture, Product, Process, or Infrastructure
- **Rationale:** Why this decision was made
- **Impact:** What systems or processes are affected
- **ADR Reference:** Link to ADR if applicable

## Meta-Decision

### 2026-08-06: Adopted CASF Framework
- **Decision:** Adopt the CASF (Claude Autonomous Software Framework) for this project
- **Category:** Process
- **Rationale:** CASF provides a structured approach to software development with specialist agents, quality gates, and defined workflows. This enables consistent, high-quality software delivery with autonomous execution capabilities.
- **Impact:** All development will follow CASF processes, including agent delegation, quality gates, and documentation standards.
- **ADR Reference:** None (framework-level decision)

## Project Decisions

### 2026-09-20: Adopt monorepo for CASF Studio
- **Decision:** CASF Studio (the idea-to-app web product) uses a monorepo: `backend/` (Node + Express + TypeScript) and `frontend/` (React + Vite + TypeScript).
- **Category:** Architecture
- **Rationale:** Clear separation of concerns (API + LLM layer vs. UI), easy to reason about and deploy independently, matches the user's explicit "front y backend separados" requirement.
- **Impact:** `casf-studio/` repository structure; future deployment can host each side independently.

### 2026-09-20: ProjectSpec as Markdown (`project.md`), not JSON
- **Decision:** The spec artifact the LLM produces is a human-readable `project.md` (Markdown), not JSON. The framework parses it internally to materialize code.
- **Category:** Product
- **Rationale:** The user wants the spec to be readable by both the human and the framework. Markdown is legible, versionable, and reviewable; JSON is not.
- **Impact:** `backend/src/spec.ts` parses Markdown via `parseProjectMd`; the generated app stores `project.md` alongside code.

### 2026-09-20: Provider-agnostic LLM layer with zero-cost `mock`
- **Decision:** All LLM access goes through an `LLMProvider` interface; `mock` (deterministic, $0) is the default so the flow works without API keys. OpenAI/Anthropic supported via env vars.
- **Category:** Architecture
- **Rationale:** Enables demo/testing with no spend, avoids vendor lock-in, and feeds the token/cost accounting (`cost_accountant`).
- **Impact:** `backend/src/llm.ts`, `backend/src/cost.ts`; new providers are added as one class.

### 2026-09-20: Add `context_manager` + `cost_accountant` agents
- **Decision:** Two new framework agents: `context_manager` (owns `progress.md`, enables resume after token exhaustion) and `cost_accountant` (tracks tokens/cost for any LLM).
- **Category:** Process
- **Rationale:** Direct response to the user's pain: losing the thread after running out of tokens, and needing transparent cost accounting for monetization.
- **Impact:** `.claude/agents/`, `CLAUDE.md` delegation hierarchy, `/resume` command, `progress.md`, `token_ledger.md`.

### 2026-09-20: GitHub publishing via PAT (manual, guide provided)
- **Decision:** Repos (`casf-studio`, `casf` v1.0) are published to GitHub as PRIVATE, via a Personal Access Token. The MCP server config is in `.cursor/mcp.json`; full instructions in `GITHUB_GUIDE.md`.
- **Category:** Infrastructure
- **Rationale:** No `gh` CLI or token was available in this environment; a documented PAT flow is the most automated path the user can run themselves.
- **Impact:** `.cursor/mcp.json`, `GITHUB_GUIDE.md`.

### 2026-09-20: Authentication = local JWT + bcrypt + SQLite (open registration)
- **Decision:** CASF Studio auth is local: JWT (access token) + bcrypt password hashing, persisted in SQLite (`better-sqlite3`). Registration is open (anyone can sign up as a normal user); admin is assigned manually in the DB.
- **Category:** Architecture
- **Rationale:** Self-contained (no external identity provider needed for the MVP), transparent for a future SaaS migration (JWT is portable), and the SQLite file keeps the backend dependency-free. `bcryptjs` + `better-sqlite3` both ship prebuilt binaries, so no native compile on Windows.
- **Impact:** New `backend/src/db.ts` + `backend/src/auth.ts`, `requireAuth`/`requireAdmin` middleware, `/api/auth/*` routes; replaces the temporary `X-Role` header placeholder in `isAdmin`; frontend login screen + token persistence.
- **Note:** This supersedes the temporary role placeholder. The **first user** is a normal user (not admin) — admin must be granted by flipping `role` in the `users` table.

### 2026-09-20: QR = check-in automático (fidelidad), no solo identificación
- **Decision:** El QR de fidelidad (del negocio y de cada cliente) codifica una URL `#checkin[/id]`. Al escanearlo: se registra la llegada, se suman puntos automáticamente y se guarda al cliente en la BD. La vista `#checkin` es SOLO la vista del cliente; el dueño gestiona todo desde el panel SaaS (CRUD).
- **Category:** Product
- **Rationale:** El usuario aclaró que la idea es "automatizar la fidelidad y las llegadas": el QR es el mecanismo de check-in, no un simple código decorativo. Separa la experiencia del cliente (escanear y listo) de la gestión del dueño (dashboard + CRUD).
- **Impact:** `materializer.ts` (funciones `checkinUrl`, `doCheckin`, `renderCheckin*`, detección `#checkin` en `boot` + `hashchange`), KPI "visitas hoy".

### 2026-09-20: Feedback complejo en specs (enriquecimiento iterativo)
- **Decision:** El bucle de feedback (`/api/spec/feedback` + `applyFeedback`) no solo ajusta tema/idioma/moneda/login, sino que **entiende peticiones ricas**: "agrega un dashboard del dueño para ver qué hacen los barberos" → añade entidad `Employee`, página `/owner`, features concretas y fuerza backend.
- **Category:** Product
- **Rationale:** El usuario quiere poder pedir mejoras en lenguaje natural en cada build ("un par de prompts efectivos se ajuste para que quede a full"). El enriquecimiento determinista replica lo que haría un LLM fuerte.
- **Impact:** `spec.ts` (`applyFeedback` con detección `wantsOwner`/`wantsBotLog`), `materializer.ts` (`renderOwnerSection`, `seedStaff`, `logBot`), `index.ts` (endpoint `/api/spec/feedback`), `App.tsx` (cuadro de feedback).

### 2026-09-20: Docker en apps generadas + CASF Studio + framework
- **Decision:** Toda app generada incluye `Dockerfile` + `docker-compose.yml` + `.dockerignore`. Full-stack → imagen Node + Postgres; static → nginx. CASF Studio tiene compose (backend+frontend con proxy nginx `/api`). El framework CASF tiene `Dockerfile` (volumen montable en cualquier host agente).
- **Category:** Infrastructure
- **Rationale:** Despliegue con un solo comando (`docker compose up`), portabilidad, y consistencia con el cap. 16 (DevOps) de la constitución. El usuario lo pidió explícitamente por su utilidad.
- **Impact:** `materializer.ts` (`dockerfile`, `dockerCompose`, `dockerignore`), `casf-studio/{backend,frontend}/Dockerfile`, `casf-studio/docker-compose.yml`, `CASF/Dockerfile`.

### 2026-09-20: Identidad automatizada en el check-in QR (capa IdentityProvider)
- **Decision:** El check-in por QR resuelve la identidad del cliente de forma **automática** (teléfono → nombre + DNI/CE) mediante una capa `IdentityProvider` (mismo patrón que `LLMProvider`/`PaymentProvider`). Proveedores: `mock` (demo), `opengateway` (GSMA Open Gateway KYC-Match: valida DNI↔teléfono contra la operadora, sin que el usuario teclee), `jsonpe` (agregador autorizado JSON.pe para DNI, arranca hoy sin convenio). Soporta **DNI** y **Carné de Extranjería (CE)** — el CE lo verifica **Migraciones**, no RENIEC.
- **Category:** Architecture / Product
- **Rationale:** El usuario quiere la "maravilla": escanear el QR y que la identidad se resuelva sola. Investigado con fuentes oficiales 2026: SÍ es posible vía Open Gateway KYC-Match (operadora identifica por SIM/IP), RENIEC Web Service (S/0.40/consulta, convenio), Migraciones (CE), o agregadores (JSON.pe). No hay BD pública "teléfono→DNI"; la vía legítima es KYC contra la operadora o RENIEC/Migraciones.
- **Impact:** `backend/src/identity.ts` (nuevo: `IdentityProvider`, `MockIdentityProvider`, `OpenGatewayKycProvider`, `JsonPeDniProvider`, validadores `isValidDni`/`isValidCe`), `backend/.env.example` (`IDENTITY_PROVIDER`, `OG_*`, `JSONPE_TOKEN`).

### 2026-09-20: Moneda restringida a USD/PEN (switch dólares ↔ soles)
- **Decision:** El selector de moneda (pregunta de diseño interactiva) ofrece solo **USD** y **PEN** (soles), como switch binario, en lugar de las 7 monedas anteriores. El símbolo del sol es `S/`. El mapeo de feedback por lenguaje natural ya reconoce "dólares"/"soles"/"pen".
- **Category:** Product
- **Rationale:** El usuario está en Perú y solo maneja dólares y soles; el resto de monedas (EUR/MXN/ARS/COP/CLP) añadían ruido sin uso.
- **Impact:** `backend/src/spec.ts` (`proposeQuestions` → options `["USD","PEN"]`, label "¿Dólares o soles?"). El materializador ya formatea `PEN` → `S/`.

### 2026-09-20: Dominios verticales (fidelidad/citas/booking) son full-stack por defecto
- **Decision:** `isAmbitious()` en `llm.ts` ahora marca como full-stack (React + Node/Express + PostgreSQL) los dominios de fidelidad/QR/puntos/recompensas, citas/reservas/agenda, y verticales de servicios (peluquería/barbería/spa/gym/clínica). Antes, "app de fidelidad con QR, citas y puntos" generaba un stack **estático** (localStorage) a pesar de pedir "autenticación" y "panel de administración".
- **Category:** Architecture
- **Rationale:** Una app de fidelidad con citas y puntos es inherentemente multi-usuario con CRUD persistente; generar un mockup estático era un bug detectado en la prueba de fuego.
- **Impact:** `backend/src/llm.ts` (`isAmbitious`), prueba de fuego ahora produce 7 páginas + 14 features + stack full-stack.

### 2026-09-20: Edición directa del `project.md` por el usuario
- **Decision:** Además del feedback por lenguaje natural, el usuario puede **editar el `project.md` crudo a su antojo** desde CASF Studio: botón "Editar spec" → textarea con el markdown → "Guardar" → el backend re-parsea (`/api/spec/parse` + `parseProjectMd`) y regenera el spec normalizado. Cualquier ajuste queda reflejado en memoria.
- **Category:** Product
- **Rationale:** El usuario quiere control total: "lo que te digo que actualizar también debe estar en la documentación para que el usuario edite el spec a su antojo". El feedback por prompt es cómodo, pero editar el markdown directamente es la vía de control fino y transparente (ambos pueden leer el `project.md`).
- **Impact:** `backend/src/index.ts` (`POST /api/spec/parse`), `frontend/src/api.ts` (`parseSpec`), `frontend/src/App.tsx` (estado `editingSpec`/`specDraft` + botones "Editar"/"Guardar"/"Cancelar"), `i18n.ts` (claves), `styles.css` (`.spec-editor`).

---

### 2026-09-20: Pestaña Docs/Sprints en CASF Studio (transparencia del framework)
- **Decision:** CASF Studio expone un endpoint `/api/docs` + pestaña "Docs" que lee en vivo los artefactos del framework (`progress.md`, `decisions.md`, `lessons_learned.md`, `tech_debt.md`, `token_ledger.md`, sprints, patrón de diseño, ventajas) desde la carpeta del framework.
- **Category:** Product
- **Rationale:** El usuario quiere ver "todo el proceso, documentación y planificación de sprints" dentro de Studio para tener control y visibilidad del framework trabajando.
- **Impact:** `backend/src/docs.ts` (nuevo), `index.ts` (`/api/docs`), `frontend/src/Docs.tsx` (nuevo), `api.ts`, `App.tsx`, `i18n.ts`.

### 2026-09-20: Free es demo; Build se paga (créditos o Pro)
- **Decision:** Bajar Free a **spec demo (0 builds)**. Usar el producto = **crédito (~$4 / S/15 por build)** o **suscripción Pro $19 / Enterprise $99**. Packs 3×$10 y 10×$29. Ads en Free dejan de ser el plan A.
- **Category:** Product
- **Rationale:** Un Free que regala apps come COGS. $19 asusta a quien quiere una sola app; el crédito es el precio Yape-amigable. El crédito es más caro por unidad que Pro (~5 builds = $20) para no canibalizar el mensual.
- **Impact:** Solo documentación: `docs/VENTAJAS_COMPETITIVAS.md` §4. Código se cablea en el sprint de cobro.

### 2026-09-22: Cableado del cobro (créditos + 402 + límites) — código
- **Decision:** Implementar en código el modelo "Free demo + créditos + Pro": Free construye 0 apps (2 specs/mes), el build se paga con 1 crédito (packs 1×$4, 3×$10, 10×$29) o Pro/Enterprise (cupo 50/∞ builds/mes). Gate **server-side** en `/api/build` (`402 PAYMENT_REQUIRED` sin créditos) y en `/api/spec/generate` (límite de specs). Cobro solo al éxito del build.
- **Category:** Architecture + Product
- **Rationale:** El límite debe validarse en el servidor (no en el cliente) para que no se pueda saltar; el crédito se descuenta solo si el materializador termina ok. Los contadores mensuales se resetean automáticamente por mes (`usage_month`), los créditos no caducan.
- **Impact:** `db.ts` (columnas + migración idempotente + `credit_purchases`), `payments.ts` (`CREDIT_PACKS`, `PLAN_LIMITS`, `buyCredits`), `index.ts` (`authorizeBuild`/`authorizeSpec`, rutas `/api/billing/packs` y `/api/billing/credits`), frontend (`Pricing.tsx`, `api.ts`, `App.tsx`, `i18n.ts`). Smoke test `backend/smoke-monetization.mjs`.

### 2026-09-22: Revisión adversarial + slices + quality spec (Etapa 9)
- **Decision:** Integrar al framework un loop de calidad en dos puntos: (1) **post-implementación** — un `architecture_reviewer` adversarial que contrasta las hipótesis del `chief_engineer` (modo hipótesis) contra el código, y decide **refactor vs hardening**; la implementación se trata como un "cutre borrador" que se puede romper, pero justificando con qué se reemplaza. (2) **pre-build** — un `spec_quality_reviewer` que puntúa cada spec generado con una rúbrica de 12 dimensiones + red-lines (benchmark: `PROJECT_SPEC.md`). El desarrollo se divide en **slices** (checkpoints): slice → review → fix → hasta 2 intentos; lo no resuelto se anota PENDING y un **slice comodín** final (hasta 10 iteraciones) lo re-examina todo.
- **Category:** Process
- **Rationale:** Un solo review al final no atrapa ni un spec fino ni una implementación superficial. La fricción temprana (rúbrica del spec) evita builds genéricos; la fricción post-implementación (adversarial + slices) evita dar por "hecho" código que no aguanta el escrutinio. El límite de 2 intentos por hallazgo evita loops infinitos; el slice comodín evita que los pendientes se mueran silenciosamente.
- **Impact:** Nuevos agentes `architecture_reviewer` y `spec_quality_reviewer`; template `spec_quality_rubric.md`; workflow `slice_review_workflow.md`; `chief_engineer.md` (modo hipótesis); `sprint_workflow.md` (Stage 2.5); `CLAUDE.md` (cap. 26 + apéndice); `ETAPAS_SIGUIENTES.md` (Etapa 9). Pendiente: cablear el gate de calidad del spec como endpoint real en CASF Studio.

### 2026-09-24: Build LLM-driven por slices con resume (memory.md) + tokens reales
- **Decision:** El build de una app (cuando el proveedor es `claude-code`) deja de ser una sola llamada monolítica y pasa a **slices secuenciales** (`backend` → `frontend` → `root`), cada uno con su propio `claude -p --output-format stream-json --verbose` y timeout. El resume se apoya en un **`memory.md`** dentro del proyecto generado (escrito y leído por el agente): un slice con `[x]` — o con todos sus archivos en disco (fallback ante timeout parcial) — se omite. El uso de tokens se captura real (evento `result` del stream-json) y se acumula en el ledger y en `memory.md`.
- **Category:** Architecture
- **Rationale:** Un `claude -p` monolítico se pasa del timeout (10 min) y muere a mitad del frontend; dividir en slices acota el alcance de cada llamada y hace el proceso reanudable (no "empezar de cero" tras un fallo, que es desperdicio puro de tokens). Capturar el usage real (no `≈4 chars/token`) hace creíble la contabilidad de costos del producto.
- **Impact:** `llmBuild.ts` (slices + `runClaude` stream-json + `sliceComplete`/`markSliceDone` + acumulación), `claudeCodeProvider.ts` (stream-json para el spec), `index.ts` (`/api/build` registra tokens+costo en el ledger), `types.ts` (`BuildResult.usage`/`sliceUsage`). El materializador determinista sigue como fallback (`provider !== claude-code`).

### 2026-09-28: Contabilidad real de prompt cache (4 campos de usage, costo prorrateado)
- **Decision:** El `usage` deja de ser `{inputTokens, outputTokens}` y pasa a incluir `cacheReadTokens` y `cacheWriteTokens`, con la convención de que **`inputTokens` es el TOTAL** (cacheado + no cacheado) y los campos de caché son un **subconjunto** suyo. `costOf()` prorratea las tres categorías (uncached / read / write) con tarifas propias por modelo, y `costWithoutCache()` permite calcular el ahorro real. Un normalizador único (`src/usage.ts`) entiende los dos esquemas del cable (Anthropic con `input_tokens` + `cache_*`, y DeepSeek con `prompt_tokens` + `prompt_cache_hit/miss_tokens`) y lo usan los tres consumidores (`claudeCodeProvider`, `llmBuild`, providers de `llm.ts`).
- **Category:** Architecture + Product
- **Rationale:** Se leía **solo** `input_tokens`. En Anthropic ese campo es únicamente la parte POSTERIOR al último breakpoint de caché, así que el total real es `cache_read + cache_creation + input_tokens`. El efecto: cuando el caché funcionaba, **subestimábamos** el costo (los aciertos no se contaban); y cuando no funcionaba, no nos enterábamos. Rompía la contabilidad que alimenta el modelo de monetización. Además, un acierto de caché cuesta ~1/50 de un miss en DeepSeek, así que ignorarlo distorsionaba el COGS.
- **Impact:** `types.ts` (`Usage`), `cost.ts` (`Price.cacheRead/cacheWrite`, `splitInput`, `costOf` prorrateado, `costWithoutCache`, `cacheHitRate`), `usage.ts` (nuevo), `claudeCodeProvider.ts`, `llmBuild.ts`, `llm.ts`, `ledger.ts` (campos + agregados + `cacheHitRate`), `index.ts` (`cacheSavings` en `/api/cost`), frontend (`api.ts`, `Dashboard.tsx`, `i18n.ts`). 18/18 tests verdes (`test/usage.test.ts`). Decisiones de precio: DeepSeek `cacheWrite: 0` (no cobra escritura), Anthropic `1.25x` escritura / `0.1x` lectura. Si un modelo no declara tarifa de caché, se factura a tarifa plena (conservador, nunca subestima).

### 2026-09-28: CASF empaquetado como plugin oficial de Claude Code (agentes a la raíz `agents/`)
- **Decision:** El repo CASF es **marketplace + plugin a la vez**: `.claude-plugin/plugin.json` (manifest) + `.claude-plugin/marketplace.json` (catálogo), los 14 agentes se mueven de `.claude/agents/` a **`agents/` en la raíz**, cada agente recibe frontmatter YAML con `name` en **kebab-case**, y la constitución se entrega como skill (`.claude/skills/casf-framework/SKILL.md`) en vez de depender de `CLAUDE.md`.
- **Category:** Architecture + Process
- **Rationale:** Tres restricciones descubiertas y verificadas empíricamente contra Claude Code 2.1.281: (1) el campo `agents` del manifest **se acepta en `claude plugin validate` pero el loader NO lo honra en runtime** — se probó con dos plugins de prueba y la única forma fiable es la ubicación por defecto `agents/` en la raíz; (2) `name` de subagente debe ser **kebab-case** (rechaza guiones bajos) y Claude Code **salta el archivo en silencio** si es inválido, así que con los nombres `snake_case` previos ninguno habría cargado; (3) **`CLAUDE.md` en la raíz de un plugin NO se carga como contexto**, por lo que la constitución de 25 KB tiene que viajar como skill para llegar al contexto del consumidor.
- **Impact:** `agents/` (movido con `git mv`, historial preservado; 14 archivos con frontmatter), `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.claude/skills/casf-framework/SKILL.md`, `LICENSE` (MIT), `CHANGELOG.md`, `README.md` (instalación reescrita, conteo de agentes corregido 12 → 14), `CLAUDE.md` (12 referencias a `.claude/agents/` actualizadas), `.claude/commands/*.md` (frontmatter), `docs/PLAN_CACHE_Y_PLUGIN.md`. Verificado con `claude plugin details casf` → **Skills (8) · Agents (14)**. Consecuencia asumida: el uso como *proyecto* (CASF Studio ejecuta `claude -p` con el repo como cwd) obtiene los subagentes vía el plugin instalado, no vía `.claude/agents/`.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
