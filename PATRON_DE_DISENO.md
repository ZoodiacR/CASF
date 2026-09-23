# 🧩 CASF — Patrón de Diseño (Architecture Blueprint)

> El patrón canónico para "sacarle todo el jugo" al framework CASF + CASF Studio.
> Define **cómo se estructura el bucle de trabajo**, qué capa resuelve cada cosa, y cómo extenderlo sin romperlo.
> Es la versión codificada de lo que hace a CASF un producto y no un juguete.

---

## 1. El Bucle Central (Pipeline)

CASF no "genera código": ejecuta un **pipeline gobernado** con memoria y contabilidad. Todo pasa por el mismo bucle:

```
   ┌─────────────────────────────────────────────────────────────┐
   │                     BUCLE CASF (único camino)               │
   │                                                             │
   │  IDEA ──► SPEC ──► DECISIONES ──► MATERIALIZACIÓN ──► APP   │
   │   │         │            │               │            │     │
   │   │         │            │               │            │     │
   │   └──── MEMORIA (state.json + memory.md) ◄────────────────┘ │
   │        └──── CONTABILIDAD (ledger + costo) ◄───────────────┘ │
   └─────────────────────────────────────────────────────────────┘
```

**Regla de oro:** cada fase **escribe en memoria y en el ledger** antes de terminar. Nada es "efímero"; todo es reanudable.

---

## 2. Capas y Responsabilidades (Separación de Concerns)

Cada capa tiene **una sola responsabilidad** y una dependencia unidireccional (la capa de arriba depende de la de abajo, nunca al revés):

| Capa | Archivo(s) | Responsabilidad única | NO debe hacer |
|---|---|---|---|
| **Interfaz** | `frontend/src/App.tsx` | Orquestar la UI: modos, timeline, decisiones | Lógica de negocio / reglas de dominio |
| **Orquestación** | `backend/src/index.ts` | Endpoints + middleware + routing | Generar specs o materializar |
| **Dominio del spec** | `backend/src/spec.ts` | Convertir idea→spec, parsear/proponer/aplicar decisiones | Llamar APIs de LLM |
| **Enriquecimiento** | `backend/src/llm.ts` | Detectar dominio + garantizar calidad mínima del spec | Persistir o cobrar |
| **Materialización** | `backend/src/materializer.ts` | Convertir spec→archivos (HTML/CSS/JS + backend) | Decidir el dominio |
| **Proveedores LLM** | `backend/src/llm.ts` (providers) | Adaptar cada vendor (OpenAI/Anthropic/DeepSeek/mock) | Conocer el dominio |
| **Costo** | `backend/src/cost.ts` | Calcular costo por modelo + margen interno | Llamar a la red |
| **Contabilidad** | `backend/src/ledger.ts` | Registrar cada llamada (tokens/costo) | Mostrar UI |
| **Memoria** | `backend/src/memory.ts` | Persistir estado reanudable + `memory.md` | Contar costos |
| **Auth/Billing** | `db.ts`, `auth.ts`, `payments.ts` | Identidad, roles, planes, pasarela | Mezclarse con el pipeline |

> **Dependencia unidireccional:** `index.ts` orquesta; `spec.ts`/`materializer.ts`/`llm.ts`/`memory.ts` son funciones puras-ish que reciben entradas y devuelven resultados. Ninguna capa de dominio sabe de Express ni del frontend.

---

## 3. El Patrón de Enriquecimiento (garantizar calidad)

El problema que mata a los competidores: **un prompt breve produce una app pobre**. CASF lo resuelve con un **paso de enriquecimiento** que garantiza un mínimo comercial:

```
prompt breve ──► detectar dominio (keywords) ──► plantilla rica del dominio
                                                    │
                                                    ├─ entidades completas (con fields de identidad + auditoría)
                                                    ├─ páginas reales (dashboard, CRUD, settings)
                                                    ├─ features base (búsqueda, exportar, responsive)
                                                    ├─ features de dominio (auth, admin, roles, API) si aplica
                                                    └─ stack por INVARIANTE: data model ⇒ full-stack
```

**Reglas del enriquecimiento (implementadas en `llm.ts`):**

