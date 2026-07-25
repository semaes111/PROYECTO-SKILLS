#!/usr/bin/env bash
set -euo pipefail
command -v npm >/dev/null || { echo 'ERROR: npm no está instalado' >&2; exit 1; }
npm install -g @colbymchenry/codegraph
command -v codegraph >/dev/null || { echo 'ERROR: codegraph no quedó en PATH' >&2; exit 1; }
codegraph telemetry off || true
for target in codex claude cursor; do
  echo "=== Configuración MCP para $target ==="
  codegraph install --print-config "$target" || true
done
if [[ "${1:-}" == "--apply" ]]; then
  codegraph install --target=codex,claude,cursor --yes
else
  echo 'Configuración no escrita. Reejecuta con --apply tras revisar la salida.'
fi
codegraph --version
