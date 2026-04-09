#!/bin/bash
# =============================================================================
# INSTALADOR AUTOMÁTICO DE SKILLS PARA CLAUDE CODE / COWORK
# =============================================================================
# Repositorio: https://github.com/semaes111/PROYECTO-SKILLS
#
# USO:
#   git clone https://github.com/semaes111/PROYECTO-SKILLS.git
#   cd PROYECTO-SKILLS
#   chmod +x install-skills.sh
#   ./install-skills.sh [--all | --category 01 02 03 | --list]
#
# EJEMPLOS:
#   ./install-skills.sh --all                    # Instala las 210 skills
#   ./install-skills.sh --category 01 03 07      # Solo 3D-WEB, Backend, Legal
#   ./install-skills.sh --list                   # Muestra categorías disponibles
#   ./install-skills.sh --uninstall              # Desinstala todas las skills
#   ./install-skills.sh --target /ruta/proyecto   # Instala en proyecto específico
# =============================================================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color
BOLD='\033[1m'

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=""
MODE=""
CATEGORIES=()
INSTALLED=0
SKIPPED=0

# =============================================================================
# FUNCIONES
# =============================================================================

show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     INSTALADOR DE SKILLS - PROYECTO SKILLS v4.0            ║"
    echo "║     210 skills en 22 categorías temáticas                  ║"
    echo "║     Compatible con Claude Code / Cowork                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_categories() {
    echo -e "${BOLD}Categorías disponibles:${NC}"
    echo ""
    echo -e "  ${CYAN}01${NC} - SKILLS-3D-WEB              (19 skills)  Three.js, WebGL, arte 3D, animación"
    echo -e "  ${CYAN}02${NC} - SKILLS-FRONTEND            (10 skills)  React, Next.js, UI/UX"
    echo -e "  ${CYAN}03${NC} - SKILLS-BACKEND             (11 skills)  Node, Supabase, auth, BD"
    echo -e "  ${CYAN}04${NC} - SKILLS-MOBILE-EXPO         (5 skills)   React Native, Expo"
    echo -e "  ${CYAN}05${NC} - SKILLS-DEVOPS-INFRA        (17 skills)  CI/CD, deploy, Docker, MCP, RAG"
    echo -e "  ${CYAN}06${NC} - SKILLS-DOCUMENTOS          (10 skills)  Word, PDF, Excel, PPT"
    echo -e "  ${CYAN}07${NC} - SKILLS-LEGAL-FISCAL        (10 skills)  Contratos, compliance, schema fiscal"
    echo -e "  ${CYAN}08${NC} - SKILLS-MARKETING-COPY      (8 skills)   Copy, campañas, SEO"
    echo -e "  ${CYAN}09${NC} - SKILLS-UTILIDADES          (47 skills)  CLI, scraping, git, memoria, ECC"
    echo -e "  ${CYAN}11${NC} - SKILLS-DATOS-ANALYTICS     (7 skills)   SQL, dashboards, stats"
    echo -e "  ${CYAN}12${NC} - SKILLS-INGENIERIA-SOFTWARE (6 skills)   Code review, testing"
    echo -e "  ${CYAN}13${NC} - SKILLS-FINANZAS-CONTAB     (6 skills)   Estados fin., auditoría"
    echo -e "  ${CYAN}14${NC} - SKILLS-VENTAS-CRM          (15 skills)  Sales, Apollo, CommonRoom"
    echo -e "  ${CYAN}15${NC} - SKILLS-SOPORTE-CLIENTE     (5 skills)   Tickets, KB, escalados"
    echo -e "  ${CYAN}16${NC} - SKILLS-PRODUCTO-PM         (6 skills)   PRDs, roadmaps, métricas"
    echo -e "  ${CYAN}17${NC} - SKILLS-PRODUCTIVIDAD       (2 skills)   Memoria, tareas"
    echo -e "  ${CYAN}18${NC} - SKILLS-BIOINVESTIGACION    (5 skills)   RNA-seq, Nextflow, scVI"
    echo -e "  ${CYAN}19${NC} - SKILLS-BUSQUEDA-EMPRESAR   (3 skills)   Multi-source search"
    echo -e "  ${CYAN}20${NC} - SKILLS-DISENO-UX           (6 skills)   Accesibilidad, tokens, UX writing"
    echo -e "  ${CYAN}21${NC} - SKILLS-RRHH                (6 skills)   Hiring, compensación, org"
    echo -e "  ${CYAN}22${NC} - SKILLS-OPERACIONES         (6 skills)   Procesos, compliance, riesgos"
    echo ""
    echo -e "${YELLOW}Nota:${NC} La categoría 10 (PLUGINS-Y-REPOS) contiene repos completos,"
    echo "      no skills individuales. Se copian con --all automáticamente."
}

