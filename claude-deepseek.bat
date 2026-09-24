@echo off
REM =============================================================================
REM  Lanza Claude Code (interactivo) conectado a DeepSeek, con el framework CASF
REM  cargado desde d:\Trabajo\proyectos\CASF
REM
REM  Uso: haz doble clic en este archivo, o ejecutalo desde una terminal.
REM =============================================================================
setlocal EnableDelayedExpansion

set "FRAMEWORK_DIR=d:\Trabajo\proyectos\CASF"
set "ENV_FILE=d:\Trabajo\proyectos\casf-studio\backend\.env"

REM --- Verificar que claude existe en el PATH ---
where claude >nul 2>nul
if errorlevel 1 (
  echo [ERROR] No se encontro "claude" en el PATH.
  echo         Instalalo con: npm install -g @anthropic-ai/claude-code
  pause
  exit /b 1
)

REM --- Leer la API key de DeepSeek desde el .env ---
set "KEY="
for /f "usebackq tokens=1,* delims==" %%a in (`findstr /b "DEEPSEEK_API_KEY=" "%ENV_FILE%"`) do set "KEY=%%b"
REM limpiar comillas y espacios
set "KEY=!KEY:"=!"
set "KEY=!KEY: =!"

if "!KEY!"=="" (
  echo [ERROR] No se encontro DEEPSEEK_API_KEY en %ENV_FILE%
  echo         Revisa que la linea diga: DEEPSEEK_API_KEY=sk-...
  pause
  exit /b 1
)

REM --- DeepSeek expone una API compatible con Anthropic ---
set "ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic"
set "ANTHROPIC_AUTH_TOKEN=!KEY!"
set "ANTHROPIC_MODEL=deepseek-chat"
set "ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat"
set "CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1"
set "CLAUDE_CODE_MAX_CONTEXT_TOKENS=64000"
set "DISABLE_AUTOUPDATER=1"

cd /d "%FRAMEWORK_DIR%"

echo ==============================================
echo  Claude Code + DeepSeek (deepseek-chat)
echo  Framework: %FRAMEWORK_DIR%
echo ==============================================
echo.

call claude

echo.
echo ==============================================
echo  Claude Code cerro. Presiona una tecla para salir.
echo ==============================================
pause
