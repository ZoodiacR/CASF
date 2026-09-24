// Setup único: configura Claude Code globalmente para usar DeepSeek.
// Lee la key desde backend/.env y la escribe en ~/.claude/settings.json (local).
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const ENV_FILE = "d:/Trabajo/proyectos/casf-studio/backend/.env";
const SETTINGS = join(homedir(), ".claude", "settings.json");

const env = readFileSync(ENV_FILE, "utf8");
const m = env.match(/^DEEPSEEK_API_KEY=(.+)$/m);
const key = m ? m[1].trim().replace(/^"|"$/g, "") : "";

if (!key) {
  console.error("ERROR: no se encontró DEEPSEEK_API_KEY en " + ENV_FILE);
  process.exit(1);
}

let settings = {};
if (existsSync(SETTINGS)) {
  try {
    settings = JSON.parse(readFileSync(SETTINGS, "utf8"));
  } catch {
    settings = {};
  }
}

// DeepSeek expone una API compatible con Anthropic.
settings.env = {
  ANTHROPIC_BASE_URL: "https://api.deepseek.com/anthropic",
  ANTHROPIC_AUTH_TOKEN: key,
  ANTHROPIC_MODEL: "deepseek-chat",
  ANTHROPIC_SMALL_FAST_MODEL: "deepseek-chat",
  CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT: "1",
  CLAUDE_CODE_MAX_CONTEXT_TOKENS: "64000",
};

writeFileSync(SETTINGS, JSON.stringify(settings, null, 2) + "\n", "utf8");
console.log("OK: ~/.claude/settings.json configurado para DeepSeek.");
console.log("Ahora solo escribe 'claude' en cualquier terminal.");
