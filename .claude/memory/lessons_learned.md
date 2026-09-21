# Lessons Learned

This file records lessons learned throughout the project, including what worked well and what didn't. These lessons inform future decisions and process improvements.

## Schema
Each lesson entry should include:
- **Date:** ISO date (YYYY-MM-DD)
- **Lesson:** What was learned
- **Category:** Process, Technical, Architecture, or Communication
- **Context:** Situation or project phase where the lesson was learned
- **Action:** What should be done differently in the future

## Canonical Lessons

### LL-001: Test Early and Often
- **Date:** 2026-08-06
- **Lesson:** Writing tests before or alongside implementation (TDD) catches bugs earlier and results in better code design. Waiting until the end to write tests leads to gaps in coverage and harder-to-test code.
- **Category:** Process
- **Context:** General software development best practice
- **Action:** Adopt test-driven development or at minimum, write tests concurrently with implementation. Never mark a task as done without tests.

### LL-002: Document Decisions as They're Made
- **Date:** 2026-08-06
- **Lesson:** Documenting architectural and product decisions immediately after they're made prevents knowledge loss and enables future understanding. Relying on memory leads to forgotten context and conflicting interpretations.
- **Category:** Process
- **Context:** General software development best practice
- **Action:** Create an ADR for every significant architectural decision. Record all decisions in the decisions log. Never make architectural decisions without documentation.

### LL-003: Invest in CI/CD Early
- **Date:** 2026-08-06
- **Lesson:** Setting up CI/CD pipelines early in the project prevents technical debt in deployment processes and enables fast, reliable releases. Manual deployment processes become fragile and don't scale.
- **Category:** Process
- **Context:** General software development best practice
- **Action:** Implement CI/CD pipeline in Sprint 0 or Sprint 1. Automate all quality gates. Never rely on manual deployment processes.

## Project-Specific Lessons

### LL-004: Token exhaustion loses the thread — checkpoint incrementally
- **Date:** 2026-09-20
- **Lesson:** A long autonomous session that runs out of tokens/context loses all in-flight state, and the user cannot easily resume. Waiting until the end to write a summary is insufficient — by then the state is already gone.
- **Category:** Process
- **Context:** First real use of CASF to build CASF Studio; the user explicitly reported losing the thread after token exhaustion.
- **Action:** `context_manager` must update `progress.md` BEFORE starting and AFTER finishing every task (or every 5 actions). The `progress.md` file is the single source of truth for resume. Enforce `/resume` as the canonical way to pick up work.

### LL-005: A human-readable spec beats JSON for reviewability
- **Date:** 2026-09-20
- **Lesson:** Representing the project spec as Markdown (`project.md`) — even though the engine needs structured data internally — massively improves the human's ability to review and trust the generated output. JSON is machine-friendly but not human-friendly.
- **Category:** Communication
- **Context:** User requested the spec be "understandable by us two" (human + framework), not JSON.
- **Action:** Prefer Markdown for any artifact that a human must read or sign off. Parse/derive structure programmatically as needed.

### LL-006: A zero-cost deterministic provider unlocks testing
- **Date:** 2026-09-20
- **Lesson:** A `mock` LLM provider (deterministic, $0) makes the entire pipeline testable and demoable without API keys, and catches integration bugs (e.g. name derivation from the wrong input) early.
- **Category:** Technical
- **Context:** Building the provider-agnostic LLM layer for CASF Studio.
- **Action:** Always ship a mock/fake provider alongside real ones; run smoke tests against it before touching paid APIs.

### LL-007: A resume file only works if it's updated *during* work, not after
- **Date:** 2026-09-20
- **Lesson:** Creating `progress.md` + `context_manager` + `/resume` is necessary but not sufficient. The first "resume" test revealed the checkpoint was stale (mentioned an old task and a wrong commit hash) and the token ledger was empty — because nobody updated them incrementally, only once at the end.
- **Category:** Process
- **Context:** Verifying the memory/resume mechanism after building it.
- **Action:** `progress.md` must be rewritten at the START and END of every working turn (not per project). `token_ledger.md` must be appended on every generation. The resume file is only as good as its last honest update; a stale checkpoint is worse than none because it sends the next session down the wrong path.

### LL-008: Editar el spec crudo (project.md) es tan valioso como el feedback por prompt
- **Date:** 2026-09-20
- **Lesson:** El feedback por lenguaje natural es cómodo, pero el usuario también quiere **editar el markdown directamente** ("a su antojo"). Exponer el artefacto crudo + re-parsearlo da control fino y transparencia total (ambos pueden leer el `project.md`).
- **Category:** Communication
- **Context:** El usuario pidió que los cambios del spec "también estén en la documentación" para editarlo manualmente.
- **Action:** Toda herramienta que genere artefactos legibles (spec, config) debe permitir **dos vías de edición**: (1) comandos/prompts y (2) edición directa del artefacto con re-parseo. Nunca esconder el markdown detrás de la UI.