detect_target() {
    # Si se especificó --target, usar esa ruta
    if [ -n "$TARGET_DIR" ]; then
        echo "$TARGET_DIR"
        return
    fi

    # Buscar .claude/skills en el directorio actual o padres
    local dir="$(pwd)"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.claude" ]; then
            echo "$dir/.claude/skills"
            return
        fi
        dir="$(dirname "$dir")"
    done

    # Si no existe, crear en el directorio actual
    echo "$(pwd)/.claude/skills"
}

install_skill_file() {
    local src_file="$1"
    local target_base="$2"
    local filename=$(basename "$src_file")

    # Extraer nombre funcional: quitar el sufijo -SKILL.md
    local skill_name="${filename%-SKILL.md}"

    # Crear directorio de la skill
    local skill_dir="$target_base/$skill_name"
    mkdir -p "$skill_dir"

    # Copiar como SKILL.md (nombre que Cowork espera)
    cp "$src_file" "$skill_dir/SKILL.md"

    # Copiar carpeta references si existe junto al archivo
    local src_dir=$(dirname "$src_file")
    if [ -d "$src_dir/references" ]; then
        cp -r "$src_dir/references" "$skill_dir/"
    fi
    # Buscar references asociadas por nombre
    local ref_dir="${src_file%-SKILL.md}-references"
    if [ -d "$ref_dir" ]; then
        cp -r "$ref_dir" "$skill_dir/references"
    fi

    INSTALLED=$((INSTALLED + 1))
    echo -e "  ${GREEN}✓${NC} $skill_name"
}

