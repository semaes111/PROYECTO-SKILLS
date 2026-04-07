# PROYECTO SKILLS — 141 Skills para Claude Code / Cowork

Coleccion completa de **141 skills** organizadas en **19 categorias tematicas** + plugins, lista para instalar en cualquier terminal de Claude Code o sesion de Cowork.

---

## INDICE

1. [Instalacion Rapida](#-instalacion-rapida-3-comandos)
2. [Instalacion Selectiva](#-instalacion-selectiva)
3. [Guia Completa Paso a Paso](#-guia-completa-paso-a-paso)
4. [Metodo Alternativo: Instalacion Manual sin Script](#-metodo-alternativo-instalacion-manual-sin-script)
5. [Metodo Cowork: Instalacion Automatica desde Sesion](#-metodo-cowork-instalacion-automatica-desde-sesion)
6. [Categorias Disponibles](#-categorias-disponibles)
7. [Como Funciona Internamente](#-como-funciona-internamente)
8. [Estructura del Repositorio](#-estructura-del-repositorio)
9. [Verificacion Post-Instalacion](#-verificacion-post-instalacion)
10. [Actualizacion](#-actualizacion)
11. [Desinstalacion](#-desinstalacion)
12. [Troubleshooting](#-troubleshooting)
13. [Requisitos](#-requisitos)

---

## Instalacion Rapida (3 comandos)

```bash
# 1. Clonar el repositorio
git clone https://github.com/semaes111/PROYECTO-SKILLS.git

# 2. Entrar y dar permisos
cd PROYECTO-SKILLS && chmod +x install-skills.sh

# 3. Instalar TODAS las skills
./install-skills.sh --all
```

**Eso es todo.** Las skills estaran disponibles en tu proxima sesion de Claude.

---

## Instalacion Selectiva

Si solo quieres instalar categorias especificas:

```bash
# Ver categorias disponibles
./install-skills.sh --list

# Instalar solo Backend + Frontend + Legal
./install-skills.sh --category 02 03 07

# Instalar en un proyecto especifico
./install-skills.sh --all --target /ruta/a/mi-proyecto

# Instalar en la carpeta del usuario (Windows con Git Bash)
./install-skills.sh --all --target /c/Users/TU_USUARIO
```

---

## Guia Completa Paso a Paso

### PASO 1: Requisitos Previos

Antes de empezar, necesitas tener instalado:

**Git** — Para clonar el repositorio
- Windows: Descargar de https://git-scm.com/download/win (incluye Git Bash)
- macOS: `brew install git` o `xcode-select --install`
- Linux: `sudo apt install git` (Ubuntu/Debian) o `sudo dnf install git` (Fedora)

**Claude Code o Cowork** — La herramienta donde se usaran las skills
- Claude Code: https://docs.claude.com/en/docs/claude-code
- Cowork: Disponible en la app de escritorio de Claude

Verificar que Git esta instalado:
```bash
git --version
# Debe mostrar algo como: git version 2.34.1
```

### PASO 2: Clonar el Repositorio

Abre una terminal (o Git Bash en Windows) y ejecuta:

```bash
# Clonar en el directorio actual
git clone https://github.com/semaes111/PROYECTO-SKILLS.git

# Entrar en la carpeta
cd PROYECTO-SKILLS
```

Esto crea una carpeta `PROYECTO-SKILLS/` con toda la estructura de skills.

**Donde clonar?** Puedes clonar donde quieras. El script instalara las skills en la ubicacion correcta de Claude. Recomendaciones:
- Windows: `C:\Users\TU_USUARIO\PROYECTO-SKILLS`
- macOS: `~/PROYECTO-SKILLS`
- Linux: `~/PROYECTO-SKILLS`

### PASO 3: Dar Permisos al Script

```bash
chmod +x install-skills.sh
```

En Windows con Git Bash esto no es estrictamente necesario, pero no hace dano.

### PASO 4: Ejecutar la Instalacion

**Opcion A — Instalar TODO (141 skills):**
```bash
./install-skills.sh --all
```

**Opcion B — Instalar en un proyecto especifico:**
```bash
./install-skills.sh --all --target /ruta/a/tu-proyecto
```

**Opcion C — Instalar solo ciertas categorias:**
```bash
# Primero ver que hay disponible
./install-skills.sh --list

# Luego instalar las que quieras (por numero)
./install-skills.sh --category 01 02 03 06 07
```

### PASO 5: Verificar la Instalacion

El script mostrara un resumen al final:
```
=============================================
  Instalacion completada
   Skills instaladas: 141
   Ubicacion: /ruta/.claude/skills
=============================================
```

Tambien puedes verificar manualmente:
```bash
# Contar skills instaladas
ls -d .claude/skills/*/ | wc -l

# Ver las primeras 10
ls .claude/skills/ | head -10
```

### PASO 6: Reiniciar Claude

Las skills se cargan al inicio de sesion. Necesitas:
- **Claude Code (terminal):** Cerrar y abrir una nueva sesion
- **Cowork (escritorio):** Cerrar la sesion actual y abrir una nueva
- **Cowork con carpeta seleccionada:** Seleccionar la carpeta donde instalaste las skills

---

## Metodo Alternativo: Instalacion Manual sin Script

Si no puedes ejecutar el script bash (por ejemplo en Windows sin Git Bash), puedes instalar las skills manualmente:

### Paso 1: Descargar el repositorio

Ir a https://github.com/semaes111/PROYECTO-SKILLS y hacer clic en **Code > Download ZIP**. Descomprimir en cualquier carpeta.

### Paso 2: Crear la estructura de carpetas

La estructura que Claude necesita es:
```
.claude/skills/nombre-skill/SKILL.md
```

Es decir, cada archivo del repo como `constructor-webs-3d-inmersivas-SKILL.md` debe quedar como:
```
.claude/skills/constructor-webs-3d-inmersivas/SKILL.md
```

### Paso 3: Copiar manualmente

Para cada archivo `*-SKILL.md` en las carpetas del repo:

1. Crear una carpeta con el nombre del archivo (sin el `-SKILL.md` al final)
2. Copiar el archivo dentro de esa carpeta
3. Renombrar el archivo a `SKILL.md`

**Ejemplo con PowerShell (Windows):**
```powershell
# Definir rutas
$REPO = "C:\Users\TU_USUARIO\PROYECTO-SKILLS"
$DEST = "C:\Users\TU_USUARIO\tu-proyecto\.claude\skills"

# Crear carpeta destino
New-Item -ItemType Directory -Force -Path $DEST

# Copiar cada skill
Get-ChildItem -Path $REPO -Recurse -Filter "*-SKILL.md" | ForEach-Object {
    $skillName = $_.BaseName -replace '-SKILL$', ''
    $skillDir = Join-Path $DEST $skillName
    New-Item -ItemType Directory -Force -Path $skillDir
    Copy-Item $_.FullName -Destination (Join-Path $skillDir "SKILL.md")
}

Write-Host "Skills instaladas en $DEST"
```

**Ejemplo con cmd (Windows):**
```cmd
@echo off
set REPO=C:\Users\TU_USUARIO\PROYECTO-SKILLS
set DEST=C:\Users\TU_USUARIO\tu-proyecto\.claude\skills

mkdir "%DEST%" 2>nul

for /R "%REPO%" %%f in (*-SKILL.md) do (
    set "fname=%%~nf"
    setlocal enabledelayedexpansion
    set "skillname=!fname:-SKILL=!"
    mkdir "%DEST%\!skillname!" 2>nul
    copy "%%f" "%DEST%\!skillname!\SKILL.md"
    endlocal
)

echo Skills instaladas en %DEST%
```

---

## Metodo Cowork: Instalacion Automatica desde Sesion

Si ya estas dentro de una sesion de Cowork y quieres que Claude instale las skills automaticamente, simplemente pega esto en el chat:

```
Clona el repositorio https://github.com/semaes111/PROYECTO-SKILLS.git
y ejecuta el script install-skills.sh --all para instalar todas las skills
en la carpeta .claude/skills/ de mi proyecto actual.
```

O si quieres hacerlo paso a paso desde Cowork:

```
Ejecuta estos comandos en orden:
1. git clone https://github.com/semaes111/PROYECTO-SKILLS.git /tmp/skills-repo
2. chmod +x /tmp/skills-repo/install-skills.sh
3. /tmp/skills-repo/install-skills.sh --all --target .
4. rm -rf /tmp/skills-repo
```

**Cowork ejecutara los comandos automaticamente** y las skills quedaran instaladas. Necesitaras reiniciar la sesion de Cowork para que se carguen.

---

## Categorias Disponibles

| # | Carpeta | Skills | Contenido |
|---|---------|--------|-----------|
| 01 | 3D-WEB | 7 | Three.js, WebGL, portfolios 3D, arte generativo, React Three Fiber |
| 02 | FRONTEND | 10 | React/Next.js, UI/UX, GSAP, temas, design systems, shadcn/ui |
| 03 | BACKEND | 11 | Node/Go/Python, Supabase, Better Auth, BD, MCP, PocketBase |
| 04 | MOBILE-EXPO | 5 | React Native, Expo Router, NativeWind, TestFlight |
| 05 | DEVOPS-INFRA | 7 | CI/CD EAS, deploy tiendas, n8n, Coolify Docker, dependencias |
| 06 | DOCUMENTOS | 10 | Word .docx, PDF, Excel .xlsx, PowerPoint .pptx, diagramas C4 |
| 07 | LEGAL-FISCAL | 9 | Demandas tributarias ES, due diligence M&A, GDPR, contratos, NDA |
| 08 | MARKETING-COPY | 8 | Copywriting, psicologia marketing, campanas, SEO, brand voice |
| 09 | UTILIDADES | 19 | CLI (Codex/Gemini), scraping, git, comunicacion, crear skills/plugins |
| 10 | PLUGINS-Y-REPOS | — | software-architect + knowledge-work-plugins (repos completos) |
| 11 | DATOS-ANALYTICS | 7 | SQL multi-dialecto, dashboards HTML, matplotlib, estadistica |
| 12 | INGENIERIA-SW | 6 | Code review, system design, testing strategy, incidents, tech debt |
| 13 | FINANZAS-CONTAB | 6 | Estados financieros, SOX 404, conciliacion, asientos, cierres |
| 14 | VENTAS-CRM | 15 | Sales outreach, Apollo leads, Common Room signals, battlecards |
| 15 | SOPORTE-CLIENTE | 5 | Triaje tickets P1-P4, respuestas empaticas, KB articles, escalados |
| 16 | PRODUCTO-PM | 6 | PRDs, roadmaps RICE/MoSCoW, metricas OKR, research synthesis |
| 17 | PRODUCTIVIDAD | 2 | Sistema memoria 2 niveles, gestion tareas TASKS.md |
| 18 | BIOINVESTIGACION | 5 | Single-cell RNA QC, scVI deep learning, Nextflow pipelines |
| 19 | BUSQUEDA-EMPRESARIAL | 3 | Busqueda multi-fuente, sintesis conocimiento, gestion conectores |
| | **TOTAL** | **141** | |

---

## Como Funciona Internamente

### Que es una Skill?

Una skill es un archivo `SKILL.md` que contiene instrucciones especializadas para Claude. Cuando Claude detecta una skill relevante a tu peticion, la lee automaticamente y aplica ese conocimiento experto.

### Donde las busca Claude?

Claude Code y Cowork buscan skills en esta ruta dentro de tu proyecto:

```
tu-proyecto/
└── .claude/
    └── skills/
        ├── nombre-de-skill/
        │   └── SKILL.md            <-- Archivo obligatorio (instrucciones)
        │   └── references/         <-- Opcional (plantillas, datos de soporte)
        │       ├── archivo1.md
        │       └── archivo2.json
        ├── otra-skill/
        │   └── SKILL.md
        └── ...
```

**Reglas criticas:**
- El archivo DEBE llamarse exactamente `SKILL.md` (mayusculas, extension .md)
- Cada skill DEBE estar en su propia subcarpeta
- El nombre de la subcarpeta es el identificador de la skill
- La carpeta `.claude/` es oculta (empieza con punto)

### Que hace el script install-skills.sh?

El script realiza esta conversion automatica:

```
ANTES (en el repo):                          DESPUES (en .claude/skills/):
─────────────────────                        ──────────────────────────────
01-SKILLS-3D-WEB/                            .claude/skills/
  constructor-webs-3d-inmersivas-SKILL.md      constructor-webs-3d-inmersivas/
  componentes-threejs-react-fiber-SKILL.md       └── SKILL.md
03-SKILLS-BACKEND/                             componentes-threejs-react-fiber/
  arquitectura-supabase-postgresql-rls-SKILL.md    └── SKILL.md
                                               arquitectura-supabase-postgresql-rls/
                                                   └── SKILL.md
```

Paso a paso:
1. Recorre todas las carpetas tematicas (01 a 19)
2. Por cada archivo `*-SKILL.md`, extrae el nombre funcional (todo antes de `-SKILL.md`)
3. Crea una subcarpeta con ese nombre en `.claude/skills/`
4. Copia el archivo dentro como `SKILL.md`
5. Si hay carpetas `references/` asociadas, las copia tambien
6. Copia el indice maestro a `.claude/`

### Que hace Claude con las Skills?

Cuando inicias una sesion de Claude Code o Cowork:
1. Claude escanea `.claude/skills/` y registra todas las skills disponibles
2. Cada skill tiene un campo `description` dentro del SKILL.md
3. Cuando tu peticion coincide con la descripcion de una skill, Claude la activa
4. Claude lee el SKILL.md completo y sigue sus instrucciones especializadas

**Ejemplo:** Si dices "crea una presentacion PowerPoint", Claude detecta la skill `crear-editar-presentaciones-pptx`, lee su SKILL.md, y aplica las mejores practicas de creacion de .pptx que contiene.

---

## Estructura del Repositorio

```
PROYECTO-SKILLS/
├── README.md                              <-- Este archivo
├── INDICE-MAESTRO-SKILLS.md               <-- Tabla completa de 141 skills
├── install-skills.sh                      <-- Script de instalacion automatica
│
├── 01-SKILLS-3D-WEB/                      <-- 7 skills
│   ├── generador-portfolios-3d-SKILL.md
│   ├── constructor-webs-3d-inmersivas-SKILL.md
│   ├── sistema-diseno-web-3d-SKILL.md
│   ├── experiencias-3d-threejs-webgl-SKILL.md
│   ├── componentes-threejs-react-fiber-SKILL.md
│   ├── arte-visual-canvas-png-pdf-SKILL.md
│   └── arte-generativo-algoritmo-p5js-SKILL.md
│
├── 02-SKILLS-FRONTEND/                    <-- 10 skills
├── 03-SKILLS-BACKEND/                     <-- 11 skills
├── 04-SKILLS-MOBILE-EXPO/                 <-- 5 skills
├── 05-SKILLS-DEVOPS-INFRA/                <-- 7 skills
├── 06-SKILLS-DOCUMENTOS/                  <-- 10 skills
├── 07-SKILLS-LEGAL-FISCAL/                <-- 9 skills + references/
├── 08-SKILLS-MARKETING-COPY/              <-- 8 skills
├── 09-SKILLS-UTILIDADES/                  <-- 19 skills
│
├── 10-PLUGINS-Y-REPOS/                    <-- Repos completos
│   ├── software-architect/                <-- 9 archivos (Next.js, Supabase, etc.)
│   └── knowledge-work-plugins/            <-- 17 categorias de marketplace
│       ├── bio-research/
│       ├── customer-support/
│       ├── data/
│       ├── engineering/
│       ├── finance/
│       ├── legal/
│       ├── marketing/
│       ├── product-management/
│       ├── productivity/
│       ├── sales/
│       └── ...
│
├── 11-SKILLS-DATOS-ANALYTICS/             <-- 7 skills
├── 12-SKILLS-INGENIERIA-SOFTWARE/         <-- 6 skills
├── 13-SKILLS-FINANZAS-CONTABILIDAD/       <-- 6 skills
├── 14-SKILLS-VENTAS-CRM/                  <-- 15 skills
├── 15-SKILLS-SOPORTE-CLIENTE/             <-- 5 skills
├── 16-SKILLS-PRODUCTO-PM/                 <-- 6 skills
├── 17-SKILLS-PRODUCTIVIDAD/               <-- 2 skills
├── 18-SKILLS-BIOINVESTIGACION/            <-- 5 skills
└── 19-SKILLS-BUSQUEDA-EMPRESARIAL/        <-- 3 skills
```

---

## Verificacion Post-Instalacion

### Verificar que las skills se instalaron correctamente

```bash
# Contar total de skills instaladas
echo "Skills instaladas:" && ls -d .claude/skills/*/ 2>/dev/null | wc -l

# Verificar que cada carpeta tiene su SKILL.md
echo "Skills con SKILL.md:" && find .claude/skills -name "SKILL.md" | wc -l

# Listar todas las skills instaladas
ls .claude/skills/

# Verificar una skill especifica
cat .claude/skills/constructor-webs-3d-inmersivas/SKILL.md | head -5
```

### Verificar que Claude las detecta

En una nueva sesion de Claude Code, ejecuta:
```
¿Que skills tienes disponibles?
```

Claude deberia listar las 141 skills organizadas por categoria.

### Verificar en Cowork

En una nueva sesion de Cowork:
1. Selecciona la carpeta donde instalaste las skills
2. Pregunta: "Lista todas tus skills disponibles"
3. Claude mostrara el catalogo completo

---

## Actualizacion

Cuando se anadan nuevas skills al repositorio:

```bash
# Ir a la carpeta del repo clonado
cd PROYECTO-SKILLS

# Descargar cambios
git pull

# Reinstalar (sobreescribe las existentes, anade las nuevas)
./install-skills.sh --all
```

Para actualizar un proyecto especifico:
```bash
cd PROYECTO-SKILLS
git pull
./install-skills.sh --all --target /ruta/a/tu-proyecto
```

---

## Desinstalacion

### Desinstalar con el script
```bash
cd PROYECTO-SKILLS
./install-skills.sh --uninstall
```

### Desinstalar manualmente
```bash
# Eliminar todas las skills
rm -rf .claude/skills/

# O eliminar skills especificas
rm -rf .claude/skills/constructor-webs-3d-inmersivas/
rm -rf .claude/skills/arquitectura-supabase-postgresql-rls/
```

### Desinstalar en Windows (PowerShell)
```powershell
Remove-Item -Recurse -Force ".claude\skills"
```

---

## Troubleshooting

### "Permission denied" al ejecutar el script

```bash
chmod +x install-skills.sh
# o ejecutar con bash directamente:
bash install-skills.sh --all
```

### Las skills no aparecen en Claude

1. **Reiniciaste la sesion?** Las skills se cargan al inicio. Cierra y abre una nueva sesion.
2. **Seleccionaste la carpeta correcta en Cowork?** Cowork solo ve skills de la carpeta seleccionada.
3. **La estructura es correcta?** Verifica que exista `.claude/skills/nombre/SKILL.md`.

```bash
# Diagnostico rapido
echo "Carpeta .claude existe:" && ls -la .claude/ 2>/dev/null
echo "Carpeta skills existe:" && ls -la .claude/skills/ 2>/dev/null | head -5
echo "Primer SKILL.md:" && find .claude/skills -name "SKILL.md" -print -quit
```

### "command not found: git"

Instalar Git:
- Windows: https://git-scm.com/download/win
- macOS: `xcode-select --install`
- Linux: `sudo apt install git`

### El script no encuentra las skills del repo

Asegurate de ejecutar el script DESDE DENTRO de la carpeta del repo:

```bash
cd PROYECTO-SKILLS    # <-- Debes estar aqui
./install-skills.sh --all
```

### Windows: el script no funciona en CMD

El script es bash. En Windows usa una de estas opciones:
- **Git Bash** (viene con Git for Windows): clic derecho > "Git Bash Here"
- **WSL** (Windows Subsystem for Linux): `wsl` y luego los comandos normales
- **PowerShell**: Usa el metodo alternativo de PowerShell descrito arriba

### Quiero instalar en multiples proyectos

```bash
# Instalar en proyecto A
./install-skills.sh --all --target /ruta/proyecto-a

# Instalar en proyecto B
./install-skills.sh --all --target /ruta/proyecto-b

# Instalar solo categorias especificas en proyecto C
./install-skills.sh --category 03 07 11 --target /ruta/proyecto-c
```

---

## Requisitos

| Requisito | Version Minima | Donde Obtenerlo |
|-----------|---------------|-----------------|
| Git | 2.0+ | https://git-scm.com |
| Bash | 4.0+ | Incluido en Linux/macOS/Git Bash |
| Claude Code | Cualquiera | https://docs.claude.com |
| Cowork | Cualquiera | App de escritorio Claude |

**Sistemas operativos soportados:**
- Linux (Ubuntu, Debian, Fedora, Arch, etc.)
- macOS (Intel y Apple Silicon)
- Windows con Git Bash, WSL, o usando el metodo PowerShell manual

---

## Licencia y Creditos

- **Repositorio:** https://github.com/semaes111/PROYECTO-SKILLS
- **Mantenido por:** semaes111
- **Skills propias:** 73 skills creadas y curadas manualmente
- **Skills de plugins:** 68 skills del marketplace knowledge-work-plugins de Anthropic
- **Ultima actualizacion:** 8 de abril de 2026

---

*Para ver el detalle completo de cada skill (nombre, funcion, origen), consulta [INDICE-MAESTRO-SKILLS.md](./INDICE-MAESTRO-SKILLS.md)*
