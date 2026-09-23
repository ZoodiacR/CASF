# DELEGATION_BRIDGE — Puente entre agentes conceptuales y subagentes reales

> **Propósito:** el framework define agentes como *roles* (`.claude/agents/*.md`). Este documento es el **puente** que convierte esos roles en **subagentes reales del harness** (contexto aislado + ejecución paralela), en lugar de hacerlo todo inline en el orquestador.
>
> Es la pieza que hace que el flujo QA (adversarial + slices) **se ejecute de verdad**, no "de palabra".
>
> **Principio de portabilidad:** el `.claude/agents/<name>.md` es la **única fuente de verdad**. Ninguna lógica de negocio del framework depende de un harness concreto; cada harness aporta solo un **adaptador fino** que traduce "materializa este rol" a su mecanismo nativo de subagentes. El orquestador piensa en **roles**, no en nombres de subagente del harness.

---

## 1. La regla núcleo (materializar vs. inline)

El `project_orchestrator` NO debe encarnar todos los roles él mismo. Debe **materializar** cada rol como un subagente cuando se cumple **cualquiera** de estas condiciones:

| Condición | Acción |
|---|---|
| La tarea es **independiente** de otras en curso | Spawn subagente en **paralelo** |
| La tarea es una **revisión/adversarial** (otro "cerebro" debe juzgar) | Spawn subagente (aislamiento evita sesgo del autor) |
| La tarea toca **código extenso** que requiere lectura completa sin contaminar el contexto principal | Spawn subagente |
| La tarea es **barata y secuencial** (status, edición puntual, un fix acotado) | Hacerla **inline** (no over-delegate) |

> **Anti-patrón:** hacer la revisión adversarial "inline" — el autor revisando su propio código sin separación de contexto NO es una revisión adversarial. Un `architecture_reviewer` inline es solo el autor asintiendo consigo mismo.

---

## 2. Invocación lógica (independiente del harness)

El orquestador **siempre** piensa en esta invocación lógica:

```text
MATERIALIZAR <rol>        # ej. architecture_reviewer
  CONTEXTO:  <paths, spec, ADR, intención>
  TAREA:     <tarea con criterios de aceptación>
  OUTPUT:    <artifact esperado: score | verdict | plan | lista>
  PARALELO:  <sí | no — solo si es independiente de otras tareas>
```

El rol se resuelve desde su spec `.claude/agents/<rol>.md`. **Solo en el momento de spawn** interviene el adaptador del harness (sección 3) para convertir esa invocación lógica en una llamada concreta.

---

## 3. Adaptadores por harness

### A. Claude Code — adaptador nativo (cero trabajo)

En Claude Code, cada `.claude/agents/<name>.md` **ya es un subagente**: su `frontmatter` (`name`, `description`, `tools`, `model`) lo define y el harness lo lee directamente.

```text
MATERIALIZAR architecture_reviewer
  → invocar el subagente "architecture_reviewer" (Task/subagent)
    sin reproducir el spec: el harness ya lo tiene.
```

**Regla del adaptador:** no se copia el `.md` al prompt (el harness lo carga). Solo se pasa `CONTEXTO` + `TAREA` + `OUTPUT`.

### B. Cursor — adaptador de mapeo (los subagentes son tipos built-in)

En Cursor, los subagentes son **tipos built-in** que **no leen** `.claude/agents/*.md` automáticamente. El adaptador hace dos cosas: (1) mapea rol → tipo de subagente, y (2) **reproduce el contenido del `.md`** dentro del prompt (porque el harness no lo carga solo).

Formato canónico del prompt de materialización en Cursor:

```text
Actúa como <ROL> siguiendo su spec en .claude/agents/<rol>.md
(la reproduzco a continuación). <CONTEXTO: paths, spec, ADR, intención>.
<TAREA con criterios de aceptación>. <OUTPUT ESPERADO>.
No propongas rewrite sin nombrar la forma de reemplazo.
```

**Regla del adaptador:** a diferencia de Claude Code, aquí **sí** se copia el `.md` al prompt, porque el tipo built-in no lo resuelve solo.

### C. Regla de portabilidad (lo que NO debe variar)

- ❌ No mover la lógica del rol (criterios, outputs, reglas) fuera del `.md`.
- ❌ No hacer que el orquestador dependa de nombres de subagente del harness.
- ✅ Cada harness solo implementa: *"dada una invocación lógica, ¿cómo spawn un subagente?"*.
- ✅ Añadir un harness nuevo = añadir una fila a la tabla de la sección 4, nada más.

---

## 4. Mapa de roles (portable, con ambos adaptadores)