### LL-009: Generar código dentro de template literals exige escapar `\n` y `/`
- **Date:** 2026-09-20
- **Lesson:** El materializador inyecta un `app.js` completo dentro de un template literal de TypeScript. Escapes como `\n` (join) o `/` (regex) rompen el JS generado si no se duplican (`\\n`, `\\/`). Los errores aparecen como `SyntaxError` en el **archivo generado**, no en el fuente, lo que despista.
- **Category:** Technical
- **Context:** Bugs de `app.js` generado al añadir el check-in QR y los mensajes del bot.
- **Action:** Al escribir generadores de código, tratar el template literal como "código fuente embebido": revisar escapes de backslash y regex, y testear el **output** generado (no solo compilar el generador). Cache-busting (`?v=`) en el preview ayuda a no servir versiones viejas.

### LL-010: Docker "por defecto" baja la fricción de despliegue a cero
- **Date:** 2026-09-20
- **Lesson:** Añadir `Dockerfile` + `docker-compose.yml` a **toda** app generada (y a Studio y al framework) hace que "funciona en mi máquina" deje de ser un problema: un solo `docker compose up` levanta el stack completo.
- **Category:** Architecture
- **Context:** El usuario pidió Docker en todo lo generado por su utilidad.
- **Action:** Incluir artefactos Docker en la salida del materializador por defecto, con variantes según stack (full-stack → Node+Postgres; static → nginx). Documentar el comando en el README generado.

### LL-011: No afirmar "no se puede" sin investigar la web actual
- **Date:** 2026-09-20
- **Lesson:** Afirmé que "un navegador no puede leer el teléfono" y "no hay BD teléfono→DNI" como si fuera imposible. El usuario insistió y, al investigar fuentes oficiales 2026, descubrí que **sí es posible**: GSMA Open Gateway KYC-Match (la operadora identifica al usuario por SIM/IP y valida DNI↔teléfono), RENIEC Web Service (DNI) y Migraciones (CE), o agregadores (JSON.pe). Mi error fue confundir "requiere integración/convenio" con "imposible".
- **Category:** Communication
- **Context:** Diseñando el check-in QR automático para el SaaS de fidelidad.
- **Action:** Antes de declarar inviabilidad técnica, **buscar en la web** (WebSearch) la solución vigente. Distinguir entre "no hay API pública gratuita" y "no existe forma de hacerlo". El usuario suele tener razón sobre lo que el mercado ya hace.

### LL-012: El substring matching sin límites de palabra crea falsos positivos
- **Date:** 2026-09-20
- **Lesson:** La detección de dominios usaba `p.includes("lead")`, que es `true` para "emp**lead**os" (la palabra española "empleados" contiene la subcadena inglesa "lead"). Resultado: "sistema de nómina y empleados" se clasificaba como **CRM** en vez de **HR**. El mismo bug con "delivery" (E-commerce vs Restaurant) y "comida/cocina" (Receta vs Restaurant).
- **Category:** Technical
- **Context:** Ampliando los dominios verticales del generador de specs (`llm.ts`).
- **Action:** Al hacer keyword matching sobre texto natural, usar límites de palabra (`\b`) o normalizar, y **testear con prompts reales** que contengan la colisión ("empleados" vs "lead"). Preferir keywords específicas del idioma ("prospecto/leads" en vez de "lead" a secas) cuando el préstamo lingüístico colisione con léxico nativo.

### LL-013: Un watcher que observa archivos que el servidor escribe entra en bucle
- **Date:** 2026-09-20
- **Lesson:** `node --watch` (sin `--watch-path`) observa **todo** el directorio, incluidos `data.db`, `data/state.json`, `memory.md` y `generated/` — que el propio servidor escribe en cada request (registro de actividad, build). Cada escritura dispara un reinicio, y el reinicio vuelve a escribir, en un bucle infinito que consume CPU y dispara decenas de notificaciones de monitor sin que nada parezca "romperse" (el log solo repite "running on" + "Restarting").
- **Category:** Technical
- **Context:** El backend de CASF Studio quedó en bucle de reinicio mientras trabajaba; un monitor de terminal con patrón `/running on|Error/` notificó 70+ veces.
- **Action:** Acotar el watch al código fuente con `--watch-path=./src` (o configurar `ignore`). Verificar con `grep -c Restarting` que el conteo sea 0 tras unos segundos. Los artefactos de runtime (BD, logs, memoria, output generado) nunca deben estar dentro del árbol observado.

### LL-014: Secretos hardcodeados como "default de dev" activan GitGuardian y son riesgo real
- **Date:** 2026-09-20
- **Lesson:** Usar `JWT_SECRET ?? "***REMOVED***"` o `ADMIN_PASSWORD ?? "***REMOVED***"` como "defaults para que corra sin configurar" dispara alertas de secret scanning (GitGuardian) en el repositorio remoto, y son un riesgo real: una contraseña de admin fija o un secreto JWT predecible permite forjar tokens y suplantar usuarios si alguien despliega sin cambiar el default.
- **Category:** Security
- **Context:** El usuario reportó un correo de GitGuardian con "incidentes de privacidad/secretos" en los repos. La causa eran 4 defaults hardcodeados en `auth.ts`, `seed-admin.ts` y el runtime generado por `materializer.ts`.
- **Action:** Nunca ship un secreto fijo. Patrón correcto: (1) en producción, `process.env.X` es obligatorio y se hace fail-fast si falta; (2) en desarrollo, generar un valor aleatorio efímero (`randomBytes`); (3) guardar los secretos reales de prueba en `.env` (gitignored), no en el código; (4) verificar con `git check-ignore` que el archivo no se rastrea. El correo de GitGuardian trae el hash exacto del commit ofensor — los defaults "inocentes" siguen contando como incidente porque viven en el historial.

