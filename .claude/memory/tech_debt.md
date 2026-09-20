# Tech Debt Register

This file tracks technical debt items with their severity, impact, and remediation plans. Technical debt is recorded when we take shortcuts or make trade-offs that will need to be addressed later.

## Schema
Each tech debt entry should include:
- **ID:** Unique identifier (TD-001, TD-002, etc.)
- **Date:** ISO date (YYYY-MM-DD) when debt was incurred
- **Description:** Brief description of the technical debt
- **Category:** Performance, Security, Architecture, Code Quality, Documentation, or Testing
- **Severity:** Critical, High, Medium, or Low
- **Impact:** What systems or features are affected
- **Owner:** Which agent or team is responsible for remediation
- **Due Date:** Target date for remediation (if applicable)
- **Status:** Open, In Progress, or Resolved
- **Remediation Plan:** How the debt will be addressed

## Severity Guidelines

**Critical:** Must be addressed immediately or in the next sprint. Poses significant risk to system stability, security, or data integrity.

**High:** Should be addressed within 2-3 sprints. Poses moderate risk or significantly impacts maintainability.

**Medium:** Should be addressed within 3-6 months. Impacts maintainability or performance but doesn't pose immediate risk.

**Low:** Can be addressed opportunistically. Minor impact on maintainability or performance.

## Tech Debt Items

### TD-001: Check-in QR persiste solo en localStorage (no en BD real)
- **Date:** 2026-09-20
- **Description:** El flujo de check-in por QR (registrar llegada + sumar puntos + guardar cliente) escribe en `localStorage` en el preview estático. Con backend real (`server.js`) debería usar `/api/*` + transacciones de puntos atómicas.
- **Category:** Architecture
- **Severity:** Medium
- **Impact:** La app de fidelidad en preview pierde datos al recargar en otro navegador; no es "multi-dispositivo" real.
- **Owner:** backend_architect
- **Due Date:** Próxima iteración del materializador
- **Status:** Open
- **Remediation Plan:** En el `RUNTIME` de `materializer.ts`, cuando `fetch /health` detecte backend, enrutar `doCheckin` a `POST /api/points/check-in` (endpoint nuevo en `server.js` generado) con transacción SQL.

### TD-002: Proveedor `mock` no valida la calidad real de specs LLM
- **Date:** 2026-09-20
- **Description:** El enriquecimiento determinista (`mockSpec` + `enrichEntities`) simula un LLM rico, pero no ejercita el `SYSTEM_PROMPT` real de los proveedores DeepSeek/OpenAI/Anthropic.
- **Category:** Testing
- **Severity:** High
- **Impact:** Riesgo de que, al conectar un LLM real, la calidad del spec difiera (o rompa el parser de markdown).
- **Owner:** qa_engineer
- **Due Date:** Al conectar DeepSeek real
- **Status:** Open
- **Remediation Plan:** Smoke test con proveedor real (1 prompt) y validación de que `parseProjectMd` parsea la salida; añadir fixtures de salida real.

### TD-003: Conteo de tokens del ledger es estimado (no exacto)
- **Date:** 2026-09-20
- **Description:** `token_ledger.md` registró valores estimados retroactivamente; el conteo preciso por API (`usage.prompt_tokens`/`completion_tokens`) no se persiste automáticamente en el ledger aún.
- **Category:** Observability
- **Severity:** Medium
- **Impact:** La contabilidad de costos para monetización no es exacta en histórico.
- **Owner:** cost_accountant
- **Due Date:** Antes de facturar a clientes
- **Status:** Open
- **Remediation Plan:** En `index.ts`, tras cada `generate`, escribir entrada en `backend/data/state.json` + `token_ledger.md` con `usage` real devuelto por el proveedor.

### TD-004: `node:sqlite` es experimental en Node 22
- **Date:** 2026-09-20
- **Description:** Se usa `node:sqlite` (flag `--experimental-sqlite`) tras el segfault de `better-sqlite3`. Funciona, pero es API experimental.
- **Category:** Architecture
- **Severity:** Low
- **Impact:** Posibles cambios de API al actualizar Node; no hay binario nativo que mantener.
- **Owner:** devops_engineer
- **Due Date:** Al migrar a Node 23+/LTS estable
- **Status:** Open
- **Remediation Plan:** Migrar a `better-sqlite3` estable o a Postgres en el deploy Docker cuando `node:sqlite` sea estable.

---

<!-- CASF v1.0 · generated 2026-08-06T22:51:00Z -->
