# 🧭 GUÍA MANUAL — Correr CASF sin el agente de Cursor

> **Objetivo:** poder ejecutar todo el flujo `prompt → spec → build → preview`
> **con tus propias manos**, viendo cada paso en tu terminal (MINGW64) y en el
> navegador, sin depender del agente de Cursor que hoy hace de "puente".
>
> El motor real es **Claude Code** (`claude -p`) conectado a **DeepSeek**, dentro
> del directorio del framework `d:/Trabajo/proyectos/CASF`, donde carga
> `CLAUDE.md`, `.claude/agents/*.md` y `PROJECT_SPEC.md` (el benchmark).

---

## 0. Mapa de la arquitectura (quién hace qué)

| Pieza | Qué hace | Dónde se ejecuta |
|---|---|---|
| **Framework CASF** | Constitución + agentes + workflows + memoria | `d:/Trabajo/proyectos/CASF` |
| **CASF Studio backend** | API Express (auth, spec, build, costos, log) | `casf-studio/backend` → `:4000` |
| **CASF Studio frontend** | UI React/Vite (chat, dashboard, log en vivo) | `casf-studio/frontend` → `:5173` |
| **Claude Code + DeepSeek** | Motor de inferencia (spec **y** build) | invocado por Studio o por ti |
| **Preview server** | Sirve las apps generadas (`generated/`) | `casf-studio/backend` → `:8091` |
| **`studio-live.log`** | Log en vivo del proceso (lo ves con `tail -f`) | `d:/Trabajo/proyectos/CASF` |

**Flujo completo:**

```
prompt ──► Studio (o claude-deepseek.sh)
              │
              ▼
        Claude Code + DeepSeek  ──►  project spec (Markdown)
              │                        │
              │                        ▼
              │                   [hoy: agente Cursor]
              │                   [mañana: Claude Code]  ──►  código de la app
              │                                                │
              ▼                                                ▼
        studio-live.log  ◄───────────────────────────────  preview :8091
```

> **Nota clave:** hoy el "puente" entre *spec creado* y *código de la app* lo
> hago yo (el agente de Cursor) a través del materializador determinista. El
> objetivo a corto plazo es que **Claude Code** haga también ese build. Esta
> guía te deja ambos caminos: el **automatizado** (Studio) y el **manual**
> (tú, con `claude-deepseek.sh`).

---

## 1. Requisitos previos (una sola vez)

```bash
# 1. Claude Code instalado globalmente
npm install -g @anthropic-ai/claude-code

# 2. Verifica que existe (desde MINGW64)
claude --version

# 3. Tu API key de DeepSeek YA está en:
#    d:/Trabajo/proyectos/casf-studio/backend/.env  →  DEEPSEEK_API_KEY=sk-...
#    (no la pegues en la terminal; los scripts la leen solos)
```

Opcional: configurar `~/.claude/settings.json` globalmente (para escribir solo
`claude` sin scripts):

```bash
cd /d/Trabajo/proyectos/CASF
node setup-claude-deepseek.mjs
```

---

## 2. Levantar el sistema (3 terminales)

Abre **tres** ventanas de MINGW64 (o una por cada proceso). En cada una:

**Terminal 1 — Backend de Studio (`:4000`)**

```bash
cd /d/Trabajo/proyectos/casf-studio/backend
npm run dev
```

**Terminal 2 — Frontend de Studio (`:5173`)**

```bash
cd /d/Trabajo/proyectos/casf-studio/frontend
npm run dev
```

**Terminal 3 — Preview de apps generadas (`:8091`)**

```bash
cd /d/Trabajo/proyectos/casf-studio/backend
node serve-generated.mjs generated 8091
```

**Verificar que los tres responden:**

```bash
curl -s -o /dev/null -w "backend=%{http_code}\n" http://localhost:4000/health
curl -s -o /dev/null -w "frontend=%{http_code}\n" http://localhost:5173/
curl -s -o /dev/null -w "preview=%{http_code}\n" http://localhost:8091/
# Esperado: 200 / 200 / 200
```

---

## 3. Ver el log en vivo (TU terminal de observación)

Abre una **cuarta** terminal solo para ver el proceso en tiempo real:

```bash
tail -f /d/Trabajo/proyectos/CASF/studio-live.log
```

Ahí verás, en el mismo momento, los hitos:

```
══════════════════════════════════════════════════════
[2026-09-24T17:00:00.000Z] ▶ Generando spec para: "una app de..."
══════════════════════════════════════════════════════
... (salida cruda de Claude Code + DeepSeek) ...
✔ Spec generado: Mi App (claude-code/deepseek-chat)
══════════════════════════════════════════════════════
[2026-09-24T17:00:30.000Z] ▶ Build iniciado: Mi App
══════════════════════════════════════════════════════
✔ Build completado: Mi App → 18 archivos
[claude exit code 0]
```

La **pestaña "Log en vivo"** de Studio muestra exactamente lo mismo (sin abrir
terminal), porque ambos leen el mismo archivo.

---

## 4. Camino A — Flujo automatizado (Studio) 🖱️

1. Abre `http://localhost:5173/` y entra (admin@casf.studio).
2. Escribe un prompt en la pestaña **Chat** y pulsa **"Generar spec"**.
3. Observa:
   - el **timeline** de pasos en el chat,
   - el **Log en vivo** (pestaña o `tail -f`),
   - el **spec** generado (Markdown editable),
   - el **costo/tokens** (visible para admin).
4. Pulsa **"Build"** para materializar la app.
5. Mira el **preview** (`:8091/<slug>/frontend/index.html`).
6. Recarga la página: **el proceso se restaura** (prompt + spec + build).

