#!/bin/bash
# =============================================================================
# install-efficiency-pack.sh
# Instala SOLO las skills de ahorro de tokens + calidad de proyecto-skills
# en el destino indicado, en formato ~/.claude/skills/<nombre>/SKILL.md
# (autodescubierto por Claude Code / Cowork vía description, carga bajo demanda)
#
# Uso:
#   ./scripts/install-efficiency-pack.sh                 # instala en ./.claude/skills (proyecto actual)
#   ./scripts/install-efficiency-pack.sh --global        # instala en ~/.claude/skills (todos los proyectos)
#   ./scripts/install-efficiency-pack.sh --target /ruta  # instala en /ruta/.claude/skills
# =============================================================================
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"

# Resolver destino
if [ "${1:-}" = "--global" ]; then
  DEST="$HOME/.claude/skills"
elif [ "${1:-}" = "--target" ] && [ -n "${2:-}" ]; then
  DEST="$2/.claude/skills"
else
  DEST="$(pwd)/.claude/skills"
fi
mkdir -p "$DEST"

# Pack de eficiencia: ruta_en_repo -> nombre_skill_destino
PACK="
09-SKILLS-UTILIDADES/compactacion-estrategica|strategic-compact
09-SKILLS-UTILIDADES/auditoria-contexto-tokens-SKILL.md|context-budget
05-SKILLS-DEVOPS-INFRA/monitoreo-coste-tokens-llm|cost-tracking
05-SKILLS-DEVOPS-INFRA/pipeline-llm-cost-aware|cost-aware-llm-pipeline
05-SKILLS-DEVOPS-INFRA/optimizacion-consumo-tokens-openclaw|optimizacion-tokens-openclaw
09-SKILLS-UTILIDADES/aprendizaje-continuo-v2-instintos-SKILL.md|continuous-learning-v2
09-SKILLS-UTILIDADES/verificacion-quality-gates-SKILL.md|verification-loop
09-SKILLS-UTILIDADES/busqueda-antes-codigo-disciplina|search-first
09-SKILLS-UTILIDADES/tdd-workflow-test-driven-SKILL.md|tdd-workflow
"
echo "Destino: $DEST"
echo "$PACK" | grep -v '^$' | while IFS='|' read -r src name; do
  dst="$DEST/$name"
  mkdir -p "$dst"
  if [ -d "$REPO/$src" ]; then
    # formato folder: copiar SKILL.md + references/ si existe
    cp "$REPO/$src/SKILL.md" "$dst/SKILL.md"
    [ -d "$REPO/$src/references" ] && cp -r "$REPO/$src/references" "$dst/"
    [ -d "$REPO/$src/scripts" ] && cp -r "$REPO/$src/scripts" "$dst/"
  else
    # formato flat: el archivo ES el SKILL.md
    cp "$REPO/$src" "$dst/SKILL.md"
  fi
  echo "  ✅ $name"
done
echo ""
echo "Instaladas 9 skills del pack de eficiencia en $DEST"
echo "Claude las invocará automáticamente cuando el contexto coincida con su 'description'."
