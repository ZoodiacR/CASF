# 🔐 Guía de GitHub — Crear los repos privados y subir el código (Opción A: PAT)

> Cómo publicar **CASF Studio** (front + back) y **CASF v1.0** en repos privados usando un **Personal Access Token (PAT)**. Es la opción más automatizada.

---

## Repos a crear

| Repo | Contenido | Visibilidad |
|---|---|---|
| `casf-studio` | `casf-studio/` (frontend + backend del producto) | **privado** |
| `casf` (o `casf-v1`) | `CASF/` (el framework, ya no beta, producto v1.0) | **privado** |

---

## Paso 1 — Crear el PAT (una sola vez)

1. Ve a **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**.
2. Clic en **Generate new token (classic)**.
3. Nombre: `casf-deploy`.
4. Expiración: la que prefieras (90 días está bien).
5. **Scopes:** marca `repo` (te da acceso completo a repos privados). Opcional: `workflow` si quieres GitHub Actions.
6. **Genera y copia el token** (solo se muestra una vez). Guárdalo en un gestor de contraseñas.

> ⚠️ No lo pegues en archivos que se vayan a commitear. Usa variable de entorno.

---

## Paso 2 — Configurar el MCP de GitHub (ya dejado listo)

El archivo `.cursor/mcp.json` ya está configurado con el servidor oficial `github/github-mcp-server`. Solo reemplaza el token:

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "TU_PAT_AQUI"
      }
    }
  }
}
```

Luego **recarga Cursor** (o reinicia el servidor MCP) para que se active.

> Requiere **Docker**. Si no lo tienes, usa la alternativa CLI del Paso 3.

---

## Paso 3 — Alternativa con `gh` CLI (o git directo)

### 3a. Instalar y autenticar `gh`
```bash
# Windows (winget)
winget install GitHub.cli
# o descarga desde https://cli.github.com

gh auth login          # elige "GitHub.com" → "HTTPS" → pega el PAT
```

### 3b. Crear los repos privados y subir

**Repo 1 — casf-studio:**
```bash
cd D:/Trabajo/proyectos/casf-studio
git init -b main
git add .
git commit -m "feat: CASF Studio MVP (chat → spec → build → costos)"
gh repo create casf-studio --private --source=. --remote=origin --push
```

**Repo 2 — casf (framework v1.0):**
```bash
cd D:/Trabajo/proyectos/CASF
gh repo create casf --private --source=. --remote=origin --push
```

### 3c. Sin `gh` (git + API)
```bash
# crear repo privado vía API
curl -X POST -H "Authorization: token TU_PAT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"casf-studio","private":true}'

# subir
cd D:/Trabajo/proyectos/casf-studio
git init -b main && git add . && git commit -m "init"
git remote add origin https://TU_USUARIO:TU_PAT@github.com/TU_USUARIO/casf-studio.git
git push -u origin main
```

> Repite con `casf` para el framework.

---

## Notas

- El repo local de **CASF ya apunta** a `github.com/ZoodiacR/CASF` (público). Si quieres que v1.0 sea privado, usa el comando del Paso 3b/3c para apuntar a un repo **nuevo y privado** (p. ej. `casf`).
- Los archivos `backend/generated/`, `backend/ledger.json`, `node_modules/` y `dist/` ya están en `.gitignore` de casf-studio.

<!-- CASF · github guide -->
