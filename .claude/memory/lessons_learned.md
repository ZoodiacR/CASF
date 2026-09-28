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

### LL-018: La revisión de calidad funciona mejor como fricción temprana (spec) + fricción post-implementación (código)
- **Date:** 2026-09-22
- **Lesson:** Un único "review al final" no atrapa dos fallas de distinta naturaleza: (1) un **spec fino** que llega al materializador y produce una app genérica, y (2) una **implementación superficial** que se da por "hecha" sin cuestionar su arquitectura. La idea externa que se adaptó aquí aporta la solución: revisión **adversarial** (arquitecto en modo hipótesis + revisor en modo evidencia) tras la implementación, y un **gate de calidad del spec** antes del build.
- **Category:** Process
- **Context:** El usuario compartió una idea de "arquitecto + revisor" que discuten la arquitectura post-implementación, más un enfoque de **slices** (checkpoints con fix loops), y pidió integrarla al framework + crear un sub-agente que mida la calidad de los specs generados.
- **Action:** (1) Revisión post-implementación con dos roles: el arquitecto pregunta *intención* (ignorando el código) y el revisor **va al código** y marca cada hipótesis CONFIRMADA/REFUTADA/NO VERIFICADA con evidencia. (2) Slices con **máximo 2 intentos de fix** por hallazgo; lo no resuelto se anota PENDING y un **slice comodín** final (hasta 10 iteraciones) lo re-examina todo. (3) Cuando el fixer falla el mismo problema repetidamente, el revisor propone **refactor como fix**, no un tercer parche. (4) El spec se mide contra una **rúbrica ponderada** con red-lines (sin data model / sin arquitectura / sin auth = bloquea el build), benchmark: un spec rico de referencia (`PROJECT_SPEC.md`).

### LL-019: La "ambición" por keywords era un heurístico frágil que rompía la arquitectura
- **Date:** 2026-09-22
- **Lesson:** El stack (full-stack vs estático) se decidía con una lista de keywords "ambiciosas" (`isAmbitious`). Si el prompt no acertaba una keyword mágica, la app caía a **estático** (`frontend/` sin `backend/`), produciendo arquitecturas inconsistentes: de un lote de apps, solo UNA salía con el monorepo full-stack correcto. El criterio "¿es ambicioso?" es subjetivo y no correlaciona con la necesidad real de un backend. La necesidad real es: **¿la app maneja datos?** (tiene data model). Si sí, necesita backend; si no, es una landing pura.
- **Category:** Architecture
- **Context:** El usuario pidió que **todas** las apps generadas tengan arquitectura limpia full-stack, y reportó que solo una era correcta. La causa eran tres puntos que codificaban la heurística frágil: `isAmbitious` en el mock (`llm.ts`), la regla 1 del `SYSTEM_PROMPT` (LLM real), y el default estático en `parseProjectMd`.
- **Action:** Reemplazar la heurística por un **invariante declarativo**: *data model ⇒ full-stack*. (1) En el mock, `hasData = entities.length > 0` decide el stack. (2) En el `SYSTEM_PROMPT`, la regla dice "full-stack por defecto; estático solo para páginas sin data model". (3) En `parseProjectMd`, un paso de **normalización post-parseo** fuerza full-stack si hay data model aunque el LLM devolviera "None". (4) "Sin login" **ya no degrada a estático**: auth=false significa API pública (sin muro de login), no sin backend — el `guard` del CRUD generado y el `boot()` del runtime lo respetan. (5) Testear el **invariante** (todos los dominios con data model ⇒ backend), no la heurística.

### LL-020: Un build LLM monolítico se pasa del timeout — hay que "slicear" y reanudar por checkpoint
- **Date:** 2026-09-24
- **Lesson:** Pedirle a Claude Code (`claude -p`) que implemente la app COMPLETA (backend + frontend + docker + README) en una sola llamada se pasa del timeout (10 min) y muere justo cuando el frontend (la parte más grande) está a medias. La solución no es subir el timeout, sino **partir el build en slices** (backend → frontend → root) y darle a cada slice su propio `claude -p` + timeout. Además, un timeout **parcial** no debe descartar el trabajo ya escrito en disco: si el agente escribió los archivos pero no confirmó (`SLICE_OK`), el slice cuenta como completo si sus archivos están en disco (fallback), y se continúa con el siguiente.
- **Category:** Architecture
- **Context:** Implementando "Build LLM-driven" (que Claude Code, no el materializador determinista, genere el código) para VetSalud. El primer run monolítico reventó a los 10 min; el frontend quedó a medias.
- **Action:** (1) Dividir el build en slices atómicos con `files` objetivo por slice. (2) `runClaude` por slice con `try/catch`: un timeout no aborta el bucle completo. (3) `sliceComplete` usa **dos** fuentes: `memory.md` (`[x]`) y, como fallback, la presencia de los archivos en disco. (4) Un `memory.md` dentro del proyecto generado es el checkpoint: lo lee y actualiza el agente (mismo patrón que `progress.md` del framework), y el engine solo omite slices ya hechos. (5) Nunca `rmSync` el output al reanudar: el resume conserva lo ya generado y solo completa lo que falta.

