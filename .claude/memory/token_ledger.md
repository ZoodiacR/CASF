# 💰 Token & Cost Ledger

> Maintained by `cost_accountant`. Append-only. Prices are estimates in USD per 1M tokens; verify against the provider's current pricing page.

## Running totals
- **Total tokens:** ~30k in / ~48k out (est., desarrollo completo de CASF Studio)
- **Total cost:** ~$0.02 (est., mock/deepseek simulado — sin llamadas reales pagadas)
- **Active model:** mock (deepseek-chat simulado)

## Entries

```
# 2026-09-20 ~16:00 (UTC-5) model=deepseek-chat(mock) | in~2400 out~1800 | cost~$0.0002 | src=estimate | note=smoke test flujo chat→spec→build (mock, sin API real)
# 2026-09-20 ~17:00 (UTC-5) model=deepseek-chat(mock) | in~6000 out~9000 | cost~$0.004 | src=estimate | note=iteración materializador + widgets fidelidad + i18n + tema/moneda
# 2026-09-20 ~18:00 (UTC-5) model=deepseek-chat(mock) | in~8000 out~16000 | cost~$0.007 | src=estimate | note=check-in QR + CRUD SaaS + Docker + feedback complejo + editor spec
# 2026-09-20 ~18:30 (UTC-5) model=deepseek-chat(mock) | in~6000 out~12000 | cost~$0.005 | src=estimate | note=endpoint /api/spec/parse + docs tab + memoria framework + .gitignore
```

> ⚠️ Valores estimados. A partir de la conexión a un proveedor real, cada `generate` debe persistir `usage` real aquí de inmediato (ver TD-003 en tech_debt.md).

<!-- CASF v1.1 · token_ledger -->
