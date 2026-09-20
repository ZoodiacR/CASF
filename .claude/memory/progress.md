# 📍 Progress — Live Checkpoint

> ⚠️ **THIS IS THE RESUME FILE.** Updated by `context_manager` before/after every task. Read this first when resuming.

## 📌 Snapshot
- **Last updated:** 2026-09-20
- **Lifecycle stage:** Build (MVP entregado)
- **Current sprint:** Sprint 0 (bootstrap de CASF Studio + framework v1.0)
- **Working branch:** main
- **Last commit:** ad746e9 (framework) / sin commit aún (casf-studio)
- **Overall status:** 🟢 on track

## ✅ Completed (most recent first)
- [x] CASF Studio MVP: chat → spec (`project.md`) → build estático → tokens/costos (mock LLM, $0)
- [x] Flujo probado end-to-end (smoke test + navegador)
- [x] Botón de idioma ES/EN en la interfaz
- [x] Spec como Markdown (`project.md`) en vez de JSON
- [x] Framework v1.0: agentes `context_manager` + `cost_accountant`, comando `/resume`, `progress.md`, `token_ledger.md`
- [x] MCP de GitHub configurado (`.cursor/mcp.json`)
- [x] `VENTAJAS_COMPETITIVAS.md` + `GITHUB_GUIDE.md`

## 🔄 In progress
- [ ] Commit final de `casf-studio` (cambios idioma + markdown sin commitear)

## ⏭️ Next actions (in order)
1. Commit de `casf-studio` y `CASF` (pendiente de hacerlo con el usuario)
2. (Usuario) Crear repos privados en GitHub con PAT → ver `GITHUB_GUIDE.md`
3. Conectar proveedor LLM real (OpenAI/Anthropic) vía env vars cuando haya key

## 🚧 Blockers / pending decisions
- Publicar en GitHub: requiere PAT del usuario (sin `gh` CLI ni token en el entorno)

## 🧠 Key context / recent decisions
- Ver `.claude/memory/decisions.md` (5 decisiones 2026-09-20): monorepo, spec Markdown, capa LLM agnóstica con mock, 2 agentes nuevos, GitHub vía PAT

## 💰 Token & cost budget (last known)
- Model/API: mock (costo $0). Ledger en `casf-studio/backend/ledger.json`
- Estimado tokens (in/out): ~2,200 tok acumulados en pruebas

## 📁 Files currently being edited
- `casf-studio/frontend/src/` (App.tsx, i18n.ts, Markdown.tsx)
- `casf-studio/backend/src/` (spec.ts, llm.ts, materializer.ts, index.ts)