1. **Invariante de stack (data model ⇒ full-stack):** cualquier app con data model (entidades) es **full-stack**: `React + Node.js/Express + PostgreSQL`. Solo páginas de contenido puro sin data model (landing) son estáticas. NUNCA se decide por "ambición" (keywords subjetivas) — se decide por "¿maneja datos?".
2. **Entidades completas:** toda entidad recibe campo de identidad + `created_at`. Los dominios de negocio tienen entidades relacionadas (no una sola tabla).
3. **Features mínimas:** `búsqueda`, `exportar CSV`, `responsive` siempre. `auth`, `admin`, `roles`, `API REST` en apps con data model.
4. **Páginas reales:** dashboard + CRUD + settings, no "Home/About".
5. **Dominio agnóstico al tipo de negocio (PENDIENTE, 2026-09-23):** el dominio loyalty/citas (`Loyalty & Appointments Suite`) debe servir a **cualquier negocio de servicios** (barbería, salón de uñas, masajes, clínica, gimnasio, etc.), como el spec original `PROJECT_SPEC.md` ("Loyalify"). **Prohibido** hardcodear datos verticales de barbería: servicios de ejemplo ("Corte de cabello", "Manicure", "Masaje"), staff ("Barbero senior/junior"), textos `staff: 'Staff / barberos'` y respuestas del bot. El dueño **configura sus propios** servicios y empleados al crear su negocio; el seed debe ser neutro (p. ej. "Servicio 1" genérico) o vacío con onboarding guiado. Aplica a: `llm.ts` (richSections, `empleado/barbero`), `materializer.ts` (seed de services/staff + `T_EN.staff`/`T_ES.staff` + bot).

> Con un LLM real, este mismo enriquecimiento se hace en el `SYSTEM_PROMPT` (ver `spec.ts`), que **exige** Data Model completo y el mismo invariante (full-stack por defecto). El mock replica esa lógica de forma determinística, y `parseProjectMd` **normaliza** el stack post-parseo para garantizar el invariante incluso si el LLM devolviera "None".

---

## 3bis. El Patrón de Arquitectura de Proyectos Generados (estructura limpia)

**Regla no negociable:** todo proyecto generado por el materializador sigue una **arquitectura limpia de monorepo** con `frontend/` y `backend/` separados. Nunca se genera un "todo plano" en la raíz (ni `index.html` + `server.js` sueltos).

```
proyecto/
├── frontend/            # app estática autocontenida
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── backend/             # presente siempre que haya data model (invariante full-stack) — EN CAPAS
│   ├── package.json
│   ├── .env.example
│   ├── schema.sql       # SQLite (documentación del shape)
│   └── src/
│       ├── server.js    # entrypoint (bootstrap + listen)
│       ├── app.js       # express app + middleware + monta rutas
│       ├── db.js        # SQLite (node:sqlite) — capa de infraestructura
│       ├── auth.js      # JWT (register/login/me) + verificación de identidad
│       └── crud.js      # fábrica CRUD (validación + paginación)
├── project.md           # spec legible (fuente de verdad)
├── README.md            # arquitectura + estructura + arranque
├── manifest.json        # spec normalizado (machine-readable)
├── Dockerfile           # multi-stage Node 22 (full-stack) o nginx (static)
├── docker-compose.yml   # app + volumen SQLite (o solo web static)
├── .dockerignore
└── .github/workflows/docker-build.yml
```

**Reglas:**
   100|
1. **Separación de concerns:** el frontend nunca llama a rutas de disco del backend; se comunican por HTTP (`fetch('/api/...')`). El backend sirve el frontend como estático (single origin) o lo hace nginx en producción.
2. **Backend en capas (no monolito):** `server.js` (bootstrap) → `app.js` (middleware + rutas) → `auth.js`/`crud.js` (controladores/servicios) → `db.js` (persistencia). Nunca un solo archivo con todo inline.
3. **Persistencia real:** SQLite vía `node:sqlite` (cero dependencias nativas), con `id TEXT PRIMARY KEY` (UUID) y `created_at` de auditoría. El store en memoria `Map()` está **prohibido** para apps full-stack.
4. **Validación y paginación en el borde:** el CRUD valida tipos (whitelist), rechaza campos no declarados (no mass-assignment de `id`/`created_at`), y soporta `?page=&limit=` devolviendo `{ data, page, limit, total, totalPages }`. Sin `?page=`, devuelve array plano (compatibilidad con el frontend).
5. **El spec incluye una sección `## Architecture`** (monorepo layout, capas, comunicación, auth, persistencia). Tanto el `SYSTEM_PROMPT` (LLM real) como el mock (`architectureFor`) la generan. El `parseProjectMd` la lee y el `manifest.json` la persiste.
6. **Docker coherente con la estructura:** el `Dockerfile` full-stack es multi-stage Node 22 que copia `backend/` + `frontend/` y ejecuta `node --experimental-sqlite backend/src/server.js`; el estático usa nginx. El `docker-compose` monta un volumen para `DB_PATH`.
7. **El preview (`serve-generated.mjs`) y Studio apuntan a `/slug/frontend/index.html`**, no a la raíz.
8. **Robustez en el spec:** para apps con data model, la sección Architecture exige validación de entrada, queries parametrizadas, clasificación de errores (4xx/5xx), escrituras idempotentes (UUID), y paginación.
9. **Navegación por vistas (no single-page) — PENDIENTE (2026-09-23):** el frontend generado deja de ser **una sola página con todo apilado** y pasa a un **app shell con vistas por función** (`#/dashboard`, `#/clients`, `#/appointments`…). Cada vista renderiza **una** función; navegación por hash (sin framework); store compartido con `render*()` por vista (prepara el desmonte del `app.js` monolito, Etapa 1.2). Ver `DESIGN_SYSTEM.md` §8.

