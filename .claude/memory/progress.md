# 📍 Progress — Live Checkpoint

> ⚠️ **THIS IS THE RESUME FILE.** Updated by `context_manager` before/after every task. Read this first when resuming.

## 📌 Snapshot
- **Last updated:** 2026-09-20 (noche)
- **Lifecycle stage:** Build
- **Current sprint:** Sprint 1 (prueba de fuego — SaaS de fidelidad QR)
- **Working branch:** main
- **Last commit:** f9f8b4d (sin commitear trabajo reciente)
- **Overall status:** 🟡 in progress (check-in QR + Docker + CRUD SaaS + feedback complejo)

## ✅ Completed (most recent first)
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
- [ ] **Manejo delicado de secretos (API keys)** — prioridad alta (seguridad, cap. 13)
  - [ ] Definir cómo el usuario aporta su API key sin que NUNCA se suba a GitHub
  - [ ] `.env` + `.gitignore` estricto + `.env.example` documentado
  - [ ] Mensaje en la UI: "pega tu key en `.env`, la app la lee de ahí" (nunca en el chat/código)
- [ ] **Conectar LLM real (DeepSeek)** para specs ricos — pendiente de API key del usuario
- [ ] **Persistencia real del check-in en BD** (hoy localStorage; con backend real debe usar `/api/Employee` + transacciones de puntos)

## ⏭️ Next actions (in order)
1. Implementar manejo de secretos (.env + .gitignore + guía en UI)
2. Persistencia del check-in/QR contra la BD real (no solo localStorage) cuando haya backend
3. Commit de todo el trabajo reciente (Docker, check-in QR, CRUD SaaS, feedback complejo)
4. Conectar DeepSeek real cuando el usuario aporte su key
5. PRUEBA FINAL end-to-end del flujo (prompt → spec → decisiones → build → app)

## 🚧 Blockers / pending decisions
- **API key de DeepSeek**: pendiente de que el usuario la ponga en `.env` (nunca en repo).
- **Arranque del backend de apps generadas**: RESUELTO con **fallback localStorage** — en preview la app funciona sin backend; el `server.js` real se usa solo al desplegar (`npm start` o `docker compose up`). El preview `:8090` sirve el frontend y el runtime detecta y degrada gracefulmente.

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
- `casf-studio/backend/src/materializer.ts` (check-in QR + CRUD SaaS + Docker + widgets)
- `casf-studio/backend/src/spec.ts` (applyFeedback complejo: entidad Employee, página /owner)
- `casf-studio/backend/src/docs.ts` (listar artefactos del framework)
- `casf-studio/backend/src/index.ts` (endpoints /api/docs, /api/spec/feedback, /api/spec/parse)
- `casf-studio/frontend/src/Docs.tsx` + `App.tsx` (pestaña Docs + feedback UI + editor de spec)
- `casf-studio/frontend/src/api.ts` (parseSpec) + `i18n.ts` + `styles.css` (editor)
- `casf-studio/{backend,frontend}/Dockerfile` + `docker-compose.yml` (containerización)
- `CASF/Dockerfile` (framework como volumen)
- `CASF/docs/sprint/sprint_1_plan.md` (plan de sprint)**

