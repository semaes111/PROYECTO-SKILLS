# 21 — Hooks Runtime (Claude Code)

Hooks Node.js que se ejecutan en PreToolUse/PostToolUse de Claude Code.

⚠️ **ATENCIÓN**: estos scripts ejecutan código en cada acción del agente.
Auditados el 2026-06-12 contra ECC main@5b173d2. Hashes en `HASHES-AUDITORIA-2026-06-12.txt`.
Si se actualizan desde upstream: re-auditar y regenerar hashes.

## Hooks incluidos (cherry-pick auditado)

| Hook | Evento | Función | Resultado auditoría |
|---|---|---|---|
| post-edit-typecheck.js | PostToolUse Edit\|Write | `tsc --noEmit` tras editar .ts/.tsx | ✅ Solo execFileSync de tsc local. Sin red. |
| check-console-log.js | PostToolUse Edit\|Write | Avisa de console.log en archivos modificados | ✅ Solo lectura git + fs. Sin red. |
| block-no-verify.js | PreToolUse Bash | Bloquea `git commit --no-verify` | ✅ Análisis de comando. Sin red. |
| quality-gate.js | PreToolUse Bash (commit) | Lint+format check pre-commit | ✅ spawnSync de formatter local. Sin red. |

## Dependencias incluidas

`lib/utils.js`, `lib/resolve-formatter.js`, `lib/package-manager.js`, `lib/agent-data-home.js`
(cierre de dependencias verificado — los hooks funcionan standalone copiando scripts/ + lib/).

## Instalación en un proyecto

Ver `INSTALACION.md`.