### LL-021: El seed de una app de demo debe ser idempotente — nunca duplicar datos al rearrancar
- **Date:** 2026-09-24
- **Lesson:** Al levantar el backend generado para la demo, la BD reportó `clinics: 2` aunque solo había una clínica lógica. La causa: el seed se había ejecutado más de una vez (una vez por el propio Claude Code al verificar el build, y otra al rearrancar manualmente). Un seed no idempotente duplica datos demo y ensucia la experiencia de demo.
- **Category:** Technical
- **Context:** Levantando el backend de VetSalud (`backend/src/server.js`) para ver la demo completa con datos reales; el `/health/ready` devolvió `clinics: 2`.
- **Action:** (1) El seed de apps generadas **ya** usa `seedIfEmpty()` (solo siembra si la BD está vacía), que es correcto — el problema fue que la BD existente de la verificación del slice root no se limpió antes del arranque de demo. (2) El flujo de demo debe **resetear la BD demo** (`npm run reset` o borrar `data.db`) antes de arrancar, o (3) distinguir claramente "build/verificación" de "demo" para no arrastrar estado. (4) Documentar las credenciales demo que el seed imprime en el log (`admin@vetsalud.pe / VetSalud2026!`).

### LL-022: Capturar tokens reales exige `stream-json` + `--verbose`, no estimar chars
- **Date:** 2026-09-24
- **Lesson:** Claude Code con endpoint custom (DeepSeek) no reporta usage por defecto; la estimación `≈4 chars/token` es grosera y, peor, el build LLM-driven **no registraba nada** en el ledger (el Dashboard solo mostraba el spec). Con `--output-format stream-json` se puede streamear el texto al log en vivo Y capturar `usage.input_tokens`/`output_tokens` reales del evento `result`. Pero `stream-json` **requiere `--verbose`** (`Error: When using --print, --output-format=stream-json requires --verbose`).
- **Category:** Technical
- **Context:** Añadiendo contabilidad real de tokens/costos al build LLM-driven; el primer intento sin `--verbose` falló con exit code 1.
- **Action:** (1) Invocar `claude -p --output-format stream-json --verbose`. (2) Parsear por líneas: evento `assistant` (content + usage incremental) y evento `result` (texto final + usage autoritativo). (3) Acumular el usage por slice y escribirlo en `memory.md` para que un resume conserve el conteo. (4) Registrar cada build en el ledger (`addEntry`) con `costOf(model, usage)` para que el Dashboard refleje el gasto real.

### LL-023: El prompt cache no depende del PID ni de los headers — y leer solo `input_tokens` subestima el costo
- **Date:** 2026-09-28
- **Lesson:** Llegó la recomendación (de un colega) de que `claude -p` «rompe el caché» porque cada ejecución crea un proceso con PID distinto y encabezados variables, y de que había que usar el SDK con un proceso residente. **Es falso para nuestro stack, y la causa real era otra.** El caché se llavea por el **prefijo exacto de bytes del prompt** (orden `tools → system → messages`), no por proceso ni headers: dos procesos distintos con el mismo prefijo **sí** hacen cache hit. Y DeepSeek (que es el proveedor real detrás de CASF, vía su endpoint compatible con Anthropic) cachea **automáticamente**, sin código, sin `cache_control` y **sin recargo de escritura** — solo cobra hit ($0.003) o miss ($0.15). La causa real de un cache miss es contenido **dinámico** en el prefijo (fecha, cwd, estado de git): si el harness lo inyecta, cada proceso nuevo genera un prefijo distinto y se pierde el caché de todo el `CLAUDE.md`.
- **Category:** Architecture
- **Context:** Revisión del consejo «usa un wrapper con el Anthropic SDK y deja el proceso latente para hacer cache hit». Verificado contra la documentación oficial de Anthropic y de DeepSeek.
- **Action:** (1) **No** migrar a un proceso residente: no resuelve nada en DeepSeek y añade complejidad. (2) El problema real y comprobable era que leíamos **solo** `input_tokens`: en Anthropic ese campo es únicamente lo POSTERIOR al último breakpoint, y el total es `cache_read + cache_creation + input_tokens`. (3) Capturar los 4 campos y prorratear el costo (ver decisión del 2026-09-28). (4) Hacer **visible** el hit rate en el log en vivo y en el Dashboard: sin medición, cualquier teoría sobre el caché es especulación. (5) Si el hit rate sale 0% en una corrida real, la siguiente hipótesis a probar es el prefijo inestable, no el PID.

