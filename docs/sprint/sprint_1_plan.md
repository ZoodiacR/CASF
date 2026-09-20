# Sprint 1 Plan: SaaS de Fidelidad QR + Citas + Puntos (Prueba de fuego)

> Gestionado por el framework CASF como prueba de fuego end-to-end.
> Objetivo: demostrar que un prompt breve genera un SaaS completo y comercializable,
> con todo el proceso (spec → decisiones → build → verificación) visible en CASF Studio.

---

## Sprint Overview

- **Sprint Number:** Sprint 1 (prueba de fuego)
- **Duration:** Sesión única (incremental, sin fecha fija)
- **Theme:** SaaS de fidelización con QR, agenda de citas, sistema de puntos y bot de ayuda

## Sprint Goals

1. Enriquecer el dominio "Loyalty & Appointments Suite" en el generador de specs (`llm.ts`)
2. Materializar widgets funcionales de fidelidad en el materializador (`materializer.ts`): QR, puntos, citas, recompensas y bot de ayuda
3. Exponer la documentación y planificación del framework dentro de CASF Studio (pestaña Docs + endpoint `/api/docs`)
4. Añadir bucle de feedback editable del spec (endpoint `/api/spec/feedback` + UI) para ajustar la app iterativamente
5. Prueba de fuego end-to-end: prompt breve → spec rico → decisiones → build → verificación visual

## Success Definition

- Un prompt breve (p. ej. "app de fidelidad con QR y citas") produce un `ProjectSpec` rico: 5+ entidades, 6+ páginas, 8+ features
- La app generada es funcional: CRUD de clientes, puntos, citas y recompensas, con QR por cliente y bot de ayuda
- El spec es editable mediante feedback en lenguaje natural desde CASF Studio
- La planificación y la documentación del framework se ven dentro de CASF Studio

## Task Breakdown

### Generador de specs (backend_architect)
1. **Dominio Loyalty & Appointments en `llm.ts`**
   - Acceptance: keywords `fidelidad/loyalty/qr/puntos/reward/cita` mapean a un spec rico con entidades Customer, Appointment, PointsTransaction, Reward, Service
   - Effort: 1 sesión
   - Status: ✅ Done

### Materializador (frontend_architect)
2. **Widgets de fidelidad en `materializer.ts`**
   - Acceptance: `renderLoyalty` dibuja KPIs, tarjetas de cliente con QR, transacciones de puntos, agenda de citas y catálogo de recompensas; `renderHelpBot` ofrece bot de ayuda para reservar citas
   - Effort: 1 sesión
   - Status: ✅ Done

### CASF Studio — integración (frontend_architect + backend_architect)
3. **Pestaña Docs/Sprints**
   - Acceptance: endpoint `GET /api/docs` lista artefactos del framework; componente `Docs.tsx` los muestra agrupados
   - Effort: 1 sesión
   - Status: ✅ Done

4. **Feedback editable del spec**
   - Acceptance: endpoint `POST /api/spec/feedback` ajusta spec (tema, idioma, moneda, login, renombrar, features); UI en Chat permite aplicar feedback y ver cambios
   - Effort: 1 sesión
   - Status: ✅ Done

### QA
5. **Prueba de fuego end-to-end**
   - Acceptance: prompt breve → spec rico → decisiones → build → app visible en preview `:8090`
   - Effort: 1 sesión
   - Status: ⏳ Pending

### Retrospectiva (project_orchestrator)
6. **Retro + actualizar memoria del framework**
   - Acceptance: `progress.md` actualizado con resultados; lecciones registradas en `lessons_learned.md`
   - Effort: 1 sesión
   - Status: ⏳ Pending

## Execution Plan

1. Dominio → 2. Widgets (en paralelo con 3. Docs y 4. Feedback) → 5. Prueba → 6. Retro

**Parallel Opportunities:**
- El materializador y la integración de Studio pueden avanzar en paralelo
- El bucle de feedback se puede validar con la misma prueba de fuego

**Risks and Mitigation:**
- **Risk:** el spec breve produce una app pobre
  - **Mitigation:** paso de enriquecimiento garantizado en `llm.ts`
- **Risk:** la app generada parece mockup, no funcional
  - **Mitigation:** materializador con CRUD + widgets de dominio + fallback localStorage
- **Risk:** el preview no se levanta solo
  - **Mitigation:** servidor de preview `:8090` + iframe en Studio + botón "abrir en pestaña"

## Definition of Done
- Todos los tasks con acceptance cumplidos
- Spec rico garantizado desde prompt breve
- App funcional y estéticamente profesional
- Feedback del spec operativo en Studio
- Documentación y plan visibles en Studio

## Success Criteria
- La prueba de fuego produce un SaaS de fidelidad funcional desde un prompt breve
- El usuario ve el proceso completo (spec, decisiones, build, preview) en CASF Studio
- El spec es ajustable con feedback en lenguaje natural
- La memoria del framework refleja todo el proceso para poder retomarlo

---
<!-- CASF v1.0 · sprint plan -->
