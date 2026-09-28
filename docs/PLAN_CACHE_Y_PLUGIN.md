# Plan — Contabilidad real de caché + CASF como plugin de Claude Code

> Documento de trabajo interno. Origen: recomendación de un colega sobre `claude -p` y prompt caching.
> Fecha: 2026-09-28.

---

## 0. Resumen ejecutivo

La recomendación recibida («usa el SDK con un proceso persistente porque `claude -p` rompe el caché,
cambia el PID y varían los encabezados») **no aplica a nuestro stack**. El caché no se llavea por
proceso ni por headers: se llavea por el **prefijo exacto de bytes del prompt**. Y DeepSeek, que es el
proveedor real detrás de CASF, cachea **automáticamente** sin código, sin `cache_control` y sin recargo
de escritura.

Pero la observación esconde un problema **real** que sí tenemos: **no medimos el caché**, y por eso no
podemos saber si está funcionando ni cuánto estamos pagando de verdad.

Y hay un segundo problema, independiente: **hoy CASF no puede cargarse como plugin de Claude Code**
porque sus agentes no tienen frontmatter y sus nombres usan guiones bajos, que Claude Code rechaza.

---

## 1. Hallazgos de la investigación (con evidencia)

### 1.1 Cómo funciona realmente el caché

| Proveedor | Cómo se activa | Clave del caché | Coste de escritura | Coste de lectura |
| --- | --- | --- | --- | --- |
| **Anthropic** | Explícito: `cache_control: {type: "ephemeral"}`, máx. 4 breakpoints | Hash de los bytes exactos del prefijo, en orden `tools → system → messages` | **1.25×** el input normal | **0.1×** el input normal |
| **DeepSeek** | **Automático**, sin código ni parámetros | Prefijo idéntico **desde el token 0** | **0** (no existe) | ~**0.02×** ($0.003 vs $0.15) |

Fuentes:
- Anthropic: «Prompt caching is a prefix match. Any change anywhere in the prefix invalidates everything after it.»
- DeepSeek: «Only requests with identical prefixes (starting from the 0th token) will be considered duplicates. The disk caching service is now available for all users, requiring no code or interface changes.»

**Conclusión:** el PID y los headers **no participan** en la clave del caché. Dos procesos distintos que
manden el mismo prefijo hacen cache hit. Matar el PID y relanzar no rompe nada por sí solo.

### 1.2 La preocupación real que hay detrás

Sí existe una causa de cache miss, pero es otra: contenido **dinámico** en el prefijo.

> DeepSeek: «changing dates, IDs, message order, whitespace, or other content near the beginning can reduce the reusable prefix»

Si el harness inyecta fecha, `cwd` o estado de git en el system prompt, **cada proceso nuevo genera un
prefijo distinto** y se pierde el caché de todo el `CLAUDE.md` (~24 KB). El síntoma es idéntico al que
describe el colega; la causa no.

### 1.3 El bug real de nuestro código

Hoy solo leemos **un** campo del usage:

- `casf-studio/backend/src/claudeCodeProvider.ts:98-100`
- `casf-studio/backend/src/llmBuild.ts:311-313`

Y el evento `result` de Claude Code expone **cuatro**:

```json
{"usage": {
  "input_tokens": 51,
  "output_tokens": 5555,
  "cache_read_input_tokens": 147615,
  "cache_creation_input_tokens": 12190
}}
```

Con la regla oficial: `total_input_tokens = cache_read_input_tokens + cache_creation_input_tokens + input_tokens`,
donde `input_tokens` son **solo** los tokens posteriores al último breakpoint.

**Impacto:** el costo que registramos está mal en cualquier dirección. Si el caché funciona, lo
**subestimamos** (no contamos `cache_read`). Si no funciona, **no nos enteramos**. Eso rompe la
contabilidad que alimenta el modelo de monetización.

En el proveedor nativo de DeepSeek (`llm.ts:649`) pasa lo mismo: leemos `prompt_tokens` y tiramos
`prompt_cache_hit_tokens` / `prompt_cache_miss_tokens`, que es justo el dato del caché.

### 1.4 Cómo se empaqueta un plugin de Claude Code

| Componente | Ubicación | Nota |
| --- | --- | --- |
| Manifest | `.claude-plugin/plugin.json` | **Solo** `plugin.json` vive ahí |
| Skills | `skills/<nombre>/SKILL.md` | Formato recomendado hoy |
| Comandos | `commands/*.md` | Formato legacy, sigue soportado |
| Agentes | `agents/*.md` | **Requieren frontmatter YAML** |
| Hooks | `hooks/hooks.json` | |
| Marketplace | `.claude-plugin/marketplace.json` | `name`, `owner`, `plugins[]` |