### LL-024: Empaquetar un plugin de Claude Code — tres trampas que fallan en silencio
- **Date:** 2026-09-28
- **Lesson:** Convertir CASF en plugin de Claude Code chocó con tres restricciones que **no dan error**: (1) **El campo `agents` del manifest no se honra en runtime.** `claude plugin validate` lo acepta y devuelve `√ Validation passed`, pero el loader registra **0 agentes**. La única ubicación fiable es el directorio por defecto **`agents/` en la raíz del plugin** (verificado con dos plugins de prueba en un directorio temporal: raíz → `Agents (1)`; campo `agents` apuntando a otro directorio → `Agents (0)`). (2) **`name` de subagente debe ser kebab-case.** La documentación es explícita («lowercase letters and hyphens... no underscores») y un nombre inválido hace que Claude Code **salte el archivo en silencio** (solo escribe al debug log). Los 14 agentes de CASF usaban `snake_case`, así que ninguno habría cargado. (3) **`CLAUDE.md` en la raíz de un plugin NO se carga como contexto** — la documentación dice que los plugins aportan contexto vía skills, agentes y hooks. Sin un skill, un tercero que instalara el plugin no recibiría la constitución.
- **Category:** Technical
- **Context:** Empaquetando el framework como plugin instalable (`/plugin marketplace add ZoodiacR/CASF`). El primer intento de instalación reportó `Skills (8) · Agents (0)`.
- **Action:** (1) Mover los agentes a la raíz con `git mv` y **eliminar** el campo `agents` del manifest. (2) Añadir frontmatter con `name` en kebab-case a los 14 agentes y `description` como *usage hint* (incluye el disparador; sin `:` porque rompe el parser YAML). (3) Entregar la constitución como `skills/casf-framework/SKILL.md`. (4) **Verificar siempre con `claude plugin details <name>`**, no con `validate`: el validador da verde en configuraciones que no cargan nada. (5) El falsable definitivo fue un experimento de dos plugins idénticos salvo la ubicación de los agentes — aislar la variable en vez de leer documentación contradictoria. (6) **Bug reportable** a `anthropics/claude-code`: el campo `agents` del manifest se valida pero no se carga.