> El spec se genera con **Claude Code + DeepSeek real** (`LLM_PROVIDER=claude`).
> El build hoy todavía es el materializador determinista (pendiente de pasarlo a
> Claude Code — ver §6).

---

## 5. Camino B — Flujo manual (tú, con Claude Code) ⌨️

Este es el camino para **ver y controlar tú** el motor real, sin Studio de por
medio.

### 5.1 Generar el spec a mano

```bash
cd /d/Trabajo/proyectos/CASF
./claude-deepseek.sh "Quiero una app para gestionar el inventario de una tienda de repuestos, con login, dashboard de KPIs y alertas de stock bajo. Usa Postgres. Moneda: soles."
```

- El script lee la key de DeepSeek desde el `.env`, exporta las env vars de
  Anthropic-compatible y ejecuta `claude -p "..."` dentro del framework.
- Verás la salida cruda de Claude Code en la terminal.
- El resultado (spec en Markdown) aparece al final.

Para **modo interactivo** (preguntas y respuestas, verlo "pensar" paso a paso):

```bash
./claude-deepseek.sh          # sin argumentos
# o en Windows (doble clic o desde cmd):
claude-deepseek.bat
```

> 💡 Si la TUI se ve rara en MINGW64, usa el alias `claude` configurado en
> `~/.bashrc` (usa `winpty`). Si no lo tienes: `alias claude='winpty claude'`.

### 5.2 Pedirle el spec en el formato del framework

Para que el spec salga **estructurado como el benchmark** (`PROJECT_SPEC.md`),
incluye la instrucción de formato en el prompt, por ejemplo:

```bash
./claude-deepseek.sh "Genera el project spec de una app de <idea>. Usa PROJECT_SPEC.md como criterio de profundidad y formato EXACTO (nombre, descripción, stack, data model, arquitectura, roles, UX flow, MVP, non-goals)."
```

### 5.3 Hacer el build a mano (el "puente" que hoy hago yo)

Esto es lo que hoy ejecuta el materializador. Para hacerlo tú con Claude Code,
le pides que genere los archivos dentro de una carpeta nueva:

```bash
cd /d/Trabajo/proyectos/CASF
claude -p "Con este spec (pégalo abajo), crea la app completa en /d/Trabajo/proyectos/casf-studio/backend/generated/<slug>/ siguiendo la arquitectura de PATRON_DE_DISENO.md: frontend/ (React/Vite) + backend/ (Express en capas server/app/db/auth/crud) + SQLite real + validación + paginación + Dockerfile + docker-compose + README. Aplica las vistas por función (app shell + hash router). Especificación: <pegado del spec>"
```

> Para que Claude Code **escriba archivos** en modo headless sin pedir permiso
> cada vez, añade:
> `--permission-mode acceptEdits --add-dir /d/Trabajo/proyectos/casf-studio/backend/generated`

### 5.4 Ver la app generada

```bash
# el preview server (terminal 3) ya la sirve; abre:
start http://localhost:8091/<slug>/frontend/index.html
# o lista todas las apps en:
curl -s http://localhost:8091/
```

---

## 6. Qué falta (lo que hoy hace el agente de Cursor)

| # | Tarea | Estado |
|---|---|---|
| 1 | **Build LLM-driven**: que Claude Code implemente el código (no el materializador) | ⏳ pendiente (mañana) |
| 2 | Conectar `/api/build` de Studio a Claude Code con `--permission-mode acceptEdits` + `--add-dir generated` | ⏳ pendiente |
| 3 | Prueba end-to-end: prompt → spec → build por Claude Code → preview | ⏳ pendiente |
| 4 | Etapa 2 (visual) / 5.1 (Yape) | según presupuesto |

---

## 7. Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `claude: command not found` | Claude Code no instalado | `npm install -g @anthropic-ai/claude-code` |
| Warning `unrecognized_model` | DeepSeek no está en el catálogo de Claude Code | Ya se silencia con `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1` (los scripts lo ponen) |
| La TUI se ve rota en MINGW64 | Claude Code necesita `winpty` | `alias claude='winpty claude'` en `~/.bashrc` |
| `tail -f` no muestra nada | El log aún no existe o se borró | Genera un spec primero; el log se crea solo |
| Studio dice "invalid token" | `JWT_SECRET` cambió | Está fijo en `backend/.env`; no lo borres |
| La app generada no abre en preview | Preview server caído | Terminal 3: `node serve-generated.mjs generated 8091` |
| `timeout` de Claude Code | Spec muy complejo / red lenta | Sube `CLAUDE_TIMEOUT_MS` en `backend/.env` |

---

## 8. Comandos de referencia rápida

```bash
# Levantar todo (3 terminales)
cd /d/Trabajo/proyectos/casf-studio/backend && npm run dev        # :4000
cd /d/Trabajo/proyectos/casf-studio/frontend && npm run dev       # :5173
cd /d/Trabajo/proyectos/casf-studio/backend && node serve-generated.mjs generated 8091  # :8091

# Ver log en vivo (4ª terminal)
tail -f /d/Trabajo/proyectos/CASF/studio-live.log

# Generar spec a mano
cd /d/Trabajo/proyectos/CASF && ./claude-deepseek.sh "tu prompt"

# Claude Code interactivo
cd /d/Trabajo/proyectos/CASF && ./claude-deepseek.sh

# Config global (una vez)
cd /d/Trabajo/proyectos/CASF && node setup-claude-deepseek.mjs

# Typecheck
cd /d/Trabajo/proyectos/casf-studio/backend && npx tsc --noEmit
cd /d/Trabajo/proyectos/casf-studio/frontend && npx tsc --noEmit
```

---

<!-- CASF · GUIA_MANUAL.md -->