Tres restricciones críticas descubiertas:

1. **`name` de agente debe ser kebab-case.** «must use lowercase letters and hyphens... contain no underscores, spaces, or colons». Un nombre inválido → Claude Code **salta el archivo en silencio** (solo escribe al debug log). Nuestros 14 agentes usan `snake_case` (`code_reviewer`), por lo que **hoy ninguno cargaría**.
2. **`CLAUDE.md` en la raíz de un plugin NO se carga como contexto.** «Plugins contribute context through skills, agents, and hooks rather than CLAUDE.md.» La constitución de 25 KB **debe ir en un skill** para llegar al contexto del consumidor.
3. **El caché de plugins copia el plugin root.** Nada fuera del root resuelve (`../shared` no funciona). Hay que usar `${CLAUDE_PLUGIN_ROOT}`.

Y una consecuencia: los agentes de CASF son **prosa sin frontmatter** (solo `# Agent: code_reviewer`),
así que no son subagentes invocables; son documentación que el usuario tenía que copiar a mano.

---

## 2. Fase 2 — Contabilidad real de tokens y caché (`casf-studio`)

**Objetivo:** que el ledger refleje el costo real, incluyendo caché, y que el dashboard muestre el hit rate.

### Cambios

1. **`types.ts`** — extender `Usage`:
   ```ts
   export interface Usage {
     inputTokens: number;        // TOTAL (cacheado + no cacheado)
     outputTokens: number;
     cacheReadTokens?: number;   // subconjunto servido desde caché
     cacheWriteTokens?: number;  // subconjunto escrito a caché (solo Anthropic)
   }
   ```
   Convención: `inputTokens` sigue siendo el total, para que `totalTokens` no cambie de significado.

2. **`cost.ts`** —
   - `Price` gana `cacheRead?` y `cacheWrite?` (si faltan, se usa `input` → conservador).
   - Tarifas reales: `deepseek-flash` → `cacheRead: 0.003, cacheWrite: 0`; `deepseek-v4-pro` → `0.022 / 0`; Anthropic → `10% / 125%`.
   - `costOf()` prorratea las tres categorías y **clampea a 0** el no-cacheado para que un proveedor que sobrerreporte caché no genere cargos negativos.
   - Nuevo `cacheHitRate(usage)`.

3. **`claudeCodeProvider.ts` y `llmBuild.ts`** — normalizador único de usage que entiende **los dos esquemas**:
   - Anthropic/CC: `input_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`.
   - DeepSeek nativo: `prompt_cache_hit_tokens`, `prompt_cache_miss_tokens`.
   Y escribe al log en vivo una línea de diagnóstico con el hit rate, para tener **evidencia visible** durante las demos.

4. **`llmBuild.ts`** — acumular los 4 campos por slice y persistirlos en `memory.md` (el resume conserva la contabilidad).

5. **`llm.ts`** — `DeepSeekProvider` y `AnthropicProvider` dejan de tirar los campos de caché.

6. **`ledger.ts`** — `LedgerEntry` y `LedgerStats` ganan los campos de caché (agregado por modelo/proveedor/día).

7. **`index.ts`** — pasar los campos a `addEntry`; exponer el hit rate en `/api/usage`.

8. **Dashboard (frontend)** — tarjeta de caché: tokens cacheados, hit rate y ahorro estimado.

### Verificación
Correr un build real y comprobar que el hit rate reportado no es 0. Si lo es, tenemos la prueba
empírica de que el prefijo es inestable → ahí sí tocaría estabilizarlo (no montar el SDK).

---

## 2b. Fase 4 — Validación empírica del caché (el resultado contradice el plan)

Se ejecutó la prueba con la API real. **La hipótesis del prefijo inestable quedó refutada**, y el
resultado real es más incómodo y más importante.

### 2b.1 Lo que se midió

| Experimento | Resultado |
| --- | --- |
| Dos corridas idénticas de Claude Code | `input_tokens = 37303` en **ambas** → el prefijo **es byte-estable** |
| SHA de `tools` / `system` / `messages` capturados por proxy | **Idénticos** entre corridas |
| API **nativa** de DeepSeek, prefijo idéntico ×2 | **98.9 %** de aciertos ✅ |
| Shim `/anthropic`, prefijo idéntico ×2 | **99.5 %** de aciertos ✅ |
| Shim, disponibilidad del caché | Acierta a los **+3 s** (no hay latencia de calentamiento) |
| Shim, variantes de transporte (query `?beta=true`, `anthropic-beta` completo de 8 valores, `Bearer` vs `x-api-key`, user-agent, session-id) | **Todas 99.5 %** → el transporte no es la causa |
| **Replay del cuerpo EXACTO de Claude Code, byte a byte** | **99.5 %** ✅ |
| Claude Code ejecutándose por sí mismo | **0.0 %** ❌, confirmado por el propio upstream |

