# GUÍA DE INSTALACIÓN COMPLETA — PROYECTO SKILLS para Claude Desktop

> Última actualización: 2026-04-09
> Repositorio: `https://github.com/semaes111/PROYECTO-SKILLS`
> Total de assets: **278 SKILL.md** + **71 commands** + **9 commands software-architect** + scripts

---

## Índice

1. [Inventario del repositorio](#1-inventario-del-repositorio)
2. [Requisitos previos](#2-requisitos-previos)
3. [Método 1: Instalación automática (Linux/macOS/WSL)](#3-método-1-instalación-automática)
4. [Método 2: Instalación manual con PowerShell (Windows nativo)](#4-método-2-instalación-manual-con-powershell)
5. [Método 3: Instalación desde Cowork](#5-método-3-instalación-desde-cowork)
6. [Detalle por tipo de asset](#6-detalle-por-tipo-de-asset)
7. [Verificación post-instalación](#7-verificación-post-instalación)
8. [Estructura de directorios resultante](#8-estructura-de-directorios-resultante)
9. [Troubleshooting](#9-troubleshooting)
10. [Mantenimiento y actualización](#10-mantenimiento-y-actualización)

---

## 1. Inventario del repositorio

### 1.1 Categorías y conteo

| Categoría | Directorio | Flat Skills | Dir-Skills | Total SKILL.md |
|-----------|-----------|-------------|------------|----------------|
| 01 | `01-SKILLS-3D-WEB` | 19 | 0 | 19 |
| 02 | `02-SKILLS-FRONTEND` | 10 | 0 | 10 |
| 03 | `03-SKILLS-BACKEND` | 11 | 0 | 11 |
| 04 | `04-SKILLS-MOBILE-EXPO` | 5 | 0 | 5 |
| 05 | `05-SKILLS-DEVOPS-INFRA` | 13 | 4 | 17 |
| 06 | `06-SKILLS-DOCUMENTOS` | 10 | 0 | 10 |
| 07 | `07-SKILLS-LEGAL-FISCAL` | 10 | 0 | 10 |
| 08 | `08-SKILLS-MARKETING-COPY` | 8 | 0 | 8 |
| 09 | `09-SKILLS-UTILIDADES` | 42 | 5 | 47 |
| 10 | `10-PLUGINS-Y-REPOS` | 0 | 86 (KWP) + 9 (SA) | 86+9 |
| 11 | `11-SKILLS-DATOS-ANALYTICS` | 7 | 0 | 7 |
| 12 | `12-SKILLS-INGENIERIA-SOFTWARE` | 6 | 0 | 6 |
| 13 | `13-SKILLS-FINANZAS-CONTABILIDAD` | 6 | 0 | 6 |
| 14 | `14-SKILLS-VENTAS-CRM` | 15 | 0 | 15 |
| 15 | `15-SKILLS-SOPORTE-CLIENTE` | 5 | 0 | 5 |
| 16 | `16-SKILLS-PRODUCTO-PM` | 6 | 0 | 6 |
| 17 | `17-SKILLS-PRODUCTIVIDAD` | 2 | 0 | 2 |
| 18 | `18-SKILLS-BIOINVESTIGACION` | 5 | 0 | 5 |
| 19 | `19-SKILLS-BUSQUEDA-EMPRESARIAL` | 3 | 0 | 3 |
| **TOTAL** | | **183** | **95** | **278** |

### 1.2 Tipos de assets

El repo contiene 4 tipos de assets distintos. Cada uno tiene su propio mecanismo de instalación:

**TIPO A — Flat Skills (183 archivos)**
Archivos individuales con formato `nombre-SKILL.md` dentro de las carpetas de categoría.
Se instalan como: `~/.claude/skills/nombre/SKILL.md`

**TIPO B — Dir-Skills (9 directorios, cat 01-09)**
Subdirectorios que contienen `SKILL.md` + `references/` y/o `scripts/` y/o `standalone/`.
Se copian como directorio completo: `~/.claude/skills/nombre/` (recursivo)

**TIPO C — Knowledge-Work-Plugins (86 skills + 71 commands)**
Dentro de `10-PLUGINS-Y-REPOS/knowledge-work-plugins/`. Estructura: `plugin/skill/SKILL.md` con references/, scripts/, commands/.
Se instalan como: `~/.claude/skills/kwp-plugin-skill/SKILL.md` (recursivo)

**TIPO D — Software-Architect Commands (9 archivos)**
Dentro de `10-PLUGINS-Y-REPOS/software-architect/`. Son archivos `.md` de comandos.
Se instalan en dos ubicaciones: `~/.claude/commands/` y `~/.claude/skills/software-architect/`

### 1.3 Origen de las skills

Las skills provienen de 3 fuentes:

- **Propias (cat 01-09, 11-19)**: Creadas por el usuario, adaptadas al stack NextHorizont (Next.js + Supabase + TypeScript)
- **Knowledge-Work-Plugins (cat 10)**: Exportadas de los plugins oficiales de Cowork (data, engineering, finance, legal, marketing, sales, etc.) + common-room y apollo
- **ECC (prefijo `ecc-`)**: 26 skills de alto valor extraídas de `affaan-m/everything-claude-code` (146K stars) — meta-skills, patrones agénticos, seguridad

---

## 2. Requisitos previos

### Para cualquier método:

```
Git instalado y configurado
Acceso al repo: git clone https://github.com/semaes111/PROYECTO-SKILLS.git
```

### Rutas de destino según sistema:

| Sistema | Ruta de skills | Ruta de commands |
|---------|---------------|-----------------|
| **Windows** | `C:\Users\<usuario>\.claude\skills\` | `C:\Users\<usuario>\.claude\commands\` |
| **macOS** | `~/.claude/skills/` | `~/.claude/commands/` |
| **Linux** | `~/.claude/skills/` | `~/.claude/commands/` |

> **IMPORTANTE (Windows):** Desde una sesión de Cowork, el directorio `~/.claude/skills/` es un mount FUSE de solo lectura. NO se puede escribir con bash/python del sandbox. Hay que usar PowerShell nativo de Windows (Método 2) o el MCP `mcp__Windows-MCP__PowerShell` (Método 3).

---

## 3. Método 1: Instalación automática (Linux/macOS/WSL)

El script `install-skills.sh` instala todo automáticamente.

### 3.1 Instalación completa (todo)

```bash
git clone https://github.com/semaes111/PROYECTO-SKILLS.git
cd PROYECTO-SKILLS
chmod +x install-skills.sh
./install-skills.sh --all
```

Esto instala las categorías 01-09 y 11-19 (flat + dir-skills). Para instalar también los plugins (cat 10), ejecutar adicionalmente el script de plugins:

### 3.2 Instalación por categoría

```bash
./install-skills.sh --category 01        # Solo 3D/Web
./install-skills.sh --category 05,09     # Solo DevOps + Utilidades
```

### 3.3 Instalación manual de Tipo C y D (cat 10)

El script `install-skills.sh` cubre parcialmente los plugins. Para instalación completa de cat 10:

```bash
TARGET="$HOME/.claude/skills"

# --- KWP Skills (Tipo C) ---
KWP_DIR="10-PLUGINS-Y-REPOS/knowledge-work-plugins"
for plugin_dir in "$KWP_DIR"/*/; do
  plugin_name=$(basename "$plugin_dir")

  # Instalar sub-skills
  for skill_dir in "$plugin_dir"*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      skill_name=$(basename "$skill_dir")
      dest="$TARGET/kwp-${plugin_name}-${skill_name}"
      cp -r "$skill_dir" "$dest"
      echo "KWP: $dest"
    fi
  done

  # Instalar commands
  if [ -d "$plugin_dir/commands" ]; then
    dest="$TARGET/kwp-${plugin_name}-commands"
    cp -r "$plugin_dir/commands" "$dest"
    echo "CMD: $dest"
  fi
done

# --- Software-Architect (Tipo D) ---
SA_DIR="10-PLUGINS-Y-REPOS/software-architect"
mkdir -p "$HOME/.claude/commands"
mkdir -p "$TARGET/software-architect"

for f in "$SA_DIR"/*.md; do
  cp "$f" "$HOME/.claude/commands/"
  cp "$f" "$TARGET/software-architect/"
done
# Crear SKILL.md para detección
cp "$SA_DIR/review-architecture.md" "$TARGET/software-architect/SKILL.md"
echo "SA: 9 commands instalados"
```

---

## 4. Método 2: Instalación manual con PowerShell (Windows nativo)

Para Windows sin WSL. Abrir PowerShell como usuario normal.

### 4.1 Clonar y preparar

```powershell
git clone https://github.com/semaes111/PROYECTO-SKILLS.git D:\PROYECTO-SKILLS-REPO
$repo = "D:\PROYECTO-SKILLS-REPO"
$target = "C:\Users\$env:USERNAME\.claude\skills"
$commands = "C:\Users\$env:USERNAME\.claude\commands"
New-Item -ItemType Directory -Path $target -Force | Out-Null
New-Item -ItemType Directory -Path $commands -Force | Out-Null
```

### 4.2 Instalar Tipo A — Flat Skills (cat 01-09, 11-19)

```powershell
$cats = @("01","02","03","04","05","06","07","08","09","11","12","13","14","15","16","17","18","19")
$installed = 0

foreach ($cat in $cats) {
  $catDir = Get-ChildItem $repo -Directory | Where-Object { $_.Name -like "$cat-*" }
  if ($catDir) {
    Get-ChildItem $catDir.FullName -Filter "*-SKILL.md" | ForEach-Object {
      $skillName = $_.Name -replace '-SKILL\.md', ''
      $destDir = Join-Path $target $skillName
      New-Item -ItemType Directory -Path $destDir -Force | Out-Null
      Copy-Item $_.FullName (Join-Path $destDir "SKILL.md") -Force
      $installed++
    }
  }
}
Write-Host "Flat skills instaladas: $installed"
```

### 4.3 Instalar Tipo B — Dir-Skills (cat 01-09)

```powershell
$dirSkills = @(
  "05-SKILLS-DEVOPS-INFRA\mcp-n8n-workflow-builder",
  "05-SKILLS-DEVOPS-INFRA\memoria-persistente-7-capas",
  "05-SKILLS-DEVOPS-INFRA\orquestacion-docker-agente-autonomo",
  "05-SKILLS-DEVOPS-INFRA\ecc-security-review-auditoria-seguridad",
  "09-SKILLS-UTILIDADES\memoria-sesion-persistente",
  "09-SKILLS-UTILIDADES\ecc-skill-comply-compliance-medicion",
  "09-SKILLS-UTILIDADES\ecc-rules-distill-extraer-reglas",
  "09-SKILLS-UTILIDADES\ecc-skill-stocktake-inventario",
  "09-SKILLS-UTILIDADES\ecc-strategic-compact-compactacion"
)

foreach ($dir in $dirSkills) {
  $srcPath = Join-Path $repo $dir
  $skillName = Split-Path $srcPath -Leaf
  $destPath = Join-Path $target $skillName
  if (Test-Path $srcPath) {
    if (Test-Path $destPath) { Remove-Item $destPath -Recurse -Force }
    Copy-Item $srcPath $destPath -Recurse -Force
    Write-Host "DIR: $skillName"
  }
}
```

### 4.4 Instalar Tipo C — Knowledge-Work-Plugins

```powershell
$kwpDir = Join-Path $repo "10-PLUGINS-Y-REPOS\knowledge-work-plugins"

Get-ChildItem $kwpDir -Directory | ForEach-Object {
  $pluginName = $_.Name
  $pluginDir = $_.FullName

  # Sub-skills
  Get-ChildItem $pluginDir -Directory | Where-Object { $_.Name -ne "commands" } | ForEach-Object {
    if (Test-Path (Join-Path $_.FullName "SKILL.md")) {
      $destName = "kwp-$pluginName-$($_.Name)"
      $destDir = Join-Path $target $destName
      if (Test-Path $destDir) { Remove-Item $destDir -Recurse -Force }
      Copy-Item $_.FullName $destDir -Recurse -Force
    }
  }

  # Commands
  $cmds = Join-Path $pluginDir "commands"
  if (Test-Path $cmds) {
    $cmdDest = Join-Path $target "kwp-$pluginName-commands"
    if (Test-Path $cmdDest) { Remove-Item $cmdDest -Recurse -Force }
    Copy-Item $cmds $cmdDest -Recurse -Force
  }
}
Write-Host "KWP plugins instalados"
```

### 4.5 Instalar Tipo D — Software-Architect Commands

```powershell
$saDir = Join-Path $repo "10-PLUGINS-Y-REPOS\software-architect"
$saSkillDir = Join-Path $target "software-architect"
New-Item -ItemType Directory -Path $saSkillDir -Force | Out-Null

Get-ChildItem $saDir -Filter "*.md" | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $commands $_.Name) -Force
  Copy-Item $_.FullName (Join-Path $saSkillDir $_.Name) -Force
}
Copy-Item (Join-Path $saDir "review-architecture.md") (Join-Path $saSkillDir "SKILL.md") -Force
Write-Host "Software-architect: 9 commands instalados"
```

### 4.6 (Opcional) Instalar con nombres directos para plugins no cargados por Cowork

Cowork no carga automáticamente 3 plugins (design, human-resources, operations). Para acceso directo como skills:

```powershell
$extraPlugins = @("design", "human-resources", "operations", "common-room", "apollo")

foreach ($plugin in $extraPlugins) {
  $pluginDir = Join-Path $kwpDir $plugin
  if (Test-Path $pluginDir) {
    Get-ChildItem $pluginDir -Directory | Where-Object { $_.Name -ne "commands" } | ForEach-Object {
      if (Test-Path (Join-Path $_.FullName "SKILL.md")) {
        $dest = Join-Path $target "$plugin-$($_.Name)"
        if (-not (Test-Path $dest)) {
          Copy-Item $_.FullName $dest -Recurse -Force
        }
      }
    }
    $cmds = Join-Path $pluginDir "commands"
    if ((Test-Path $cmds) -and -not (Test-Path (Join-Path $target "$plugin-commands"))) {
      Copy-Item $cmds (Join-Path $target "$plugin-commands") -Recurse -Force
    }
  }
}
Write-Host "Plugins directos instalados"
```

---

## 5. Método 3: Instalación desde Cowork

Dentro de una sesión de Cowork en Claude Desktop, la ruta `.claude/skills/` es **FUSE read-only** desde el sandbox bash. Hay que usar el MCP de Windows.

### 5.1 Preparar

```
1. Abrir sesión Cowork
2. Seleccionar una carpeta de trabajo (mount)
3. Clonar el repo en Windows:
```

Decirle a Claude:
```
Clona el repo https://github.com/semaes111/PROYECTO-SKILLS.git en D:\PROYECTO-SKILLS-REPO usando PowerShell
```

### 5.2 Instalar

Decirle a Claude:
```
Instala todas las skills del repo D:\PROYECTO-SKILLS-REPO en C:\Users\Usuario\.claude\skills\ usando PowerShell MCP. Incluye: flat skills (cat 01-09, 11-19), dir-skills con references/, KWP plugins (cat 10), y software-architect commands.
```

Claude usará `mcp__Windows-MCP__PowerShell` para ejecutar los mismos comandos del Método 2, divididos en batches para evitar timeouts.

### 5.3 Notas sobre Cowork

- El sandbox bash **NO puede escribir** en `.claude/skills/` (FUSE mount read-only)
- Usar siempre `mcp__Windows-MCP__PowerShell` para operaciones en el filesystem de Windows
- Timeout recomendado por batch: 15-30 segundos
- Dividir en batches de ~20 skills para evitar timeouts del MCP

---

## 6. Detalle por tipo de asset

### 6.1 Flat Skills — Conversión `nombre-SKILL.md` → `nombre/SKILL.md`

```
REPO:     05-SKILLS-DEVOPS-INFRA/docker-patterns-SKILL.md
DESTINO:  ~/.claude/skills/docker-patterns/SKILL.md
```

El nombre de la carpeta se extrae quitando el sufijo `-SKILL.md`.

### 6.2 Dir-Skills — Copia recursiva completa

```
REPO:     05-SKILLS-DEVOPS-INFRA/orquestacion-docker-agente-autonomo/
          ├── SKILL.md
          ├── references/
          │   ├── arquitectura-servicios.md
          │   └── ...
          └── standalone/
              └── ...

DESTINO:  ~/.claude/skills/orquestacion-docker-agente-autonomo/
          ├── SKILL.md
          ├── references/
          │   ├── arquitectura-servicios.md
          │   └── ...
          └── standalone/
              └── ...
```

Se copia el directorio completo preservando toda la estructura interna.

### 6.3 KWP Plugins — Prefijo `kwp-` para evitar colisiones

```
REPO:     10-PLUGINS-Y-REPOS/knowledge-work-plugins/data/data-exploration/
          ├── SKILL.md
          └── references/
              └── ...

DESTINO:  ~/.claude/skills/kwp-data-data-exploration/
          ├── SKILL.md
          └── references/

REPO:     10-PLUGINS-Y-REPOS/knowledge-work-plugins/data/commands/
          ├── analyze.md
          └── ...

DESTINO:  ~/.claude/skills/kwp-data-commands/
          ├── analyze.md
          └── ...
```

### 6.4 Software-Architect Commands — Doble ubicación

```
REPO:     10-PLUGINS-Y-REPOS/software-architect/generate-api-route.md

DESTINO 1: ~/.claude/commands/generate-api-route.md       (para /slash commands)
DESTINO 2: ~/.claude/skills/software-architect/generate-api-route.md  (para skill detection)
```

---

## 7. Verificación post-instalación

### PowerShell (Windows)

```powershell
$target = "C:\Users\$env:USERNAME\.claude\skills"

# Contar skills con SKILL.md
$count = (Get-ChildItem $target -Directory | Where-Object {
  Test-Path (Join-Path $_.FullName "SKILL.md")
} | Measure-Object).Count

Write-Host "Skills con SKILL.md: $count"

# Desglose por tipo
$regular = (Get-ChildItem $target -Directory | Where-Object {
  $_.Name -notlike "kwp-*" -and (Test-Path (Join-Path $_.FullName "SKILL.md"))
} | Measure-Object).Count

$kwp = (Get-ChildItem $target -Directory | Where-Object {
  $_.Name -like "kwp-*" -and (Test-Path (Join-Path $_.FullName "SKILL.md"))
} | Measure-Object).Count

Write-Host "Regular: $regular | KWP: $kwp"
```

### Bash (Linux/macOS)

```bash
TARGET="$HOME/.claude/skills"

# Contar skills
find "$TARGET" -maxdepth 2 -name "SKILL.md" | wc -l

# Listar todas
find "$TARGET" -maxdepth 2 -name "SKILL.md" | sed "s|$TARGET/||; s|/SKILL.md||" | sort
```

### Valores esperados tras instalación completa

| Métrica | Valor esperado |
|---------|---------------|
| Skills con SKILL.md | **~310** (278 del repo + ~13 pre-existentes + ~19 extras directos) |
| Skills regulares (sin kwp-) | ~180 |
| Skills KWP (kwp-*) | ~86 |
| Skills directas (design/HR/ops/etc.) | ~30 |
| Commands en .claude/commands/ | variable (depende de lo que ya tengas) |

---

## 8. Estructura de directorios resultante

```
~/.claude/
├── skills/
│   ├── arte-generativo-algoritmo-p5js/          # Cat 01 - 3D/Web
│   │   └── SKILL.md
│   ├── desarrollo-frontend-react-next/           # Cat 02 - Frontend
│   │   └── SKILL.md
│   ├── arquitectura-supabase-postgresql-rls/     # Cat 03 - Backend
│   │   └── SKILL.md
│   ├── orquestacion-docker-agente-autonomo/      # Cat 05 - Dir-skill
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── arquitectura-servicios.md
│   │       └── ...
│   ├── ecc-verification-loop-quality-gates/      # ECC meta-skill
│   │   └── SKILL.md
│   ├── ecc-skill-comply-compliance-medicion/     # ECC dir-skill
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   │   ├── classifier.py
│   │   │   └── ...
│   │   └── prompts/
│   │       └── ...
│   ├── kwp-data-data-exploration/                # KWP plugin skill
│   │   └── SKILL.md
│   ├── kwp-data-commands/                        # KWP plugin commands
│   │   ├── analyze.md
│   │   └── ...
│   ├── design-accessibility-review/              # Plugin directo
│   │   └── SKILL.md
│   ├── software-architect/                       # SA commands como skill
│   │   ├── SKILL.md
│   │   ├── generate-api-route.md
│   │   └── ...
│   └── ...
├── commands/
│   ├── generate-api-route.md                     # SA commands
│   ├── scaffold-feature.md
│   └── ...
└── plugins/
    └── marketplaces/                             # Plugins de Cowork (auto-gestionados)
```

---

## 9. Troubleshooting

### "Permission denied" al escribir en `.claude/skills/` desde Cowork bash

**Causa:** El directorio `.claude/skills/` es un mount FUSE read-only dentro del sandbox de Cowork.
**Solución:** Usar `mcp__Windows-MCP__PowerShell` para escribir directamente en `C:\Users\Usuario\.claude\skills\`.

### Las skills no aparecen en Cowork tras instalar

**Causa:** Cowork carga las skills al inicio de sesión.
**Solución:** Cerrar y abrir una nueva sesión de Cowork. Las skills se detectan al arranque.

### Git pull tarda demasiado en Windows PowerShell

**Causa:** El repo tiene ~500 archivos y el MCP tiene timeout de 30-60s.
**Solución:** Hacer `git clone` fresco en lugar de pull, o ejecutar git desde un terminal PowerShell normal (no desde el MCP).

### Las skills KWP duplican las que ya carga Cowork como plugins

**Esto es intencional.** Las skills KWP se instalan como backup local. Cowork carga sus propios plugins desde la caché, pero si algún día un plugin no está disponible, la versión local en `kwp-*` sigue accesible.

### Los 3 plugins (design, human-resources, operations) no aparecen en Cowork

**Causa:** Estos 3 plugins NO están en la caché de plugins de Cowork.
**Solución:** Están instalados como `design-*`, `human-resources-*`, `operations-*` en `.claude/skills/`. Para usarlos, pide a Claude que lea el SKILL.md correspondiente. También puedes consultarlos a través de la CLAUDE-MEMORY.md donde están documentados en la sección "Superpoderes".

---

## 10. Mantenimiento y actualización

### Actualizar a última versión

```bash
cd PROYECTO-SKILLS
git pull origin main
./install-skills.sh --all   # Re-instala todo (sobrescribe existentes)
```

### Añadir una nueva skill al repo

**Flat skill:**
```bash
# Crear el archivo en la categoría correcta
echo "# Mi nueva skill..." > 09-SKILLS-UTILIDADES/mi-nueva-skill-SKILL.md
git add . && git commit -m "feat: add mi-nueva-skill"
git push origin main
```

**Dir-skill (con references):**
```bash
mkdir -p 09-SKILLS-UTILIDADES/mi-skill-compleja/references
echo "# Skill..." > 09-SKILLS-UTILIDADES/mi-skill-compleja/SKILL.md
echo "# Ref..." > 09-SKILLS-UTILIDADES/mi-skill-compleja/references/guia.md
git add . && git commit -m "feat: add mi-skill-compleja with references"
git push origin main
```

### Respaldar plugins nuevos de Cowork al repo

Si Cowork añade nuevos plugins que no están en el repo, exportarlos desde la caché:

```bash
# Desde el sandbox de Cowork
CACHE="/sessions/*/mnt/.local-plugins/cache/knowledge-work-plugins"
REPO="/sessions/*/PROYECTO-SKILLS/10-PLUGINS-Y-REPOS/knowledge-work-plugins"

cp -r $CACHE/nuevo-plugin $REPO/
git add . && git commit -m "feat: export nuevo-plugin from Cowork cache"
git push origin main
```

---

## Apéndice: Script de instalación completa one-liner (PowerShell)

Para los impacientes, este script hace TODO de una vez en Windows:

```powershell
# === ONE-LINER: Instalación completa ===
$repo = "D:\PROYECTO-SKILLS-REPO"
$target = "C:\Users\$env:USERNAME\.claude\skills"
$commands = "C:\Users\$env:USERNAME\.claude\commands"

# 1. Clonar (si no existe)
if (-not (Test-Path $repo)) { git clone https://github.com/semaes111/PROYECTO-SKILLS.git $repo }
New-Item -ItemType Directory -Path $target -Force | Out-Null
New-Item -ItemType Directory -Path $commands -Force | Out-Null

# 2. Flat skills (cat 01-09, 11-19)
$cats = @("01","02","03","04","05","06","07","08","09","11","12","13","14","15","16","17","18","19")
foreach ($cat in $cats) {
  $catDir = Get-ChildItem $repo -Directory | Where-Object { $_.Name -like "$cat-*" } | Select-Object -First 1
  if ($catDir) {
    Get-ChildItem $catDir.FullName -Filter "*-SKILL.md" | ForEach-Object {
      $name = $_.Name -replace '-SKILL\.md', ''
      $dest = Join-Path $target $name
      New-Item -ItemType Directory -Path $dest -Force | Out-Null
      Copy-Item $_.FullName (Join-Path $dest "SKILL.md") -Force
    }
  }
}

# 3. Dir-skills (copia recursiva)
Get-ChildItem $repo -Recurse -Directory -Depth 2 | Where-Object {
  (Test-Path (Join-Path $_.FullName "SKILL.md")) -and
  ($_.Parent.Name -like "0*-SKILLS-*") -and
  ($_.Name -notlike "*-SKILL*")
} | ForEach-Object {
  $dest = Join-Path $target $_.Name
  if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
  Copy-Item $_.FullName $dest -Recurse -Force
}

# 4. KWP plugins
$kwp = Join-Path $repo "10-PLUGINS-Y-REPOS\knowledge-work-plugins"
Get-ChildItem $kwp -Directory | ForEach-Object {
  $pn = $_.Name
  Get-ChildItem $_.FullName -Directory | ForEach-Object {
    if (Test-Path (Join-Path $_.FullName "SKILL.md")) {
      $dest = Join-Path $target "kwp-$pn-$($_.Name)"
      if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
      Copy-Item $_.FullName $dest -Recurse -Force
    }
  }
  $cmds = Join-Path $_.FullName "commands"
  if (Test-Path $cmds) {
    $dest = Join-Path $target "kwp-$pn-commands"
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Copy-Item $cmds $dest -Recurse -Force
  }
}

# 5. Software-architect
$sa = Join-Path $repo "10-PLUGINS-Y-REPOS\software-architect"
$saDest = Join-Path $target "software-architect"
New-Item -ItemType Directory -Path $saDest -Force | Out-Null
Get-ChildItem $sa -Filter "*.md" | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $commands $_.Name) -Force
  Copy-Item $_.FullName (Join-Path $saDest $_.Name) -Force
}
Copy-Item (Join-Path $sa "review-architecture.md") (Join-Path $saDest "SKILL.md") -Force

# 6. Plugins directos (design, HR, operations, common-room, apollo)
foreach ($p in @("design","human-resources","operations","common-room","apollo")) {
  $pd = Join-Path $kwp $p
  if (Test-Path $pd) {
    Get-ChildItem $pd -Directory | Where-Object { $_.Name -ne "commands" } | ForEach-Object {
      if (Test-Path (Join-Path $_.FullName "SKILL.md")) {
        $dest = Join-Path $target "$p-$($_.Name)"
        if (-not (Test-Path $dest)) { Copy-Item $_.FullName $dest -Recurse -Force }
      }
    }
    $cd = Join-Path $pd "commands"
    if ((Test-Path $cd) -and -not (Test-Path (Join-Path $target "$p-commands"))) {
      Copy-Item $cd (Join-Path $target "$p-commands") -Recurse -Force
    }
  }
}

# 7. Verificar
$total = (Get-ChildItem $target -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } | Measure-Object).Count
Write-Host "Instalacion completa: $total skills con SKILL.md"
```

---

> Generado automáticamente. Para contribuir al repo: fork → branch → PR.
> Contacto: semaes111 en GitHub