install_skill_dir() {
    # Instala una skill que ya es directorio con SKILL.md dentro
    local src_dir="$1"
    local target_base="$2"
    local skill_name=$(basename "$src_dir")

    local dest_dir="$target_base/$skill_name"
    mkdir -p "$dest_dir"

    # Copiar SKILL.md
    cp "$src_dir/SKILL.md" "$dest_dir/SKILL.md"

    # Copiar references si existen
    if [ -d "$src_dir/references" ]; then
        cp -r "$src_dir/references" "$dest_dir/"
    fi

    # Copiar standalone si existe (MCP servers instalables)
    if [ -d "$src_dir/standalone" ]; then
        cp -r "$src_dir/standalone" "$dest_dir/"
    fi

    # Copiar templates si existen
    for tmpl in "$src_dir"/*TEMPLATE*; do
        if [ -f "$tmpl" ]; then
            cp "$tmpl" "$dest_dir/"
        fi
    done

    INSTALLED=$((INSTALLED + 1))
    echo -e "  ${GREEN}✓${NC} $skill_name"
}

install_category() {
    local cat_num="$1"
    local target_base="$2"

    # Encontrar la carpeta que empieza con el número
    local cat_dir=$(find "$SCRIPT_DIR" -maxdepth 1 -type d -name "${cat_num}-*" | head -1)

    if [ -z "$cat_dir" ] || [ ! -d "$cat_dir" ]; then
        echo -e "  ${YELLOW}⚠ Categoría ${cat_num} no encontrada, saltando...${NC}"
        return
    fi

    local cat_name=$(basename "$cat_dir")
    echo ""
    echo -e "${BLUE}📁 Instalando: ${BOLD}$cat_name${NC}"

    local count=0

    # Modo 1: Instalar skills planas (*-SKILL.md)
    for skill_file in "$cat_dir"/*-SKILL.md; do
        if [ -f "$skill_file" ]; then
            install_skill_file "$skill_file" "$target_base"
            count=$((count + 1))
        fi
    done

    # Modo 2: Instalar skills que son directorios (contienen SKILL.md)
    for skill_subdir in "$cat_dir"/*/; do
        if [ -f "${skill_subdir}SKILL.md" ]; then
            install_skill_dir "${skill_subdir%/}" "$target_base"
            count=$((count + 1))
        fi
    done

    # Copiar references sueltas (como demandas-tributarias-references)
    for ref_dir in "$cat_dir"/*-references; do
        if [ -d "$ref_dir" ]; then
            local ref_name=$(basename "$ref_dir")
            local parent_skill="${ref_name%-references}"
            if [ -d "$target_base/$parent_skill" ]; then
                cp -r "$ref_dir" "$target_base/$parent_skill/references" 2>/dev/null || true
            fi
        fi
    done

    if [ $count -eq 0 ]; then
        echo -e "  ${YELLOW}(sin skills individuales en esta categoría)${NC}"
        SKIPPED=$((SKIPPED + 1))
    fi
}

install_plugins() {
    local target_base="$1"
    local plugins_dir="$SCRIPT_DIR/10-PLUGINS-Y-REPOS"

    if [ -d "$plugins_dir" ]; then
        echo ""
        echo -e "${BLUE}📦 Copiando plugins y repos...${NC}"

        # Crear carpeta _plugins en el destino
        mkdir -p "$target_base/../plugins"
        cp -r "$plugins_dir"/* "$target_base/../plugins/" 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} software-architect"
        echo -e "  ${GREEN}✓${NC} knowledge-work-plugins"
    fi
}

do_uninstall() {
    local target=$(detect_target)
    echo -e "${YELLOW}⚠ Esto eliminará todas las skills instaladas desde este repo en:${NC}"
    echo "  $target"
    echo ""
    read -p "¿Continuar? (s/N): " confirm
    if [ "$confirm" != "s" ] && [ "$confirm" != "S" ]; then
        echo "Cancelado."
        exit 0
    fi

    # Leer skills del repo y eliminar las que coincidan
    local removed=0
    for cat_dir in "$SCRIPT_DIR"/0*-SKILLS-* "$SCRIPT_DIR"/1[0-9]-SKILLS-*; do
        if [ -d "$cat_dir" ]; then
            for skill_file in "$cat_dir"/*-SKILL.md; do
                if [ -f "$skill_file" ]; then
                    local filename=$(basename "$skill_file")
                    local skill_name="${filename%-SKILL.md}"
                    if [ -d "$target/$skill_name" ]; then
                        rm -rf "$target/$skill_name"
                        echo -e "  ${RED}✗${NC} Eliminado: $skill_name"
                        removed=$((removed + 1))
                    fi
                fi
            done
        fi
    done

    echo ""
    echo -e "${GREEN}Desinstalación completada: $removed skills eliminadas.${NC}"
}

# =============================================================================
# PARSEO DE ARGUMENTOS
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            MODE="all"
            shift
            ;;
        --category)
            MODE="category"
            shift
            while [[ $# -gt 0 ]] && [[ "$1" != --* ]]; do
                CATEGORIES+=("$1")
                shift
            done
            ;;
        --list)
            show_banner
            show_categories
            exit 0
            ;;
        --uninstall)
            show_banner
            do_uninstall
            exit 0
            ;;
        --target)
            shift
            TARGET_DIR="$1/.claude/skills"
            shift
            ;;
        --help|-h)
            show_banner
            echo "Uso: ./install-skills.sh [OPCIÓN]"
            echo ""
            echo "Opciones:"
            echo "  --all                    Instala las 210 skills completas"
            echo "  --category 01 03 07      Instala solo las categorías indicadas"
            echo "  --list                   Muestra categorías disponibles"
            echo "  --target /ruta/proyecto  Instala en un proyecto específico"
            echo "  --uninstall              Desinstala skills de este repo"
            echo "  --help                   Muestra esta ayuda"
            echo ""
            echo "Si no se usa --target, busca .claude/skills en el directorio"
            echo "actual o lo crea si no existe."
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Opción desconocida '$1'. Usa --help para ver opciones.${NC}"
            exit 1
            ;;
    esac
done

# =============================================================================
# EJECUCIÓN PRINCIPAL
# =============================================================================

show_banner

if [ -z "$MODE" ]; then
    echo "Usa --all para instalar todo, --category para seleccionar, o --help."
    echo ""
    show_categories
    exit 0
fi

# Detectar directorio destino
TARGET=$(detect_target)
mkdir -p "$TARGET"

echo -e "📍 Destino: ${BOLD}$TARGET${NC}"
echo -e "📂 Fuente:  ${BOLD}$SCRIPT_DIR${NC}"

if [ "$MODE" = "all" ]; then
    # Instalar todas las categorías
    for num in 01 02 03 04 05 06 07 08 09 11 12 13 14 15 16 17 18 19 20 21 22; do
        install_category "$num" "$TARGET"
    done
    install_plugins "$TARGET"

elif [ "$MODE" = "category" ]; then
    for cat in "${CATEGORIES[@]}"; do
        # Asegurar formato 2 dígitos
        cat_padded=$(printf "%02d" "$cat")
        install_category "$cat_padded" "$TARGET"
    done
fi

# Copiar índice maestro
cp "$SCRIPT_DIR/INDICE-MAESTRO-SKILLS.md" "$TARGET/../INDICE-MAESTRO-SKILLS.md" 2>/dev/null || true

echo ""
echo -e "═══════════════════════════════════════════════════════"
echo -e "${GREEN}${BOLD}✅ Instalación completada${NC}"
echo -e "   Skills instaladas: ${GREEN}${BOLD}$INSTALLED${NC}"
[ $SKIPPED -gt 0 ] && echo -e "   Categorías vacías:  ${YELLOW}$SKIPPED${NC}"
echo -e "   Ubicación: ${BOLD}$TARGET${NC}"
echo -e "═══════════════════════════════════════════════════════"
echo ""
echo -e "${CYAN}Las skills estarán disponibles en tu próxima sesión de Claude Code / Cowork.${NC}"
echo -e "${CYAN}Reinicia la sesión o recarga el proyecto para activarlas.${NC}"
