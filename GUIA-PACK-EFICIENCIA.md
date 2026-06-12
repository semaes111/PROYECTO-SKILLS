# Guía — Instalación del Pack de Eficiencia (ahorro de tokens + calidad)

Skills clave de la implementación ECC para que se invoquen automáticamente en tus proyectos.

## Qué incluye el pack (9 skills)

| Skill | Cuándo se auto-invoca |
|---|---|
| strategic-compact | Cuando el contexto crece y conviene compactar en un breakpoint lógico |
| context-budget | Al auditar consumo del context window (MCPs, skills, rules) |
| cost-tracking | Al pedir uso de tokens / gasto / presupuesto |
| cost-aware-llm-pipeline | Al diseñar pipelines LLM con routing por complejidad |
| optimizacion-tokens-openclaw | Incidente de consumo en bots OpenClaw (4 vectores) |
| continuous-learning-v2 | Aprendizaje por instintos (requiere hooks) |
| verification-loop | Quality gates antes de dar por terminada una tarea |
| search-first | Antes de escribir código nuevo (buscar lo que ya existe) |
| tdd-workflow | Al escribir features, arreglar bugs o refactorizar |

## Cómo funciona la invocación (importante)

Claude Code / Cowork descubren las skills por su campo `description` en el frontmatter
y las cargan **bajo demanda** SOLO cuando el contexto coincide. No entran todas en cada
turno → no inflan el context window. Esto es lo contrario al `skills:{}` de OpenClaw que
carga todo (y causó el incidente de coste). Aquí el ahorro es real y seguro.

## NIVEL 1 — Por proyecto (recomendado para skills específicas)

```bash
cd ~/repos/proyecto-skills
./scripts/install-efficiency-pack.sh --target ~/mi-proyecto-nextjs
```
Instala en `~/mi-proyecto-nextjs/.claude/skills/`. Solo ese proyecto las ve.
Añade `.claude/skills/` a `.gitignore` si no quieres versionarlas, o commitéalas
para que todo el equipo las tenga.

## NIVEL 2 — Global (todos tus proyectos de la máquina)

```bash
cd ~/repos/proyecto-skills
./scripts/install-efficiency-pack.sh --global
```
Instala en `~/.claude/skills/`. Disponibles en cualquier proyecto que abras con Claude Code.
Recomendado para las skills de eficiencia (strategic-compact, context-budget, search-first)
porque aplican a todo.

## NIVEL 3 — Catálogo completo (las 310 skills)

```bash
cd ~/repos/proyecto-skills
./install-skills.sh --all --global                    # todas
./install-skills.sh --category 05 09 --global         # solo devops + utilidades
```

## Activar continuous-learning-v2 (requiere hooks)

Esta skill necesita los hooks de la categoría 21 para observar sesiones:

```bash
# 1. Instalar el pack (incluye la skill)
./scripts/install-efficiency-pack.sh --target ~/mi-proyecto

# 2. Cablear los hooks runtime
mkdir -p ~/mi-proyecto/.claude/hooks
cp -r 21-HOOKS-RUNTIME/scripts ~/mi-proyecto/.claude/hooks/scripts
cp -r 21-HOOKS-RUNTIME/lib ~/mi-proyecto/.claude/hooks/lib
cp 21-HOOKS-RUNTIME/configs/settings.example.json ~/mi-proyecto/.claude/settings.json
```

## Token settings globales (gratis, aplica ya)

Edita `~/.claude/settings.json`:
```json
{
  "model": "sonnet",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  }
}
```
Esto reduce el coste por request independientemente de las skills.

## Verificación

```bash
ls ~/.claude/skills/          # (global) o ~/mi-proyecto/.claude/skills/
# En una sesión de Claude Code, las skills se listan y se invocan solas por contexto.
```
