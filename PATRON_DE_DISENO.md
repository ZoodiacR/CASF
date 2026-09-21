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
                                                    ├─ features ambiciosos si aplica (auth, admin, roles, API)
                                                    └─ stack según ambición (static vs full-stack)
```

**Reglas del enriquecimiento (implementadas en `llm.ts`):**

1. **Stack según ambición:** SaaS/CRM/inventario/multi-usuario ⇒ `React + Express + PostgreSQL`. Simple ⇒ static + localStorage.
2. **Entidades completas:** toda entidad recibe campo de identidad + `created_at`. Los dominios de negocio tienen entidades relacionadas (no una sola tabla).
3. **Features mínimas:** `búsqueda`, `exportar CSV`, `responsive` siempre. `auth`, `admin`, `roles`, `API REST` si es ambicioso.
4. **Páginas reales:** dashboard + CRUD + settings, no "Home/About".

> Con un LLM real, este mismo enriquecimiento se hace en el `SYSTEM_PROMPT` (ver `spec.ts`), que **exige** Data Model completo y stack según ambición. El mock replica esa lógica de forma determinística.

---

## 3bis. El Patrón de Arquitectura de Proyectos Generados (estructura limpia)

**Regla no negociable:** todo proyecto generado por el materializador sigue una **arquitectura limpia de monorepo** con `frontend/` y `backend/` separados. Nunca se genera un "todo plano" en la raíz (ni `index.html` + `server.js` sueltos).

```
proyecto/
├── frontend/            # app estática autocontenida
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── backend/             # solo si es full-stack (ambicioso)
│   ├── server.js        # API Express + JWT + sirve ../frontend (single origin)
│   ├── schema.sql       # Postgres versionado
│   ├── package.json
│   └── .env.example
├── project.md           # spec legible (fuente de verdad)
├── README.md            # arquitectura + estructura + arranque
├── manifest.json        # spec normalizado (machine-readable)
├── Dockerfile           # multi-stage Node (full-stack) o nginx (static)
├── docker-compose.yml   # app + postgres (o solo web static)
├── .dockerignore
└── .github/workflows/docker-build.yml
```

**Reglas:**

1. **Separación de concerns:** el frontend nunca llama a rutas de disco del backend; se comunican por HTTP (`fetch('/api/...')`). El backend sirve el frontend como estático (single origin) o lo hace nginx en producción.
2. **El spec incluye una sección `## Architecture`** (monorepo layout, capas, comunicación, auth, persistencia). Tanto el `SYSTEM_PROMPT` (LLM real) como el mock (`architectureFor`) la generan. El `parseProjectMd` la lee y el `manifest.json` la persiste.
3. **Docker coherente con la estructura:** el `Dockerfile` full-stack copia `backend/` y `frontend/` por separado (multi-stage Node + Postgres); el estático usa nginx copiando solo `frontend/`. El `docker-compose` monta `backend/schema.sql` en el init de Postgres.
4. **El preview (`serve-generated.mjs`) y Studio apuntan a `/slug/frontend/index.html`**, no a la raíz.
5. **Robustez en el spec:** para apps ambiciosas, la sección Architecture exige validación de entrada en el borde del servicio, queries parametrizadas, clasificación de errores (4xx/5xx), escrituras idempotentes, connection pooling y paginación.

---

## 4. El Patrón de Decisiones (interactivo vs manos libres)

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

**Regla:** una decisión **nunca** degrada el stack sin consecuencias conscientes. Si el usuario elige "sin login", el spec baja a estático; si elige "con login", se garantiza backend. Se registra en memoria como decisión.

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
