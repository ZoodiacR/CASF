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

**Matices y correcciones de la propia medición** (para no sobreafirmar):

- **Una anomalía sin explicar:** una corrida de Claude Code reportó `cache_read = 37 248`. Las 5
  corridas de control posteriores, con args idénticos, dieron 0. La formulación correcta es «el CLI
  **casi siempre** reporta 0 y **a veces** acierta», no «nunca acierta». Queda como pista abierta.
- **Hipótesis refutada — caché por credencial:** se pensó que el shim namespaceaba el caché por
  cabecera de auth (mis replays usaban `x-api-key`, Claude Code usa `Bearer`). Con prefijo nuevo y
  un nonce por prueba: **Bearer acierta igual (98.5 %)** y el caché se comparte entre ambas
  credenciales. La sospecha estaba contaminada por un error del propio script, que reenviaba el
  prefijo ya cacheado.
- **Corrección de instrumentación:** lo que al principio conté como «2 llamadas API por corrida» son
  **los dos eventos de stream de la misma petición** (mismo `message.id`: uno con el bloque de
  *thinking* y otro con el texto). Claude Code hace **una** petición por corrida.
- **El «bucle de reintentos» era artefacto del proxy** (ver §2b.2): se retira como bug.

### 2b.2 Bugs, correcciones y estado

1. **`~/.claude/settings.json` pisa las variables que exporta CASF Studio.** El bloque `env` del
   archivo de usuario gana sobre el entorno del proceso hijo. En esta máquina eso significa:
   - `ANTHROPIC_MODEL: "deepseek-chat"` → **modelo legacy discontinuado el 2026-07-24**, en lugar del
     `deepseek-flash` que el provider cree estar usando.
   - `CLAUDE_CODE_MAX_CONTEXT_TOKENS: "64000"` → pisa los 200 000 que declara `claudeCodeProvider.ts`.

   Se detectó porque `ANTHROPIC_BASE_URL` fue ignorado y las peticiones no pasaban por el proxy.
   **Arreglado** con `--settings`, que tiene precedencia sobre la config del usuario y además hace
   *merge* (no descarta el resto). Verificado con los args exactos del provider:
   `model=deepseek-flash`, `contextWindow=200000`. Es mejor que `CLAUDE_CONFIG_DIR` porque no
   secuestra el resto de la configuración del usuario.

2. **CORREGIDO — el «bucle de reintentos» era mi proxy, no Claude Code.** Se observaron 12+ reintentos
   consecutivos con respuesta vacía, pero **solo al enrutar por el proxy de diagnóstico instrumentado**.
   Con conexión directa, 8+ corridas terminaron en 3-6 s sin un solo reintento. Por tanto **no es un bug
   de Claude Code** y la afirmación anterior queda retirada. (Detalle que engañó: el intérprete del proxy
   recibía respuestas comprimidas y reportaba `usage: null`, que confundí con respuestas vacías.)

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
| **Directorio de Anthropic** | Envío desde el portal `claude.ai/directory/manage` + **plan de pago de claude.ai** | Aparece en el catálogo de claude.ai/Cowork y llega a Claude Code por sincronización de cuenta |

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

- **RESUELTO (2026-09-28, tarde) — el cache miss era un ARTEFACTO DE REPORTE, no de cobro.**
  El panel de facturación de DeepSeek **no expone columnas de cache hit/miss** (se comprobó: cero
  menciones de «cache» en su DOM y tampoco en sus docs de *Token & Usage*). Pero la aritmética del
  panel lo cierra igual, y de forma concluyente:

  | Dato del panel (últimos 30 días) | Valor |
  |---|---|
  | Coste total | **$31.71** |
  | Tokens `deepseek-v4-pro` | **537,003,171** |
  | Tokens `deepseek-flash` | 66,637,695 |

  La tarifa **cache miss** de `deepseek-v4-pro` es **$0.66/M**. Facturar esos 537 M tokens a miss
  daría **$354 — once veces la factura entera de $31.71**. Incluso asumiendo que todo fueran *output*
  ($1.98/M) serían $1063. La única lectura compatible con la factura es que el **91 %+ de esos tokens
  se cobraron como cache hit** ($0.022/M → $11.81). **El descuento de caché se está aplicando.**

  Confirmación independiente obtenida mientras se medía: entre dos lecturas del panel separadas por
  ~1 h, las **35 peticiones nuevas fueron 100 % a `deepseek-flash`** (`deepseek-v4-pro` no se movió ni
  una petición). Es decir, con la config corregida el tráfico nuevo aterriza en el modelo barato.

  **Conclusión:** `cache_read_input_tokens: 0` es lo que DeepSeek **reporta** al cliente por esta ruta,
  no lo que **cobra**. El bug se cierra como artefacto de reporte. Se abandona la vía «socket/HTTP2»
  por innecesaria.

- **Hallazgo de coste (el más accionable): la config del provider estaba incompleta.** La guía
  **oficial** de DeepSeek para Claude Code
  (`api-docs.deepseek.com/quick_start/agent_integrations/claude_code`) documenta variables que el
  provider **no** fijaba, y una de ellas es una trampa de facturación:
  - DeepSeek **mapea los tiers de Claude a modelos suyos**: `claude-opus*` → `deepseek-v4-pro`
    (facturado a precio Pro: **4.4× Flash en miss, 7.3× en hit**); `claude-sonnet*`/`claude-haiku*` →
    `deepseek-flash`. Dejar `ANTHROPIC_DEFAULT_OPUS_MODEL` sin fijar significa que cualquier petición
    que resuelva al tier opus (subagentes, rutas internas del CLI) se cobra a precio Pro **en silencio**.
  - El sufijo **`[1m]`** es lo que habilita el contexto de **1M**. Verificado: `deepseek-flash[1m]`
    reporta `contextWindow: 1000000` (sin sufijo, 200 000).
  - `CLAUDE_CODE_SUBAGENT_MODEL`, `CLAUDE_CODE_AUTO_COMPACT_WINDOW=786432`, `CLAUDE_CODE_EFFORT_LEVEL=max`.

  **Arreglado** en `claudeCodeProvider.ts`: se fijan los cuatro puntos (principal, opus, sonnet,
  haiku) más el modelo de subagentes. El ledger no se rompe: `resolveModel()` no encuentra
  `deepseek-flash[1m]` exacto y cae al fallback por prefijo `deepseek*` → `deepseek-flash`.
- **Reportar a Anthropic:**
  - El campo `agents` del manifest se valida pero el loader no lo honra (reproducción mínima: dos
    plugins idénticos salvo la ubicación de los agentes).
  - El bloque `env` de `~/.claude/settings.json` pisa el entorno del proceso hijo — silenciosamente,
    sin advertencia. Mitigable con `--settings`, que sí tiene precedencia.
- **`--plugin-dir` como hallazgo aprovechable:** carga el plugin solo para esa sesión. Verificado desde
  otro cwd y sin instalación global → Skills (8), Agents (14). Es lo que hace que el framework sea
  autocontenido: quien clone el repo no necesita instalar el plugin a mano.
- **Publicación en el marketplace curado** de Anthropic: el plugin ya es instalable desde GitHub; para
  el directorio de Anthropic hay que enviarlo desde el portal `claude.ai/directory/manage` (requiere plan
  de pago de claude.ai). Nota: `claude-plugins-official` **no** acepta envíos por ese portal.
