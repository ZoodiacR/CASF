# 🚀 CASF — Ventaja Competitiva y Potencial de Negocio

> Documento de negocio del producto **CASF** (Claude Autonomous Software Framework + CASF Studio).
> Objetivo: explicar por qué CASF es más que "un IDE con agente", frente a qué compite y cómo monetizarlo como empresa.

---

## 1. Qué es CASF como producto

CASF combina dos capas:

1. **El Framework (kernel):** un sistema de reglas, agentes especializados, workflows, memoria persistente y calidad gates versionado en archivos. Es el "cerebro" que convierte a cualquier LLM en un equipo de ingeniería senior.
2. **CASF Studio (la interfaz):** una web con chat donde el usuario escribe una idea, la IA la convierte en un `ProjectSpec` real, el framework la **materializa** en código/aplicación, y todo el proceso **registra tokens y costos** de forma transparente.

La tesis central: **el valor no está en "escribir código", sino en el sistema que coordina, recuerda, verifica y mide.** La mayoría de las herramientas actuales solo "autocompletan" o "generan un componente". CASF ejecuta un **proceso de ingeniería completo** con memoria y contabilidad de costos.

---

## 2. Ventajas frente a "un simple IDE con agente" (Cursor, Copilot, Windsurf…)

| Dimensión | IDE + agente | CASF |
|---|---|---|
| **Alcance** | Sugiere/edita código dentro de un editor | Ejecuta un ciclo de vida completo (discovery → diseño → build → ship → operar) |
| **Coordinación** | Un solo modelo "chatty" sin roles | 12 agentes especializados con jerarquía, handoffs y gates (orquestador, arquitectos, QA, seguridad, costos…) |
| **Memoria** | Contexto se pierde al cerrar sesión / agotar tokens | Memoria persistente en archivos: decisiones, lecciones, deuda técnica, **checkpoint de progreso reanudable** |
| **Calidad** | Depende del prompt del usuario | Definition of Done + Quality Gates + reviewer final que bloquea merges malos |
| **Decisión** | Sin trazabilidad | ADRs (Architecture Decision Records) con contexto, consecuencias y alternativas |
| **Costos** | Opaco | Contabilidad de tokens y costo **por cualquier LLM**, con ledger y alertas de presupuesto |
| **Repetibilidad** | Cada sesión empieza de cero | El framework se versiona y se reutiliza: "Rails para desarrollo asistido por IA" |
| **Portabilidad de modelo** | Atado a un proveedor | Proveedor-agnóstico (OpenAI, Anthropic, Google, DeepSeek, local) |

> **En una frase:** un IDE con agente te ayuda a escribir líneas; CASF te da un **equipo de ingeniería con proceso, memoria y contabilidad** que puedes auditar y escalar.

---

## 3. Ventajas frente a competidores "texto-a-app" (v0, Lovable, Bolt, Replit Agent…)

| Competidor | Fuerte en | Dónde se queda corto | Qué hace CASF mejor |
|---|---|---|---|
| **v0 (Vercel)** | UI desde prompt, rápido | Solo frontend, sin backend/proceso, sin trazabilidad de costos | Full-stack + spec auditable + costos + framework reutilizable |
| **Lovable** | Apps full-stack sencillas | "Caja negra" (no sabes por qué decidió algo), sin memoria de decisiones | ADRs + memoria persistente + agentes con roles |
| **Bolt.new** | Prototipado en navegador | Poca gobernanza, difícil de industrializar | Quality gates + Definition of Done + seguridad por diseño |
| **Replit Agent** | Entorno integrado | Costos poco transparentes, proceso ad-hoc | Ledger de tokens/costo + presupuesto + multi-LLM |
| **GitHub Copilot Workspace** | Integración con PRs | Centrado en código, no en "idea → producto" | Pipeline completo desde la idea, con especificación como artefacto de primer nivel |

**Diferenciadores defendibles de CASF:**

