# 🧠 PROYECTO SKILLS — 141 Skills para Claude Code / Cowork

Colección completa de **141 skills** organizadas en **19 categorías temáticas** + plugins, lista para instalar en cualquier terminal de Claude Code o sesión de Cowork.

---

## ⚡ Instalación Rápida (3 comandos)

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

## 📦 Instalación Selectiva

Si solo quieres instalar categorías específicas:

```bash
# Ver categorías disponibles
./install-skills.sh --list

# Instalar solo Backend + Frontend + Legal
./install-skills.sh --category 02 03 07

# Instalar en un proyecto específico
./install-skills.sh --all --target /ruta/a/mi-proyecto
```

---

## 🗂 Categorías

| # | Categoría | Skills | Contenido |
|---|-----------|--------|-----------|
| 01 | 3D / Web | 7 | Three.js, WebGL, portfolios 3D, arte generativo |
| 02 | Frontend | 10 | React/Next.js, UI/UX, animaciones, temas |
| 03 | Backend | 11 | Node/Go/Python, Supabase, auth, bases de datos |
| 04 | Mobile / Expo | 5 | React Native, Expo Router, NativeWind |
| 05 | DevOps / Infra | 7 | CI/CD, deploy, dependencias, PaaS |
| 06 | Documentos | 10 | Word, PDF, Excel, PowerPoint, diagramas |
| 07 | Legal / Fiscal | 9 | Contratos, compliance, GDPR, NDA, demandas tributarias |
| 08 | Marketing / Copy | 8 | Copywriting, campañas, SEO, brand voice |
| 09 | Utilidades | 19 | CLI tools, scraping, git, comunicación, meta-skills |
| 10 | Plugins y Repos | — | software-architect + knowledge-work-plugins |
| 11 | Datos / Analytics | 7 | SQL, dashboards, visualización, estadística |
| 12 | Ingeniería Software | 6 | Code review, system design, testing, incidents |
| 13 | Finanzas / Contabilidad | 6 | Estados financieros, SOX, conciliación |
| 14 | Ventas / CRM | 15 | Sales, Apollo, Common Room |
| 15 | Soporte Cliente | 5 | Triaje tickets, respuestas, KB, escalados |
| 16 | Producto / PM | 6 | PRDs, roadmaps, métricas, research |
| 17 | Productividad | 2 | Sistema memoria, gestión tareas |
| 18 | Bioinvestigación | 5 | Single-cell RNA, Nextflow, scVI |
| 19 | Búsqueda Empresarial | 3 | Búsqueda multi-fuente empresarial |

---

## 🔧 Cómo Funciona

Claude Code / Cowork detecta skills automáticamente en la carpeta `.claude/skills/` de tu proyecto. Cada skill necesita esta estructura:

```
tu-proyecto/
└── .claude/
    └── skills/
        ├── nombre-de-skill/
        │   └── SKILL.md          ← Archivo obligatorio
        │   └── references/       ← Opcional: archivos de soporte
        ├── otra-skill/
        │   └── SKILL.md
        └── ...
```

El script `install-skills.sh` se encarga de:
1. Leer cada archivo `*-SKILL.md` del repo
2. Crear la carpeta con el nombre funcional de la skill
3. Renombrarlo a `SKILL.md` dentro de esa carpeta
4. Copiar carpetas `references/` asociadas si existen

---

## 🔄 Actualización

```bash
cd PROYECTO-SKILLS
git pull
./install-skills.sh --all
```

---

## 🗑 Desinstalación

```bash
./install-skills.sh --uninstall
```

---

## 📋 Índice Completo

Consulta el archivo [INDICE-MAESTRO-SKILLS.md](./INDICE-MAESTRO-SKILLS.md) para ver la tabla completa con:
- Nombre funcional de cada skill
- Descripción de qué hace
- Fuente original

---

## 🔑 Requisitos

- **Git** instalado
- **Claude Code** o **Cowork** configurado
- Terminal con bash (Linux, macOS, WSL, Git Bash en Windows)

Para Windows nativo sin WSL, puedes ejecutar el script con Git Bash que viene incluido con Git for Windows.

---

*Última actualización: 8 de abril de 2026*
*Mantenido por: semaes111*