**Conclusión:** el mismo cuerpo, con los mismos headers, en la misma ruta y con la misma cuenta,
acierta al 99.5 % cuando lo enviamos nosotros y da 0 % cuando lo envía Claude Code. La pérdida está
en la ruta de transporte Claude Code → DeepSeek y **no** en el prompt, el protocolo, la cuenta ni el
framework. No se pudo aislar la causa raíz exacta dentro del presupuesto de la prueba; queda
registrado como hallazgo abierto, no como conclusión.

### 2b.2 Dos bugs confirmados de camino

1. **`~/.claude/settings.json` pisa las variables que exporta CASF Studio.** El bloque `env` del
   archivo de usuario gana sobre el entorno del proceso hijo. En esta máquina eso significa:
   - `ANTHROPIC_MODEL: "deepseek-chat"` → **modelo legacy discontinuado el 2026-07-24**, en lugar del
     `deepseek-flash` que el provider cree estar usando.
   - `CLAUDE_CODE_MAX_CONTEXT_TOKENS: "64000"` → pisa los 200 000 que declara `claudeCodeProvider.ts`.

   Se detectó porque `ANTHROPIC_BASE_URL` fue ignorado y las peticiones no pasaban por el proxy.
   **Mitigación:** lanzar con `CLAUDE_CONFIG_DIR` apuntando a un directorio propio, o documentar que
   el usuario debe limpiar su `settings.json`.

2. **Claude Code entra en bucles de reintento** contra este endpoint (se observaron 12+ reintentos
   consecutivos con respuesta vacía). Consume cuota sin producir nada. Hay que acotar
   `maxRetries`/timeout en el provider.

### 2b.3 Decisión que se deriva

Dado que por la ruta de Claude Code el caché no se materializa, y que el **prefijo estático grande
(≈33 K tokens) es donde vive el 97 % del costo**, la recomendación es una **arquitectura híbrida**:

| Etapa | Ruta | Motivo |
| --- | --- | --- |
| Trabajo agéntico (leer repo, editar, tools) | **Claude Code CLI** | Es el valor real: harness, agentes, tools |
| Generación masiva de texto (spec, slices, docs) con prefijo estático grande | **API nativa de DeepSeek** | Captura el **~33×** de ahorro del caché, medido |

El normalizador de `usage.ts` ya entiende **ambos** esquemas, así que el ledger contabiliza las dos
rutas sin cambios. Esto convierte el bug de contabilidad que arreglamos en el habilitador de la
solución.

---

## 3. Fase 3 — CASF como plugin oficial de Claude Code (`CASF`)

### 3.1 Estructura final (validada)

El repo CASF es **marketplace + plugin a la vez**:

```text
CASF/
├── .claude-plugin/
│   ├── plugin.json          # manifest del plugin
│   └── marketplace.json     # catálogo → otros devs hacen /plugin marketplace add
├── agents/                  # 14 agentes (frontmatter kebab-case) — RAÍZ, no .claude/
├── .claude/
│   ├── skills/casf-framework/SKILL.md   # la constitución, como skill
│   ├── commands/            # 7 comandos
│   ├── constitution/  templates/  workflows/  memory/  ...
├── CLAUDE.md
└── LICENSE
```

### 3.1bis Hallazgo: el campo `agents` del manifest NO funciona

Se probó empíricamente con dos plugins de prueba en un directorio temporal:

| Variante | Resultado |
| --- | --- |
| Agentes en la raíz `agents/`, sin declarar en el manifest | **Agents (1)** ✅ |
| Agentes en directorio propio, declarados en `plugin.json` → `agents` | **Agents (0)** ❌ |

**El campo `agents` del manifest se acepta en `claude plugin validate` pero el loader no lo
honra en runtime.** Es un bug de Claude Code 2.1.281. La única forma fiable de publicar
agentes en un plugin es dejarlos en la raíz `agents/`, que es la ubicación por defecto
auto-descubierta.

Consecuencia: los agentes se movieron de `.claude/agents/` a `agents/` con `git mv`
(historial preservado). El `agents` field del manifest se eliminó por innecesario.

> Esto también invalida la hipótesis de las «rutas ocultas»: `.claude/skills/` y
> `.claude/commands/` **sí** cargan vía manifest (8 skills lo confirman), así que no es
> un problema de directorios ocultos sino específico del campo `agents`.

### 3.2 Trabajo requerido

1. **Frontmatter kebab-case en los 14 agentes.** No es cosmético: sin esto **no cargan**.
   - `code_reviewer` → `name: code-reviewer`
   - `description` = cuándo debe invocarlo Claude (es un *usage hint*, no un resumen).
   - Nota: los nombres de archivo conservan guiones bajos; Claude Code deriva la identidad
     del campo `name`, no del nombre del archivo (así lo documenta el propio CLI).