1. **Spec como artefacto central.** El `ProjectSpec` es un entregable auditable y versionable, no un efecto secundario. Permite trazabilidad idea→implementación.
2. **Memoria que compone.** `.claude/memory/` acumula decisiones/lecciones/deuda entre sesiones. La mayoría de los competidores no persisten nada entre prompts.
3. **Contabilidad de costos multi-LLM.** El usuario (y un eventual modelo de negocio) necesita saber cuánto cuesta cada generación. Casi nadie lo expone.
4. **Proceso de ingeniería, no "magia".** Checklists, gates, roles. Esto genera confianza en entornos empresariales.
5. **Agnóstico al modelo.** No dependes de un vendor; puedes usar el LLM más barato o uno local.
6. **Self-host / on-prem posible.** Al ser archivos + una API, se puede vender como producto privado, lo que abre el mercado enterprise.

### 3.1 El foso real: CASF cubre el BUCLE COMPLETO, no solo el stack

> El error de los competidores es creer que el valor está en "generar una app". El valor está en **gobernar el proceso de convertir una idea en un producto comercializable, de forma auditable, reanudable y controlable**. Eso es lo que hace CASF, y por eso un competidor nuevo no puede alcanzarlo solo "saliendo con otro generador".

El bucle completo que CASF cubre (y que la competencia deja a medias):

| Fase del bucle | Qué hace CASF | Competidores típicos |
|---|---|---|
| **Idea → Spec rico** | Un prompt breve (3 palabras) se expande a un spec completo: entidades, páginas, features, stack. **Enriquecimiento garantizado**, no mockup genérico | Generan solo lo literal del prompt |
| **Decisiones de diseño** | Modo **interactivo** (el framework pregunta moneda/tema/idioma/login y el usuario decide) o **manos libres** (decide solo). El usuario **controla el proceso** | Caja negra: no preguntan, no dejan decidir |
| **Materialización comercial** | App funcional con CRUD + backend (Express + JWT + schema.sql) + auth + formato de moneda + tema + i18n. **Lista para vender**, no prototipo | Mockups estáticos sin backend |
| **Memoria visible** | El progreso se registra y se **ve dentro de la propia web** (`memory.md` + timeline en vivo) y se puede **retomar** donde quedó | Se pierde al cerrar la pestaña |
| **Contabilidad + margen** | Tokens y costo por cualquier LLM, con margen interno y rol admin/usuario | Costo opaco o inexistente |
| **Seguridad por diseño** | Los secretos (API keys) **nunca** se piden en el chat ni se suben a repos: se leen de `.env` local ignorado por git | Exponen claves en el prompt/repo |

**Por qué esto es un foso (moat) y no una feature:**

1. **Efecto de red de proceso.** Cuanto más se usa, más memoria acumula (decisiones, lecciones, deuda), y el framework se vuelve *mejor con el uso* para el cliente. Un competidor nuevo empieza vacío.
2. **Los competidores compiten en el 20% visible (generar UI); CASF domina el 80% invisible (gobernanza, memoria, costos, secretos, reanudación).** Esa parte invisible es la que genera confianza empresarial y retención.
3. **La especificación es propiedad del cliente.** El `ProjectSpec` + `memory.md` son archivos versionables que el cliente se lleva. Eso crea **lock-in positivo** (no por encierro, sino por valor acumulado).
4. **Multi-modelo + self-host = imbatible en precio.** Al poder correr con modelos locales/baratos (margen ≈ $0), CASF puede ofrecer precios que un competidor atado a un LLM premium no puede sostener.

---

## 4. Modelos de monetización

### Modelo elegido (principal): Free demo + créditos + suscripción

**Decisión (2026-09-20):** Free **no construye**. El uso real (Build) se paga. Hay dos vías de precio: **crédito barato** (una app) o **Pro/Enterprise** (si genera seguido). El usuario no ve el costo de tokens; ve “incluido en el crédito / el plan”.

