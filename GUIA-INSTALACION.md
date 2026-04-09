# GUÍA DE INSTALACIÓN COMPLETA — PROYECTO SKILLS para Claude Code / Cowork

> Última actualización: 2026-04-09
> Repositorio: `https://github.com/semaes111/PROYECTO-SKILLS`
> Total: **194 skills funcionales** en **17 categorías**

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

| # | Categoría | Skills | Incluye subdirectorios |
|---|-----------|--------|------------------------|
| 01 | SKILLS-3D-WEB | 19 | No |
| 02 | SKILLS-FRONTEND | 12 | Sí (design-md-references/) |
| 03 | SKILLS-BACKEND | 18 | No |
| 04 | SKILLS-MOBILE-EXPO | 5 | No |
| 05 | SKILLS-DEVOPS-INFRA | 17 | Sí (4 dir-skills con recursos) |
| 06 | SKILLS-DOCUMENTOS | 10 | No |
| 07 | SKILLS-LEGAL-FISCAL | 10 | Sí (demandas-tributarias-references/) |
| 08 | SKILLS-MARKETING-COPY | 8 | No |
| 09 | SKILLS-UTILIDADES | 46 | Sí (6 dir-skills con recursos) |
| 11 | SKILLS-DATOS-ANALYTICS | 7 | No |
| 13 | SKILLS-FINANZAS-CONTABILIDAD | 6 | No |
| 14 | SKILLS-VENTAS-CRM | 15 | No |
| 15 | SKILLS-SOPORTE-CLIENTE | 5 | No |
| 16 | SKILLS-PRODUCTO-PM | 6 | No |
| 17 | SKILLS-PRODUCTIVIDAD | 2 | No |
| 18 | SKILLS-BIOINVESTIGACION | 5 | No |
| 19 | SKILLS-BUSQUEDA-EMPRESARIAL | 3 | No |
| | **TOTAL** | **194** | |

### 1.2 Tipos de assets

**TIPO A — Flat Skills (mayoría)**
Archivos individuales con formato `nombre-SKILL.md` dentro de las carpetas de categoría.
Se instalan como: `~/.claude/skills/user/nombre/SKILL.md`

**TIPO B — Dir-Skills (skills con recursos adicionales)**
Subdirectorios que contienen un `SKILL.md` principal más archivos de soporte (references/, templates/, scripts/).
Se copian como directorio completo: `~/.claude/skills/user/nombre/` (recursivo)

### 1.3 Origen de las skills

Las skills provienen de 3 fuentes:

- **Originales NextHorizont**: Skills creadas específicamente para el ecosistema (legal-fiscal, backend Supabase, n8n, carbon credits)
- **Curadas de la comunidad**: Skills adaptadas y traducidas de repositorios open-source (Anthropic examples, knowledge-work-plugins)
- **ECC (Effective Claude Code)**: Skills de patrones agénticos extraídas de la comunidad Claude Code

---

## 2. Requisitos previos

| Sistema | Ruta de skills |
|---------|---------------|
| **Windows** | `C:\Users\<usuario>\.claude\skills\user\` |
| **macOS** | `~/.claude/skills/user/` |
| **Linux** | `~/.claude/skills/user/` |

> **IMPORTANTE (Windows):** Desde una sesión de Cowork, el directorio `~/.claude/skills/` es un mount FUSE de solo lectura. Hay que usar PowerShell nativo de Windows (Método 2) o instalar desde Git Bash.

Software necesario:

- **Git** — `git --version` debe funcionar
- **Claude Code** o **Cowork** — Donde se usarán las skills

---

## 3. Método 1: Instalación automática

```bash
# Clonar
git clone https://github.com/semaes111/PROYECTO-SKILLS.git
cd PROYECTO-SKILLS

# Dar permisos
chmod +x install-skills.sh

# Instalar todo
./install-skills.sh --all

