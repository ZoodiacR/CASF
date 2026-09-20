# .claude\ — CASF Framework

Structure:
- agents\     -> Specialist agent definitions (12 agents, incl. context_manager + cost_accountant)
- commands\   -> Slash commands (/start-project, /new-sprint, /review, /ship, /recover, /resume, /status)
- workflows\  -> Multi-step orchestrated processes
- templates\  -> Reusable document templates
- memory\     -> Long-term project memory (progress.md checkpoint, decisions, lessons, tech debt, token ledger)
- logs\       -> Session logs

This is CASF v1.0 — the product (no longer beta). The bootstrap stubs have been materialized.