**Flujo de dinero:**
```
Gratis: idea → spec (demo, 1–2/mes)
                 │
        ¿Quieres la app en código?
                 │
     ┌───────────┴───────────┐
  Crédito $4 / pack     Pro $19  o  Ent $99
     └───────────┬───────────┘
                 ▼
     CASF paga DeepSeek (y opcional imágenes)
                 ▼
     Margen interno (crédito ~$3.80; Pro ~$14–17)
```

**Reglas:**
1. **Free = probar el spec**, no llevarse el producto. 0 builds.
2. **1 crédito = 1 Build** exitoso (~$4 / S/ 15). Packs: 3×$10, 10×$29. No caducan.
3. **Pro $19/mes** gana si haces ~5+ apps/mes (5×$4 = $20). Así no se canibaliza.
4. **Enterprise $99** para agencias / volumen con tope negociado.
5. El usuario no ve $ de API. Admin sí (ledger + margen).
6. Ads en Free: **no** son el plan A (sesión de demo corta).

**En el código (hoy, aún el modelo viejo):** planes Free/Pro/Ent en `payments.ts` sin créditos ni 402 en Build. Cablear 5.4–5.5 en el sprint de cobro.

### Modelos complementarios (a futuro)

1. Licencia on-prem / self-hosted.
2. Marketplace de agentes/templates.
3. Consultoría (implementar la app a un negocio real).

**Margen clave:** crédito a $4 con COGS DeepSeek de centavos; Pro con DeepSeek por defecto. Claude no va en el cupo barato.

---

## 5. Proyecciones de mercado

- El mercado de **desarrollo low-code/no-code** supera los $20B y crece a doble dígito.
- El mercado de **AI coding agents** se proyecta en decenas de miles de millones para 2027-2030.
- **TAM/SAM/SOM (estimación top-down):**
  - **TAM** — desarrolladores + no-técnicos que quieren construir software: cientos de millones de usuarios.
  - **SAM** — creadores/founders/agencias que hoy usan v0/Lovable/Replit: decenas de millones.
  - **SOM** — capturable en 24-36 meses con un nicho (e.g., "especificación auditable + costos"): miles de clientes de pago.

**Palanca de crecimiento:** la combinación "memoria + costos + spec" es naturalmente **viral en equipos** (el framework se comparte como repo, como Rails o un monorepo de reglas).

Números operativos (costos, MRR mínimo, escenarios bueno/regular/malo/crítico y contingencias): ver `ETAPAS_SIGUIENTES.md` secciones **💰**, **📈** y **Apéndice B**. Este archivo no sustituye esa hoja: aquí está el *por qué* de negocio; allí está *cuánta plata hace falta para no fundirse*.

---

## 6. Roadmap hacia empresa

| Horizonte | Hito | Monetización |
|---|---|---|
| 0-3 meses | CASF Studio MVP (chat→spec→build→costos), framework v1.0 | Freemium + beta privada |
| 3-9 meses | Proveedores reales, historial de proyectos, exportación, plantillas verticales | Suscripción + créditos |
| 9-18 meses | Self-host enterprise, SSO, auditoría, multi-usuario | Licencias anuales |
| 18+ meses | Marketplace de agentes, integración CI/CD, partnerships | Marketplace + enterprise |

---

## 7. Riesgos y mitigación

- **Commoditización** (los LLMs mejoran y "todos" generan apps) → mitigación: foco en **proceso, memoria y costos**, no en el modelo.
- **Dependencia de proveedores** → mitigación: arquitectura agnóstica + soporte local.
- **Costos de inferencia** → mitigación: caché, modelos baratos, recargo transparente.
- **Confianza/seguridad** → mitigación: gates, DoD, self-host, no enviar secretos.

---

## 8. Conclusión

CASF no compite en "quién genera el mejor componente", sino en **quién convierte una idea en un producto construido con proceso, memoria y costos transparentes**. Ese posicionamiento lo diferencia tanto de un IDE con agente como de los generadores de apps "caja negra", y habilita un modelo de negocio defendible (SaaS + créditos + enterprise/self-host).

<!-- CASF · business.md -->