### LL-015: Corregir un secreto en HEAD no basta — hay que reescribir el historial completo
- **Date:** 2026-09-20
- **Lesson:** GitGuardian (y cualquier secret scanner) escanea **todo** el historial, no solo el HEAD. Corregir el default hardcodeado en el commit actual no apaga la alerta: el valor filtrado sigue vivo en los commits viejos. La única forma de limpiarlo es reescribir el historial con `git filter-repo --replace-text` y force-push.
- **Category:** Security
- **Context:** Tras corregir los defaults (LL-014), el usuario pidió purgar el historial de ambos repos (`casf-studio` y `CASF`) para que GitGuardian dejara de reportar los commits ofensores.
- **Action:** Procedimiento verificado: (1) `pip install git-filter-repo`; (2) crear un archivo de reemplazo `OLD==>***REMOVED***`; (3) backup con `git bundle create`; (4) `git filter-repo --replace-text <archivo> --force` (atención: borra el remote `origin`); (5) re-agregar `git remote add origin <url>`; (6) verificar con `git log --all -S <secreto> --oneline | wc -l` que el conteo es 0; (7) `git push --force origin main`; (8) borrar los bundles de backup (contienen el historial viejo con los secretos). Efectos: **todos los SHAs cambian** y se rompen clones/PRs existentes — es irreversible. Hacer backup ANTES y verificar DESPUÉS.

### LL-016: El spec debe declarar la arquitectura, no asumirla — y el materializador debe reflejarla
- **Date:** 2026-09-20
- **Lesson:** El materializador generaba todo plano en la raíz (`index.html` + `server.js` + `schema.sql` juntos), contradiciendo lo que los agentes del framework (backend_architect, frontend_architect) exigen (capas separadas, frontend/ + backend/). La raíz del problema era doble: (1) el spec no declaraba arquitectura alguna, y (2) el materializador no tenía una convención que respetar. Sin una sección `## Architecture` en el spec y sin una regla en el blueprint, cada generación "improvisaba" la estructura.
- **Category:** Architecture
- **Context:** El usuario detectó que los proyectos generados no seguían ninguna arquitectura limpia (front/back por carpetas), a diferencia de lo que hacía su agente antes.
- **Action:** (1) El `SYSTEM_PROMPT` y el mock **deben** generar una sección `## Architecture` (monorepo layout, capas, comunicación, auth, persistencia, robustez); (2) el materializador debe seguir **siempre** el monorepo `frontend/` + `backend/` + raíz (docker/CI/docs); (3) limpiar el directorio del slug con `rmSync` antes de regenerar para no dejar archivos huérfanos de layouts anteriores; (4) documentar la convención en el blueprint y en los agentes para que no se repita. Docker y preview deben apuntar a las rutas nuevas (`/slug/frontend/index.html`, `backend/.env`).

### LL-017: El backend generado debe estar en capas y persistir de verdad — no un monolito con Map()
- **Date:** 2026-09-20
- **Lesson:** Un "backend" de un solo archivo con todo inline (rutas + auth + CRUD) y un `Map()` en memoria no es "sólido y escalable", aunque la carpeta se llame `backend/`. El spec declaraba React + PostgreSQL pero el materializador entregaba vanilla JS + un `Map()`, una brecha de credibilidad que un usuario detecta al instante. Además, el campo de auditoría `created_at` que añadía el enriquecimiento colisionaba con el `created_at` de la DDL generada (duplicado → crash de SQLite en el arranque).
- **Category:** Architecture
- **Context:** El usuario pidió "arquitectura full stack" real y "comenzar el roadmap" para que el producto sea comercializable. La evaluación honesta del estado anterior era: forma correcta (carpetas) pero fondo insuficiente (monolito + memoria).
- **Action:** (1) Generar backend en capas: `server.js` (bootstrap) → `app.js` (middleware+rutas) → `auth.js`/`crud.js` (controladores) → `db.js` (infraestructura SQLite `node:sqlite`, cero deps nativas). (2) Persistencia real con `id TEXT` (UUID vía `randomUUID`) y `created_at` de auditoría; prohibir `Map()` en apps full-stack. (3) Validación por whitelist en el borde (rechaza tipos inválidos y campos no declarados; sin mass-assignment de `id`/`created_at`) + paginación `?page=&limit=`. (4) Filtrar los campos de auditoría (`id`, `created_at`) en DDL y CRUD para evitar duplicados — el enriquecimiento los añade como fields del spec, pero en el backend son gestionados por la DB. (5) Verificar con smoke test real (arrancar el backend generado, probar register/login/CRUD/paginación/validación), no solo `node --check`.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
