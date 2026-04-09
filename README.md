# PROYECTO SKILLS — 194 Skills para Claude Code / Cowork

Colección curada de **194 skills funcionales** organizadas en **17 categorías temáticas**, lista para instalar en cualquier terminal de Claude Code o sesión de Cowork.

> Cada skill tiene contenido real (50+ líneas mínimo) con instrucciones, patrones, ejemplos y contexto suficiente para que Claude las ejecute de forma autónoma.

---

## Instalación Rápida (3 comandos)

```bash
# 1. Clonar el repositorio
git clone https://github.com/semaes111/PROYECTO-SKILLS.git

# 2. Entrar y dar permisos
cd PROYECTO-SKILLS && chmod +x install-skills.sh

# 3. Instalar TODAS las skills
./install-skills.sh --all
```

**Eso es todo.** Las skills estarán disponibles en tu próxima sesión de Claude.

---

## Instalación Selectiva

```bash
# Ver categorías disponibles
./install-skills.sh --list

# Instalar solo Backend + Frontend + Legal
./install-skills.sh --category 02 03 07

# Instalar en un proyecto específico
./install-skills.sh --all --target /ruta/a/mi-proyecto
```

---

## Categorías Disponibles

| # | Categoría | Skills | Cobertura |
|---|-----------|--------|-----------|
| 01 | **3D-WEB** | 19 | Three.js, WebGL, shaders, animaciones, Spline, Rive, Remotion |
| 02 | **FRONTEND** | 12 | React, Next.js, Electron, GSAP, DESIGN.md, temas, Vercel |
| 03 | **BACKEND** | 18 | Node, Supabase, MongoDB, Qdrant, AI SDK, MCP servers, workers |
| 04 | **MOBILE-EXPO** | 5 | React Native, Expo Router, NativeWind, EAS |
| 05 | **DEVOPS-INFRA** | 17 | Docker, CI/CD, n8n, migraciones, seguridad, RAG, memoria 7-capas |
| 06 | **DOCUMENTOS** | 10 | Word, PDF, Excel, PPT, C4 diagrams, co-autoría |
| 07 | **LEGAL-FISCAL** | 10 | Contratos, compliance, due diligence, RD 214/2025, demandas |
| 08 | **MARKETING-COPY** | 8 | Copywriting, campañas, SEO, psicología, voz de marca |
| 09 | **UTILIDADES** | 46 | CLI, scraping, git, memoria, multi-agente, TDD, prompts |
| 11 | **DATOS-ANALYTICS** | 7 | SQL, dashboards, estadística, visualización, perfilado |
| 13 | **FINANZAS-CONTAB** | 6 | Estados financieros, auditoría SOX, cierre mensual |
| 14 | **VENTAS-CRM** | 15 | Sales, Apollo, CommonRoom, battlecards, outreach |
| 15 | **SOPORTE-CLIENTE** | 5 | Tickets, KB, escalados, investigación cliente |
| 16 | **PRODUCTO-PM** | 6 | PRDs, roadmaps, métricas OKR, análisis competitivo |
| 17 | **PRODUCTIVIDAD** | 2 | Memoria sesión, gestión tareas |
| 18 | **BIOINVESTIGACIÓN** | 5 | RNA-seq, Nextflow, scVI, Allotrope |
| 19 | **BÚSQUEDA-EMPRESARIAL** | 3 | Estrategia búsqueda, síntesis multifuente |
| | **TOTAL** | **194** | |

---

## Estructura del Repositorio

```
PROYECTO-SKILLS/
├── 01-SKILLS-3D-WEB/           19 skills
├── 02-SKILLS-FRONTEND/         12 skills
├── 03-SKILLS-BACKEND/          18 skills
├── 04-SKILLS-MOBILE-EXPO/       5 skills
├── 05-SKILLS-DEVOPS-INFRA/     17 skills
├── 06-SKILLS-DOCUMENTOS/       10 skills
├── 07-SKILLS-LEGAL-FISCAL/     10 skills
├── 08-SKILLS-MARKETING-COPY/    8 skills
├── 09-SKILLS-UTILIDADES/       46 skills
├── 11-SKILLS-DATOS-ANALYTICS/   7 skills
├── 13-SKILLS-FINANZAS-CONTAB/   6 skills
├── 14-SKILLS-VENTAS-CRM/       15 skills
├── 15-SKILLS-SOPORTE-CLIENTE/   5 skills
├── 16-SKILLS-PRODUCTO-PM/       6 skills
├── 17-SKILLS-PRODUCTIVIDAD/     2 skills
├── 18-SKILLS-BIOINVESTIGACION/  5 skills
├── 19-SKILLS-BUSQUEDA-EMPRES/   3 skills
├── README.md
├── GUIA-INSTALACION.md
├── INDICE-MAESTRO-SKILLS.md
└── install-skills.sh
```

---

## Verificación Post-Instalación

```bash
find ~/.claude/skills/user/ -name "*SKILL.md" | wc -l
# Esperado: 194
```

---

## Actualización

```bash
cd PROYECTO-SKILLS && git pull && ./install-skills.sh --all --force
```

---

## Requisitos

- **Git** (para clonar)
- **Claude Code** o **Cowork** (para usar las skills)

---

## Licencia

Uso personal y organizacional. Curado por **NextHorizont AI SL**.
