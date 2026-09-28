# Changelog

All notable changes to the CASF framework are documented here.
This project adheres to [Semantic Versioning](https://semver.org/).

> **Plugin releases:** when CASF is installed as a Claude Code plugin, the `version` field in
> [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) is the cache key. Users only receive
> changes when that field is bumped — pushing commits alone is not enough. Bump it on every release.

## [1.0.0] — 2026-09-28

First public release as an installable Claude Code plugin.

### Added

- `.claude-plugin/plugin.json` — plugin manifest (14 agents, 7 commands, 1 skill).
- `.claude-plugin/marketplace.json` — marketplace catalog, so third parties can run
  `/plugin marketplace add ZoodiacR/CASF` and install it without cloning.
- `agents/` — the 14 subagents now carry YAML frontmatter. That frontmatter is what makes them
  loadable as real Claude Code subagents; before this they were prose that only a human could
  copy into a config by hand.
- `.claude/skills/casf-framework/SKILL.md` — the operating manual delivered as a skill. A
  plugin's root `CLAUDE.md` is **not** loaded as context, so the operating rules have to ship
  as a skill to reach a consumer's session.
- `LICENSE` (MIT).
- `docs/PLAN_CACHE_Y_PLUGIN.md` — research notes and execution report behind this release.

### Changed

- **Agents moved from `.claude/agents/` to the plugin root `agents/`.** Claude Code accepts an
  `agents` field in `plugin.json` at validation time but does not honour it at load time, so the
  default root `agents/` directory is the only location that reliably works. Verified empirically
  with two probe plugins.
- `README.md` installation rewritten around the plugin; agent counts corrected (12 → 14).

### Fixed

- **Agent `name` fields are now kebab-case.** Claude Code rejects underscores in subagent names
  and skips those files silently, so with the previous `snake_case` names none of the agents
  would have loaded as subagents at all.