### LL-025: Medir de verdad refutó la hipótesis — y destapó dos bugs que nadie miraba
- **Date:** 2026-09-28
- **Lesson:** LL-023 dejó escrito «si el hit rate sale 0% en una corrida real, la hipótesis a probar es el prefijo inestable». **Se midió, y era falsa.** Dos corridas de Claude Code dieron `input_tokens = 37303` **idéntico** en ambas, y el SHA-256 de `tools`, `system` y `messages` capturados por un proxy local coincidió byte a byte: el prefijo era perfectamente estable. A la vez, el mismo cuerpo **reenviado literalmente por nosotros** daba **99.5 % de aciertos**, y Claude Code daba **0 %** — confirmado por el propio upstream, no por el cliente. Se descartaron una a una todas las variables de transporte (query `?beta=true`, el header `anthropic-beta` completo de 8 valores, `Bearer` vs `x-api-key`, user-agent, session-id, latencia de calentamiento medida en +3 s, cuenta y protocolo) y **ninguna** rompía el caché. Conclusión honesta: la pérdida está en la ruta Claude Code → DeepSeek y no se pudo identificar la causa raíz; queda como hallazgo **abierto**, no como conclusión. Dos bugs reales aparecieron de camino: (1) **`~/.claude/settings.json` pisa las variables de entorno del proceso hijo** — el bloque `env` del archivo de usuario gana, y en esta máquina forzaba `ANTHROPIC_MODEL: "deepseek-chat"` (modelo **legacy discontinuado el 2026-07-24**) y `CLAUDE_CODE_MAX_CONTEXT_TOKENS: "64000"` en vez de los 200 000 declarados. Se detectó porque `ANTHROPIC_BASE_URL` fue ignorado y las peticiones no pasaban por el proxy. (2) **Claude Code entra en bucles de reintento** contra este endpoint: se observaron 12+ reintentos consecutivos con respuesta vacía, quemando cuota sin producir nada.
- **Category:** Process
- **Context:** Fase 4 de validación del caché, con la API real de DeepSeek. La medición costó unos pocos centavos y evitó una migración arquitectónica equivocada (montar el SDK con proceso residente, como sugería la recomendación original).
- **Action:** (1) **Medir antes de teorizar**: la hipótesis «obvia» (prefijo inestable) era refutable en un experimento de 15 segundos, y era falsa. (2) Cuando el mismo input da resultados distintos por dos rutas, **aislar la variable** hasta que solo quede una — y si al final no queda ninguna aislable, **decirlo** en vez de fabricar una causa. (3) Aislar con **proxy de intercepción + SHA de cada bloque del prefijo**: convierte «creo que el prompt cambia» en un hecho verificable. (4) Lanzar Claude Code con **`CLAUDE_CONFIG_DIR`** propio para que el `settings.json` del usuario no contamine las pruebas ni producción. (5) Acotar `maxRetries`/timeout en el provider para que un bucle de reintentos no queme cuota. (6) Arquitectura híbrida recomendada: Claude Code para el trabajo agéntico, API nativa de DeepSeek para la generación masiva con prefijo estático grande — el normalizador de `usage.ts` ya entiende ambos esquemas, así que el ledger no cambia.

### LL-026: Un comando que nombra un agente en prosa NO lo materializa — es role-play
- **Date:** 2026-09-28
- **Lesson:** Los 7 comandos de CASF referenciaban los agentes como **etiquetas de rol en prosa** (`### Step 1: Discovery Interview (project_orchestrator)`, `**code_reviewer:** *(Code review)*` en los ejemplos). Eso **no invoca nada**: le dice al modelo principal que *actúe como* ese rol. La verificación fue contundente: **cero** menciones de `subagent`, `spawn`, `Task` o `materializ` en los 7 comandos. Es decir, el framework **predicaba** la materialización (cap. 8.6 y `DELEGATION_BRIDGE.md`, que dice literalmente *«un `architecture_reviewer` inline es solo el autor asintiendo consigo mismo»*) pero **no la cableaba**. Los comandos y los subagentes son mecanismos **independientes**: los comandos los invoca **el usuario** (`/casf:new-sprint`) y su texto se inyecta como prompt; los subagentes los invoca **el modelo**, vía la herramienta `Task`, cuando el `description` encaja. Ninguno llama al otro automáticamente. Dos agentes clave además **ni siquiera aparecían** en `new-sprint`: `spec_quality_reviewer` y `architecture_reviewer`, que son el corazón del cap. 26.
- **Category:** Process
- **Context:** El usuario preguntó «o sea los agents van afuera y simplemente usa los comandos para llamarlos?». Su sospecha destapó el hueco: el flujo podía «funcionar» produciendo resultados, pero sin la separación adversarial que el framework exige.
- **Action:** (1) Añadir a cada comando **que delega** (new-sprint, review, ship, recover, start-project) una sección *Delegation — materialize, do not role-play* con una **tabla explícita**: qué rol se materializa, cuándo, y qué queda inline. (2) Declarar **explícitamente inline** los comandos que lo son por diseño (`status`, `resume`), para que no haya ambigüedad — en `status` los nombres de agente del reporte son **dueños de tarea**, no destinos de delegación. (3) Aclarar que `project_orchestrator` **es la sesión**, no un subagente que se materialice. (4) Regla dura: **un reviewer nunca es el autor**. (5) Materializar en **paralelo** lo independiente (el gate pre-merge). (6) Añadir los revisores que faltaban en `new-sprint` (spec gate + slice review) y describir el bucle de slices del cap. 26. (7) **No** delegar trivialidades (leer un archivo, un fix de una línea). Regla general: **un rol nombrado en un comando sin instrucción de spawn es documentación, no ejecución** — hay que decidir explícitamente cuál es cada uno.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
