# Instalación de hooks en un proyecto NextHorizont

## Pre-requisitos
- Node 20+ (los contenedores del ecosistema usan node:24-bookworm-slim)
- Claude Code CLI
- TypeScript en el proyecto (para post-edit-typecheck)

## Pasos

```bash
# 1. En la raíz del proyecto Next.js
mkdir -p .claude/hooks
cp -r ~/repos/proyecto-skills/21-HOOKS-RUNTIME/scripts .claude/hooks/scripts
cp -r ~/repos/proyecto-skills/21-HOOKS-RUNTIME/lib .claude/hooks/lib

# 2. Ajustar rutas relativas de require en los hooks
#    Los hooks referencian '../lib/...': la estructura .claude/hooks/{scripts,lib} la respeta. OK.

# 3. Config
cp ~/repos/proyecto-skills/21-HOOKS-RUNTIME/configs/settings.example.json .claude/settings.json
# (o mergear el bloque "hooks" si ya existe settings.json)

# 4. Verificar integridad
cd .claude/hooks && sha256sum -c ~/repos/proyecto-skills/21-HOOKS-RUNTIME/HASHES-AUDITORIA-2026-06-12.txt
```

## Verificación funcional

1. Editar cualquier `.ts` introduciendo un error de tipos → el hook debe reportarlo.
2. Añadir `console.log` a un archivo → warning.
3. Intentar `git commit --no-verify` → bloqueado.

## Desinstalación

Eliminar el bloque `hooks` de `.claude/settings.json` y borrar `.claude/hooks/`.