---

## 4. El Patrón de Decisiones (interactivo vs manos libres)
   110|

El usuario **controla el proceso** sin fricción:

```
                     ¿modo? 
                    ┌───────┴───────┐
              🎛️ INTERACTIVO      🛰️ MANOS LIBRES
                    │                   │
        el framework PROPONE      el framework RESUELVE
        preguntas (moneda,          con defaults
        tema, idioma, login)        automáticamente
                    │                   │
                    └────────► REFINE ◄─┘
                              (applyAnswers)
                                    │
                              spec refinado + project.md regenerado
```

**Decisiones soportadas:** nombre, moneda (USD/EUR/MXN/ARS/COP/PEN/CLP), tema (dark/light), idioma (es/en), login (sí/no).

**Regla:** una decisión **nunca** degrada el stack sin consecuencias conscientes. "Sin login" **no** baja a estático: significa API pública (sin muro de login), manteniendo el monorepo full-stack. "Con login" garantiza el muro de auth. Se registra en memoria como decisión.

---

## 5. El Patrón de Memoria (reanudación)

La memoria es **doble** y **auto-actualizada**:

| Forma | Archivo | Propósito |
|---|---|---|
| **Estructurada** | `data/state.json` | Estado reanudable (último prompt, eventos, decisiones, proyectos) |
| **Legible** | `data/memory.md` | Log humano renderizado (el usuario lo lee en la pestaña Memoria) |

**Reglas:**

1. **Cada fase registra un evento** (`generate`, `refine`, `build`, `auth`, `system`) con timestamp, tokens, costo.
2. **Las decisiones se de-duplican por `id`** (se conserva la última).
3. **El log se acota** (máx. 500 eventos) para no crecer sin límite.
4. **El botón "Retomar"** carga el último prompt en el chat para continuar donde se quedó.

> Esto espeja la memoria del framework CASF (`.claude/memory/`): `progress.md` (checkpoint) + `decisions.md` (decisiones) + `token_ledger.md` (costos). La diferencia es que en CASF Studio es **visible para el usuario en la propia web**.

---

## 6. El Patrón de Seguridad (secretos)

Los secretos **nunca** se piden en el chat ni se escriben en código:

```
❌ NUNCA:  "pega tu API key aquí en el chat"
✅ SIEMPRE: "pon tu API key en backend/.env (que está en .gitignore) y la app la lee de ahí"
```

**Reglas (cap. 13 del CLAUDE.md):**

1. Las API keys viven en `backend/.env`, **ignorado por git** (`.gitignore`).
2. `backend/.env.example` documenta las variables **sin valores reales**.
3. El backend lee `process.env.LLM_PROVIDER`, `DEEPSEEK_API_KEY`, etc. — nunca hardcodeado.
4. El costo/margen es visible solo para **admin**; el usuario ve "incluido en tu plan".

---

## 7. Cómo extender sin romper (puntos de extensión)

Para añadir una **nueva capacidad**, toca **una sola capa**:

| Quieres añadir… | Toca… | Ejemplo |
|---|---|---|
| Un nuevo dominio (recetas, reservas…) | `llm.ts` → `buildDomain()` | agregar un bloque de detección + entidades |
| Un nuevo proveedor LLM | `llm.ts` → clase provider + `getProvider()` | `OpenAIProvider`, `AnthropicProvider`, `DeepSeekProvider` |
| Una nueva decisión de diseño | `spec.ts` → `proposeQuestions()` + `applyAnswers()` | añadir "¿tema claro/oscuro?" |
| Un nuevo widget de UI generada | `materializer.ts` → `RUNTIME` | `renderCalendar()`, `renderKanban()` |
| Una nueva pasarela de pago | `payments.ts` → clase provider | `StripeProvider`, `MercadoPagoProvider` |
| Un nuevo tipo de evento en memoria | `memory.ts` → `MemoryEvent.type` | `"deploy"`, `"export"` |

**Principio:** extensión **por composición** (agregar un bloque) y **no por modificación** de la lógica central.

---

## 8. Checklist de "¿esto está bien diseñado?"

Antes de considerar terminado cualquier cambio en CASF:

- [ ] ¿Respeta la separación de capas (cada archivo hace una sola cosa)?
- [ ] ¿Escribe en memoria y ledger en cada fase?
- [ ] ¿El spec resultante es **rico** (entidades completas, no genérico) incluso con prompt breve?
- [ ] ¿Las decisiones del usuario se aplican y se registran?
- [ ] ¿Los secretos no se exponen en código/chat/repo?
- [ ] ¿Funciona en ambos modos (interactivo y manos libres)?
- [ ] ¿El costo es visible solo para admin?
- [ ] ¿Es reanudable (se puede retomar desde memoria)?

---

<!-- CASF · architecture-blueprint.md · v1.0 -->
