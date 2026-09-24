#!/usr/bin/env bash
# =============================================================================
# Lanza Claude Code (headless) conectado a DeepSeek, con el framework CASF
# cargado desde el directorio raíz del framework.
#
# Uso:
#   ./claude-deepseek.sh "tu prompt aquí"
#   ./claude-deepseek.sh            # sin prompt → modo interactivo
# =============================================================================

# Directorio del framework CASF (donde están .claude/agents, CLAUDE.md, etc.)
FRAMEWORK_DIR="d:/Trabajo/proyectos/CASF"

# Cargar la API key de DeepSeek desde el .env del backend de casf-studio.
ENV_FILE="d:/Trabajo/proyectos/casf-studio/backend/.env"
if [ -f "$ENV_FILE" ]; then
  KEY=$(grep '^DEEPSEEK_API_KEY=' "$ENV_FILE" | cut -d= -f2- | tr -d '"' | tr -d ' ')
fi
if [ -z "$KEY" ]; then
  echo "❌ No se encontró DEEPSEEK_API_KEY en $ENV_FILE"
  exit 1
fi

# DeepSeek expone una API compatible con Anthropic.
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$KEY"
export ANTHROPIC_MODEL="deepseek-chat"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-chat"
# Silenciar el warning de "modelo no reconocido" y fijar ventana de contexto.
export CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT="1"
export CLAUDE_CODE_MAX_CONTEXT_TOKENS="64000"
export DISABLE_AUTOUPDATER="1"

cd "$FRAMEWORK_DIR" || exit 1

echo "=============================================="
echo " Claude Code  +  DeepSeek (deepseek-chat)"
echo " Framework:  $FRAMEWORK_DIR"
echo "=============================================="

if [ -n "$1" ]; then
  # Modo headless: responde y termina.
  claude -p "$*"
else
  # Modo interactivo.
  claude
fi