| Rol (`.claude/agents/`) | Claude Code (nativo) | Cursor (mapeo) | Cuándo materializar |
|---|---|---|---|
| `chief_engineer` (hipótesis) | subagente `chief_engineer` | `generalPurpose` | Diseño de arquitectura, ADRs, romper empates |
| `architecture_reviewer` (evidencia) | subagente `architecture_reviewer` | `generalPurpose` | **Review adversarial post-implementación** (lee código, no resumen) |
| `spec_quality_reviewer` | subagente `spec_quality_reviewer` | `generalPurpose` | **Gate de calidad del spec** antes del build |
| `backend_architect` / `database_architect` | subagente homónimo | `generalPurpose` | Diseño de API/schema antes de implementar |
| `frontend_architect` | subagente `frontend_architect` | `generalPurpose` | Diseño de UI/componentes (sigue `DESIGN_SYSTEM.md`) |
| `qa_engineer` | subagente `qa_engineer` | `generalPurpose` | Estrategia de tests, planes de cobertura |
| `code_reviewer` | subagente `code_reviewer` | `bugbot` | **Gate pre-merge** del diff |
| `security_officer` | subagente `security_officer` | `security-review` | **Revisión de seguridad** del diff (secretos, OWASP) |
| `context_manager` / exploración | subagente `context_manager` | `explore` | Mapear el repo antes de un cambio (rápido, barato) |
| `devops_engineer` (CI roto) | subagente `devops_engineer` | `ci-investigator` | Diagnosticar un check de CI fallido |
| `devops_engineer` / `documentation_writer` | subagente homónimo | `startup-review` / `docs-reliability-review` | Auditar que el setup documentado arranca de verdad |
| `qa_engineer` (verificabilidad) | subagente `qa_engineer` | `validation-review` | Auditar que un cambio se puede verificar sin adivinar |
| Experimentos en paralelo | subagente genérico (worktree) | `best-of-n-runner` | Probar 2-3 soluciones a la vez en worktrees aislados |

> **Nota:** en Claude Code, si un rol no tiene `.md` propio (p. ej. `best-of-n-runner` o reviews de infraestructura), se usa un subagente genérico con el prompt equivalente. El `.md` sigue siendo la fuente de verdad donde existe.

---

## 5. El flujo QA (adversarial + slices) materializado

```
GENERACIÓN ──► [spec_quality_reviewer]
                 · compara el spec contra spec_quality_rubric.md
                 · benchmark = PROJECT_SPEC.md
                 · salida: score (0-100) + red-lines + top gaps + verdict
                 · red-line = BLOQUEA el build

BUILD ──► slice 1..n
           implemento (orquestador)
           └─ [architecture_reviewer]
                · lee el CÓDIGO REAL (no el resumen)
                · marca cada hipótesis CONFIRMADA/REFUTADA/NO VERIFICADA
                · verdict: REFACTOR (nombra reemplazo) | HARDENING (lista)
           └─ fix (máx 2 intentos) → si repite fallo → REFACTOR como fix

SLICE COMODÍN ──► hasta 10 iteraciones contra todos los PENDING

PRE-MERGE ──► [code_reviewer] + [security_officer]
               EN PARALELO sobre el diff
```

---

## 6. Guardarraíles (para no gastar de más ni sub-delegar)

1. **Paralelo cuando es independiente** (cap. 8 CLAUDE.md); secuencial solo si hay dependencia explícita.
2. **No spawn para trivialidades**: status, editar un string, correr tests, leer un archivo — eso es inline.
3. **El reviewer nunca es el autor**: la revisión adversarial exige un subagente distinto o, mínimo, una pasada con contexto aislado.
4. **Presupuesto**: con budget ajustado, el `spec_quality_reviewer` y el `architecture_reviewer` pueden correrse inline solo si son acotados; ante revisión de un slice grande o pre-merge, spawn SIEMPRE.
5. **Modelo**: por defecto los subagentes heredan el modelo del orquestador (`inherit`); usar un modelo rápido para reviews de rutina ahorra costo.
6. **Todo subagente devuelve un artifact**, no conversación suelta: score, verdict, plan de reemplazo, lista de hardening — con evidencia (file:line).

---

## 7. Definición de hecho (para el orquestador)

Un flujo QA se considera **materializado correctamente** cuando:
- [ ] Cada revisión adversaria se ejecutó en un subagente distinto del autor.
- [ ] Las tareas independientes corrieron **en paralelo**.
- [ ] Cada subagente devolvió su artifact (no un "ok" suelto).
- [ ] El resultado (score/verdict/PENDING) quedó registrado en `.claude/memory/`.
- [ ] La invocación lógica no dependió del harness; solo el adaptador final fue específico.

---

<!-- CASF v1.0 · generated 2026-09-22 -->