2. **Coherencia de nombres.** La constitución referencia a los agentes en snake_case; hay que actualizar
   esas referencias (CLAUDE.md, `constitution/`, `workflows/`, `commands/`, `templates/`, `DELEGATION_BRIDGE.md`).
   Se **excluye** `.claude/memory/**` (registro histórico; se anota la decisión en `decisions.md`).
3. **Skill de constitución.** Un `skills/casf-constitution/SKILL.md` que cargue en contexto las reglas
   de operación. Sin esto, un tercero que instale el plugin no recibe la constitución (porque `CLAUDE.md`
   de la raíz no se lee).
4. **`plugin.json` + `marketplace.json`.**
5. **Hook de sesión (opcional, alto valor).** `SessionStart` → recordar `/resume` y el checkpoint.
6. **Verificación real:** instalar el plugin desde el marketplace local y confirmar que los 14 agentes y
   los 7 comandos aparecen.
7. **`README` de instalación para terceros** (bilingüe, según el estándar del repo).

### 3.3 Sobre «oficial»

Distinción honesta de dos significados:

| Nivel | Qué requiere | Resultado |
| --- | --- | --- |
| **Plugin instalable** | Manifest + estructura + verificación | Cualquiera lo instala con `/plugin marketplace add ZoodiacR/CASF` |
| **Marketplace oficial de Anthropic** | Envío a `anthropics/claude-plugins-community` y **pasar su revisión** | Aparece en el catálogo curado |

Alcanzamos el primero con certeza. El segundo depende de la revisión de Anthropic y lo preparamos
(estructura, licencia, CHANGELOG, semver) para maximizar las probabilidades.

---

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
| --- | --- |
| El renombrado masivo rompe referencias a agentes | Rename acotado + `rg` de verificación antes de commitear |
| El cacheo del plugin ignora `.claude/` | Verificación empírica temprana; fallback a raíz |
| Cambiar `inputTokens` a «total» altera cifras históricas | Es más correcto, no menos; se documenta en `decisions.md` |
| DeepSeek no devuelve campos de caché por el endpoint `/anthropic` | El normalizador es defensivo: si no vienen, el comportamiento es el de hoy |
| Tocar el build en caliente | Los cambios son aditivos/opcionales; el build sigue funcionando si el usage no trae caché |

---

## 5. Estado de ejecución

| Fase | Estado | Evidencia |
| --- | --- | --- |
| 2. Contabilidad de caché (`casf-studio`) | ✅ Hecho | 18/18 tests verdes · `tsc --noEmit` limpio en back y front · build de Vite ok |
| 2b. Dashboard (hit rate + ahorro) | ✅ Hecho | Tarjetas de caché y ahorro añadidas; `cacheSavings` expuesto por `/api/cost` |
| 3. Frontmatter kebab en 14 agentes | ✅ Hecho | `claude plugin validate agents/` → passed |
| 3. Frontmatter en 7 comandos | ✅ Hecho | Validador sin warnings |
| 3. Skill de constitución | ✅ Hecho | `casf-framework` carga ~890 tok on-invoke |
| 3. Manifest + marketplace | ✅ Hecho | `claude plugin validate .` → passed |
| 3. Verificación empírica | ✅ Hecho | `plugin details casf` → **Skills (8) · Agents (14)** |
| 4. Validar hit rate con corrida real | ✅ Hecho | **0 % por la ruta de Claude Code**; 99.5 % por la ruta directa. Ver §2b |
| 5. README de instalación + CHANGELOG | ✅ Hecho | Pusheado |

### Hallazgos abiertos

- **Causa raíz del cache miss en la ruta Claude Code → DeepSeek.** Aislada pero no identificada:
  cuerpo/headers/ruta idénticos aciertan cuando los enviamos nosotros y fallan cuando los envía el CLI.
  Siguiente experimento sugerido: comparar la petición a nivel de socket (HTTP/1.1 vs chunked, orden de
  headers) o consultar el detalle de facturación de DeepSeek para ver si el caché **sí** se aplica y
  solo **no se reporta** por esa ruta.
- **Reportar el bug** del campo `agents` del manifest a Anthropic (`anthropics/claude-code`), con el
  experimento de dos plugins como reproducción mínima.
- **Reportar el override silencioso** de `~/.claude/settings.json` sobre el entorno del proceso.
- **Publicación en el marketplace curado** de Anthropic: el plugin ya es instalable desde GitHub; para
  el catálogo oficial hay que enviarlo a `anthropics/claude-plugins-community` y pasar su revisión.
