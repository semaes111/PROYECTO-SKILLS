#!/bin/bash
# Importa una skill ECC al repo (formato folder + frontmatter estandarizado)
# Uso: ./scripts/import-ecc-skill.sh <ecc-name> <nombre-español> <prefijo-categoria> [/ruta/ECC]
# Ej:  ./scripts/import-ecc-skill.sh docker-patterns docker-patrones-multi-stage 05
set -euo pipefail
ECC_NAME="$1"; ES_NAME="$2"; CAT_PREFIX="$3"
ECC_DIR="${4:-$HOME/repos/ECC}"
PS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATE=$(date +%Y-%m-%d)
REF=$(cd "$ECC_DIR" && git log -1 --format="main@%h" 2>/dev/null || echo "desconocido")

CAT_DIR=$(ls -d "$PS_DIR"/${CAT_PREFIX}-* 2>/dev/null | head -1)
[ -z "$CAT_DIR" ] && { echo "❌ Categoría $CAT_PREFIX no encontrada"; exit 1; }
SRC="$ECC_DIR/skills/$ECC_NAME/SKILL.md"
[ ! -f "$SRC" ] && { echo "❌ No existe: $SRC"; exit 1; }
DST="$CAT_DIR/$ES_NAME"
[ -d "$DST" ] && { echo "❌ Ya existe: $DST"; exit 1; }

mkdir -p "$DST"
cp "$SRC" "$DST/SKILL.md"
for extra in scripts references examples; do
  [ -d "$ECC_DIR/skills/$ECC_NAME/$extra" ] && cp -r "$ECC_DIR/skills/$ECC_NAME/$extra" "$DST/"
done

python3 - "$DST/SKILL.md" "$ECC_NAME" "$REF" "$DATE" << 'PYEOF'
import sys
path, src, ref, date = sys.argv[1:5]
lines = open(path, encoding='utf-8').read().split('\n')
if lines[0] != '---':
    lines = ['---', f'name: {src}', '---', ''] + lines
end = lines[1:].index('---') + 1
fm = [l for l in lines[1:end] if not l.startswith(('ecc-version:','ecc-source:','ecc-imported:'))]
if not any(l.startswith('origin:') for l in fm): fm.append('origin: ECC')
fm += [f'ecc-version: {ref}', f'ecc-source: skills/{src}', f'ecc-imported: {date}']
open(path, 'w', encoding='utf-8').write('\n'.join(['---'] + fm + lines[end:]))
PYEOF
echo "✅ Importada: $DST"
echo "   TODO: añadir sección '## Aplicación en el stack NextHorizont' si aplica"