# O instalar solo categorías específicas
./install-skills.sh --category 01 03 07 09
```

### Opciones del script

| Flag | Uso |
|------|-----|
| `--all` | Instala las 194 skills |
| `--category 01 03` | Instala solo categorías específicas |
| `--list` | Muestra categorías disponibles |
| `--target /ruta` | Instala en ruta personalizada |
| `--force` | Sobrescribe skills existentes |
| `--uninstall` | Elimina todas las skills instaladas |

---

## 4. Método 2: Instalación manual con PowerShell

Para Windows sin Git Bash:

```powershell
# 1. Clonar
git clone https://github.com/semaes111/PROYECTO-SKILLS.git
cd PROYECTO-SKILLS

# 2. Crear directorio destino
$dest = "$env:USERPROFILE\.claude\skills\user"
New-Item -ItemType Directory -Force -Path $dest

# 3. Copiar todas las skills
Get-ChildItem -Recurse -Filter "*SKILL.md" | ForEach-Object {
    $name = $_.BaseName -replace '-SKILL$',''
    $skillDir = Join-Path $dest $name
    New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
    Copy-Item $_.FullName (Join-Path $skillDir "SKILL.md")
    Write-Host "Instalada: $name"
}
```

---

## 5. Método 3: Instalación desde Cowork

Dentro de una sesión de Cowork, pedir a Claude:

```
Clona https://github.com/semaes111/PROYECTO-SKILLS.git y ejecuta ./install-skills.sh --all
```

O para instalación manual sin script:

```
Copia todas las *-SKILL.md del repo PROYECTO-SKILLS a ~/.claude/skills/user/
```

---

## 6. Detalle por tipo de asset

### Flat skills (archivo único)

```
Origen:  03-SKILLS-BACKEND/arquitectura-supabase-postgresql-rls-SKILL.md
Destino: ~/.claude/skills/user/arquitectura-supabase-postgresql-rls/SKILL.md
```

### Dir-skills (con recursos)

```
Origen:  05-SKILLS-DEVOPS-INFRA/orquestacion-docker-agente-autonomo/
         ├── SKILL.md
         ├── docker-compose.yml
         └── config/
Destino: ~/.claude/skills/user/orquestacion-docker-agente-autonomo/
         ├── SKILL.md
         ├── docker-compose.yml
         └── config/
```

---

## 7. Verificación post-instalación

```bash
# Contar skills instaladas
find ~/.claude/skills/user/ -name "SKILL.md" | wc -l
# Esperado: 194

# Verificar que Claude las detecta
# En Claude Code:
claude --print "¿Cuántas skills tienes disponibles en /user/?"

# Verificar una skill específica
cat ~/.claude/skills/user/arquitectura-supabase-postgresql-rls/SKILL.md | head -10
```

---

## 8. Estructura de directorios resultante

```
~/.claude/skills/user/
├── arte-generativo-algoritmo-p5js/SKILL.md
├── arquitectura-supabase-postgresql-rls/SKILL.md
├── auditoria-contexto-tokens/SKILL.md
├── blueprint-planificacion-features/SKILL.md
├── ...
└── [194 directorios, uno por skill]
```

---

## 9. Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| `Permission denied` | Script sin permisos | `chmod +x install-skills.sh` |
| Skills no aparecen | Sesión no reiniciada | Cerrar y reabrir Claude Code / Cowork |
| Git clone falla | Repo privado | Usar token: `git clone https://TOKEN@github.com/...` |
| Windows: rutas rotas | CMD no soporta bash | Usar Git Bash o PowerShell (Método 2) |
| Cowork: no puede escribir | Mount FUSE read-only | Usar Método 2 (PowerShell nativo) |
| Skill no se activa | Nombre no coincide con trigger | Revisar campo `triggers:` en el SKILL.md |

---

## 10. Mantenimiento y actualización

```bash
# Actualizar a última versión
cd PROYECTO-SKILLS
git pull origin main
./install-skills.sh --all --force

# Desinstalar todo
./install-skills.sh --uninstall

# Ver qué skills tienes instaladas
ls ~/.claude/skills/user/ | wc -l
```

### Versionado

El repositorio usa versionado semántico en el script:
- **v6.0** — 194 skills, 17 categorías (limpieza: eliminados duplicados, stubs, normalizado naming)

---

Curado por **NextHorizont AI SL** — Sergio Martínez Escobar
