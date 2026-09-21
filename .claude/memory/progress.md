# 📍 Progress — Live Checkpoint

> ⚠️ **THIS IS THE RESUME FILE.** Updated by `context_manager` before/after every task. Read this first when resuming.

## 📌 Snapshot
- **Last updated:** 2026-09-20 (noche)
- **Lifecycle stage:** Ship (cierre de Sprint 1)
- **Current sprint:** Sprint 1 (prueba de fuego — SaaS de fidelidad QR) — COMPLETADO
- **Working branch:** main
- **Last commit:** docs(roadmap): añadir Etapa 5.5 control de límites anti-pérdidas (P0)
- **Overall status:** 🟢 sprint completado + pulido + widgets verticales + hardening seguridad + arquitectura limpia + roadmap actualizado con control de límites

## ✅ Completed (most recent first)
- [x] **Documentación de control de límites (Etapa 5.5)**: añadida al roadmap (`ETAPAS_SIGUIENTES.md`) como P0 (crítico antes de beta pública). Especifica límites hard por plan (Free: 3 apps/mes, Pro: 50 apps/mes), contadores en tiempo real, validación server-side antes de consumir recursos, reset mensual automático, dashboard de uso, manejo de casos extremos (cancelaciones, bypass, transacciones atómicas). Criterios de done verificables + tests automatizados. Costo estimado: ~$8-12 tokens. **Protege el margen de negocio** — sin esto el producto puede operar a pérdida desde el día 1.
- [x] **Backend generado en capas (no monolito) + SQLite real**: `serverJs()` monolítico reemplazado por 5 archivos con capas (`src/server.js` bootstrap, `src/app.js` middleware+rutas, `src/db.js` SQLite `node:sqlite`, `src/auth.js` JWT+identidad, `src/crud.js` fábrica CRUD). Persistencia SQLite real (UUID + `created_at` auditoría, sin `Map()` en memoria). Validación de tipos por whitelist (rechaza campos no declarados, no mass-assignment de `id`/`created_at`), paginación `?page=&limit=` → `{data,page,limit,total,totalPages}` (sin `page` devuelve array plano por compatibilidad con el frontend). Dockerfile Node 22 multi-stage con `--experimental-sqlite`; docker-compose con volumen `DB_PATH`. **Smoke test real verificado**: health + register/login (JWT+UUID) + CRUD + paginación + validación 400.
- [x] **Arquitectura limpia en proyectos generados (frontend/ + backend/)**: `materialize()` genera monorepo separado — `frontend/`, `backend/`, raíz (project.md, README, manifest, Docker, compose, CI). `rmSync` limpia antes de regenerar. Preview apunta a `/slug/frontend/index.html`.
- [x] **Sección `## Architecture` en el spec**: `SYSTEM_PROMPT` (LLM real) y mock (`architectureFor`) generan arquitectura. `parseProjectMd` la lee, `specToMarkdown` la emite, `manifest.json` la persiste. Tipo `ProjectSpec.architecture?: string[]`.
- [x] **Documentación de la convención en framework**: `PATRON_DE_DISENO.md` ganó "3bis. Patrón de Arquitectura de Proyectos Generados" (backend en capas + SQLite + validación + paginación). `backend_architect`, `frontend_architect` y `devops_engineer` exigen estructura limpia + Docker coherente.
- [x] **Purga de historial Git (secretos)**: reescrito el historial completo de `casf-studio` y `CASF` con `git filter-repo --replace-text` + force-push a GitHub. Verificado con `git log -S` que los secretos ya no aparecen (0 ocurrencias). Lección LL-015 registrada.
- [x] **Hardening de secretos (GitGuardian)**: eliminados 4 secretos hardcodeados (`***REMOVED***`, `JWT_SECRET` fijos en `auth.ts`, `seed-admin.ts` y el runtime generado). Ahora: secreto JWT aleatorio en dev (`randomBytes`), fail-fast en producción si falta env, `.env` real con secretos guardado localmente (gitignored, verificado con `git check-ignore`), y `--env-file-if-exists=.env` en los scripts npm. Lección LL-014 registrada.
- [x] **Widgets de restaurante y salud**: `renderRestaurant` (mesas libre/ocupada + menú digital con toggle de disponibilidad + pedidos con flujo cocina: enviar a cocina → marcar servido → liberar mesa) y `renderHealth` (agenda del día con form de citas paciente/médico/fecha/hora + tabla de pacientes + tarjetas de médicos). Ambos con datos demo (`seedRestaurant`/`seedHealth`) y verificado en navegador.
- [x] **Widget de tienda (e-commerce)**: `renderShop` con catálogo (búsqueda + filtro por categoría), carrito lateral con cantidades, checkout que crea `Order`+`OrderItem` y descuenta stock, toast no bloqueante. `seedShop` siembra productos demo. Verificado en navegador (añadir al carrito → contador, comprar → pedido).
- [x] **Widgets "muertos" arreglados**: `renderApp` reordenado — los widgets específicos (fidelidad, tienda, gastos, todo, blog, landing) ahora tienen prioridad sobre el CRUD genérico. Antes el CRUD los pisaba siempre (todo/gastos/blog/landing nunca se renderizaban). Verificado: todo→widget, tienda→widget, resto→CRUD.
- [x] **Fix de colisiones de keywords en widgets**: `factura` sacado de Expense (capturaba Invoicing SaaS), `saas/sass` sacado de Landing (capturaba cualquier SaaS), `catálogo` sacado de Shop (colisionaba con "catálogo de cursos" del LMS). 12 dominios verificados → widget correcto.
- [x] **Fix del bucle de reinicio del dev-server**: `node --watch` observaba `data.db`/`state.json`/`generated/` que el propio servidor escribe → reinicio infinito (consumía CPU). `--watch-path=./src` lo acota al código. El monitor de terminal disparaba 70+ notificaciones por esto.
- [x] **Pulido del flujo completo (CASF Studio)**: modo interactivo ya NO pierde decisiones — `handleBuild` auto-refina si el usuario no aplicó sus respuestas; indicador "Cambios sin aplicar" (chip warn); cache-busting del iframe de preview (`?v=`) al reconstruir; limpieza de estado (feedback/steps/activeFile) al regenerar y al logout; botón alternar resumen/memory.md claro. Verificado en navegador (moneda PEN→S/ aplicada sin "Aplicar decisiones").
- [x] **5 dominios verticales ricos nuevos en `llm.ts`**: E-commerce Suite, Restaurant & Delivery, Health & Clinic Suite, Learning Management System, HR & Payroll Suite — cada uno con entidades completas, páginas y features ambiciosas (full-stack React/Express/Postgres). `isAmbitious` ampliado con verticales nuevos.
- [x] **Fixes de colisión de keywords** (bug real encontrado): `hasWord` matcheaba `"lead"` dentro de `"empleados"` (substring) → CRM incorrecto. Arreglado: `lead`→`prospecto/leads`, `delivery` solo en Restaurant, `comida/cocina` solo en Restaurant, `producto/product` fuera de Inventory. Salud movido antes de Booking. Verificado con 9 prompts.
- [x] **Identidad automatizada en check-in QR**: capa `IdentityProvider` (mock + Open Gateway KYC-Match + JSON.pe). El cliente escribe SOLO su teléfono → el sistema resuelve nombre + DNI/CE automáticamente (verificado en navegador). Soporta DNI y Carné de Extranjería (CE → Migraciones).
- [x] **GitHub Actions CI/CD**: apps generadas + CASF Studio + framework con workflow `docker-build.yml` (build + publish a GHCR con `GITHUB_TOKEN`, sin secretos).
- [x] **Panel del dueño SIEMPRE presente**: dashboard de staff/barberos + actividad del bot ya no depende de keywords — toda app de fidelidad/citas lo muestra (nunca se pierde la vista del dueño).
- [x] **Docker en apps generadas + CASF Studio + framework**: toda app generada incluye `Dockerfile` + `docker-compose.yml` + `.dockerignore` (full-stack → Node+Postgres; static → nginx). CASF Studio tiene compose (backend+frontend con proxy nginx). El framework tiene su propio `Dockerfile` (volumen montable).
- [x] **Check-in por QR (fidelidad automática)**: el QR del negocio y el QR de cada cliente codifican una URL `#checkin[/id]`. Al escanear: registra la visita, suma puntos automáticamente y guarda al cliente en la BD. Vista de check-in es **solo la vista del cliente**; el dueño gestiona todo desde el panel SaaS.
- [x] **Panel SaaS completo con CRUD**: servicios, recompensas, clientes, citas, puntos y (con feedback) staff/barberos — todo gestionable con CRUD real, no solo catálogo.
- [x] **Feedback complejo en specs**: `applyFeedback` en `spec.ts` entiende peticiones ricas ("agrega un dashboard del dueño para ver a los barberos") → añade entidad `Employee`, página `/owner`, features y fuerza backend. Se registra en memoria.
- [x] **Edición directa del `project.md`**: botón "Editar spec" en el panel → textarea con el markdown → "Guardar" re-parsea vía `/api/spec/parse` (`parseProjectMd`) y regenera el spec normalizado. Control fino del usuario sobre el spec.
- [x] **Pestaña Docs/Sprints en CASF Studio**: endpoint `GET /api/docs` + componente `Docs.tsx` lee en vivo los artefactos del framework (`progress.md`, `decisions.md`, `lessons_learned.md`, sprints, patrón de diseño, ventajas).
- [x] **Sprint plan creado**: `docs/sprint/sprint_1_plan.md` siguiendo el template del framework.
- [x] **Auto-levantamiento + preview en vivo ✓**: tras el build, CASF Studio abre un **iframe en vivo** de la app generada + botón "Abrir en pestaña nueva" (`:8090/<slug>`)
- [x] **Fallback inteligente en apps generadas**: `app.js` detecta si hay backend real (`fetch /health`); si no (preview estático), cae a localStorage y **se salta el muro de login** — la app SIEMPRE se ve y funciona sin levantar nada
- [x] **PRUEBA DE FUEGO SaaS ✓**: prompt breve "gestión de inventario" → spec rico (7 entidades, 7 páginas, 14 features) → decisiones (MXN) → build full-stack
- [x] **Memoria verificada con SaaS**: `memory.md` + `state.json` registran generate/refine/build + decisiones + proyectos; botón "Retomar" funciona
- [x] **Patrón de diseño documentado**: `PATRON_DE_DISENO.md` (bucle, capas, enriquecimiento, decisiones, memoria, seguridad, extensión)
- [x] **Log de progreso en vivo** en el chat (timeline: analizar → generar → decisiones → build), con estados activo/completado/error
- [x] **Pestaña Memoria** en CASF Studio: `memory.md` + `state.json` auto-actualizados, historial, decisiones, proyectos, botón "Retomar"
- [x] **Modo interactivo (decisiones de diseño)**: el framework propone preguntas (nombre, moneda, tema, idioma, login) y el usuario decide; endpoint `/api/spec/refine` + panel en frontend
- [x] **Modo manos libres**: el framework resuelve todo con defaults automáticamente
- [x] **Enriquecimiento de specs**: prompt breve → spec comercial (dominios ricos, entidades completas, features base+ambiciosas)
- [x] **Backend de apps generadas autocontenido**: `server.js` sirve API + frontend estático (una sola URL), JWT + CRUD
- [x] **Login/autenticación completo**: JWT + bcrypt + SQLite (`node:sqlite`), registro abierto, roles admin/user, seed-admin
- [x] **Capa de pricing/pagos**: planes Free/Pro/Enterprise + `MockPaymentProvider` (abstracción lista para Stripe/Mercado Pago)
- [x] **Dashboard de consumo**: tokens, costos, gráfico de evolución acumulada (área/línea/barras)
- [x] Visibilidad de costos por rol (admin ve $, usuario ve "incluido en plan")
- [x] Backend: proveedor DeepSeek + OpenAI + Anthropic + tabla de precios + margen interno
- [x] Botón de idioma ES/EN + spec como `project.md` legible
- [x] **Materializador mejorado**: apps funcionales (CRUD genérico por Data Model) + widgets por dominio + backend full-stack
- [x] **Estética rica en apps generadas**: CSS profesional, formato de moneda con símbolo, tema dark/light, i18n es/en

