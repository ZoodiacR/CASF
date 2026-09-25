# .claude\ — CASF Framework

Structure:
- agents\     -> Specialist agent definitions (12 agents, incl. context_manager + cost_accountant)
- commands\   -> Slash commands (/start-project, /new-sprint, /review, /ship, /recover, /resume, /status)
- workflows\  -> Multi-step orchestrated processes
- templates\  -> Reusable document templates
- memory\     -> Long-term project memory (progress.md checkpoint, decisions, lessons, tech debt, token ledger)
- logs\       -> Session logs
- examples\   -> PROJECT_SPEC.md, the rich-spec benchmark
- DESIGN_SYSTEM.md / DESIGN_SYSTEM.en.md -> visual language for generated apps
- PATRON_DE_DISENO.md -> architecture blueprint
- prompts\     -> catalog.md, the ready-to-use prompt library
- CLAUDE.en.md -> English constitution (not auto-loaded; CLAUDE.md at the repo root is)

This is CASF v1.0 — the product (no longer beta). The bootstrap stubs have been materialized.
