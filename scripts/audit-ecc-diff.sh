#!/bin/bash
# Genera REPORTE-DIFF-ECC-<fecha>.md con diffs por skill emparejada
# Uso: ./scripts/audit-ecc-diff.sh [/ruta/a/ECC]
set -euo pipefail

ECC_DIR="${1:-$HOME/repos/ECC}"
PS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATE=$(date +%Y-%m-%d)
REPORT="$PS_DIR/REPORTE-DIFF-ECC-$DATE.md"
ECC_REF=$(cd "$ECC_DIR" && git log -1 --format="main@%h (%cd)" --date=short 2>/dev/null || echo "desconocido")

declare -A MAPPING=(
  ["continuous-learning"]="09-SKILLS-UTILIDADES/aprendizaje-continuo-auto-SKILL.md"
  ["continuous-learning-v2"]="09-SKILLS-UTILIDADES/aprendizaje-continuo-v2-instintos-SKILL.md"
  ["verification-loop"]="09-SKILLS-UTILIDADES/verificacion-quality-gates-SKILL.md"
  ["strategic-compact"]="09-SKILLS-UTILIDADES/compactacion-estrategica/SKILL.md"
  ["context-budget"]="09-SKILLS-UTILIDADES/auditoria-contexto-tokens-SKILL.md"
  ["autonomous-loops"]="09-SKILLS-UTILIDADES/bucles-autonomos-agentes-SKILL.md"
  ["security-review"]="05-SKILLS-DEVOPS-INFRA/auditoria-seguridad-review/SKILL.md"
  ["codebase-onboarding"]="09-SKILLS-UTILIDADES/onboarding-codebase-exploracion-SKILL.md"
  ["blueprint"]="09-SKILLS-UTILIDADES/blueprint-planificacion-features-SKILL.md"
  ["rules-distill"]="09-SKILLS-UTILIDADES/extraccion-reglas-distill/SKILL.md"
  ["tdd-workflow"]="09-SKILLS-UTILIDADES/tdd-workflow-test-driven-SKILL.md"
)

{
  echo "# Reporte de diff ECC -> proyecto-skills — $DATE"
  echo ""
  echo "- ECC ref: \`$ECC_REF\`"
  echo "- ECC dir: \`$ECC_DIR\`"
  echo ""
  for ecc_skill in $(echo "${!MAPPING[@]}" | tr ' ' '\n' | sort); do
    ps_path="${MAPPING[$ecc_skill]}"
    ecc_file="$ECC_DIR/skills/$ecc_skill/SKILL.md"
    ps_file="$PS_DIR/$ps_path"
    echo "## $ecc_skill"
    echo ""
    echo "- ECC: \`skills/$ecc_skill/SKILL.md\`"
    echo "- ES:  \`$ps_path\`"
    if [ ! -f "$ecc_file" ]; then echo "" ; echo "> ⚠️ ECC file no encontrado"; echo ""; continue; fi
    if [ ! -f "$ps_file" ]; then echo "" ; echo "> ⚠️ proyecto-skills file no encontrado"; echo ""; continue; fi
    ecc_lines=$(wc -l < "$ecc_file"); ps_lines=$(wc -l < "$ps_file")
    ecc_ver=$(grep -m1 '^version:' "$ecc_file" | sed 's/version: *//' || true)
    echo "- Líneas: ECC=$ecc_lines | ES=$ps_lines | Delta=$((ps_lines - ecc_lines))"
    [ -n "${ecc_ver:-}" ] && echo "- Versión ECC declarada: $ecc_ver"
    echo ""
    echo "### Secciones (##) solo en ECC"
    echo '```'
    comm -23 <(grep '^## ' "$ecc_file" | sort -u) <(grep '^## ' "$ps_file" | sort -u) | sed 's/^## //' || true
    echo '```'
    echo "### Secciones (##) solo en ES"
    echo '```'
    comm -13 <(grep '^## ' "$ecc_file" | sort -u) <(grep '^## ' "$ps_file" | sort -u) | sed 's/^## //' || true
    echo '```'
    echo ""
    echo "---"
    echo ""
  done
} > "$REPORT"
echo "Reporte generado: $REPORT"