## 🔄 In progress
- [ ] **Conectar LLM real (DeepSeek)** para specs ricos — pendiente de API key del usuario
- [ ] **Persistencia real del check-in en BD** (hoy localStorage; con backend real debe usar `/api/Employee` + transacciones de puntos)

## ⏭️ Next actions (in order)
1. Persistencia del check-in/QR contra la BD real (no solo localStorage) cuando haya backend
2. Widgets para los últimos dominios ambiciosos (LMS, RRHH, inventario) — hoy caen en CRUD genérico
3. Conectar DeepSeek real cuando el usuario aporte su key

## 🚧 Blockers / pending decisions
- **API key de DeepSeek**: pendiente de que el usuario la ponga en `.env` (nunca en repo).
- **Identidad real (RENIEC/Open Gateway/Migraciones)**: la capa `IdentityProvider` está lista con mock; para producción requiere credenciales/convenio (Open Gateway KYC-Match, JSON.pe, RENIEC, Migraciones). El flujo y el modelo de datos no cambian.

## 🧠 Key context / recent decisions
- **Flujo QR de fidelidad**: el QR NO es solo identificación — es el mecanismo de **check-in automático**: escanear → registrar llegada → sumar puntos → guardar en BD. La vista `#checkin` es para el cliente; el panel SaaS (CRUD) es para el dueño.
- Costo del proveedor visible solo para admin; el usuario ve "incluido en tu plan".
- `mock` simula el precio de `deepseek-chat` para demo sin gasto.
- Margen interno (30%) se aplica solo en `/api/admin/cost` (auditoría del dueño).
- **Modo interactivo vs manos libres**: toggle en el frontend; las decisiones (moneda/tema/idioma/login/nombre) se aplican vía `/api/spec/refine` y regeneran `project.md`.
- **Feedback iterativo**: el usuario puede ajustar el spec con prompts en lenguaje natural (`/api/spec/feedback`) — tema, idioma, moneda, login, renombrar, añadir features, y peticiones complejas (entidades/páginas nuevas).
- Apps generadas: soportan moneda, tema, i18n, JWT, y ahora **Docker** (despliegue con un solo comando).

## 💰 Token & cost budget (last known)
- Model/API: mock (deepseek-chat), costo real simulado
- Último costo registrado: ~$0.000161 por generación

## 📁 Files currently being edited
- `casf-studio/backend/src/llm.ts` (5 dominios nuevos + fixes de colisión de keywords)
- `casf-studio/frontend/src/App.tsx` (auto-refine al build, indicador dirty, cache-busting preview)
- `casf-studio/frontend/src/i18n.ts` + `styles.css` (chip warn + traducciones)
- `casf-studio/frontend/src/Memory.tsx` (botón alternar resumen/memory.md)
- `casf-studio/backend/src/materializer.ts` (check-in QR + CRUD SaaS + Docker + widgets)
- `casf-studio/backend/src/spec.ts` (applyFeedback complejo: entidad Employee, página /owner)
- `CASF/docs/sprint/sprint_1_plan.md` (plan de sprint)

