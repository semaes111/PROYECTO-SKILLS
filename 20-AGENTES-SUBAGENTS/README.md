# 20 — Agentes y Subagentes

Agentes especializados para delegación de tareas en Claude Code (Task tool / subagents).
Cherry-pick de ECC (`agents/`) adaptado al stack NextHorizont.

| Agente | Origen ECC | Uso |
|---|---|---|
| revisor-codigo-general | code-reviewer | Revisión general post-implementación |
| revisor-typescript | typescript-reviewer | Type safety, async, seguridad Node/web — OBLIGATORIO en proyectos TS |
| revisor-react | react-reviewer | Componentes, hooks, Server/Client Components |
| revisor-base-datos-postgres | database-reviewer | Esquemas, queries, índices, RLS (Supabase) |
| revisor-seguridad | security-reviewer | Auth, input, secretos, PHI/PII (crítico para clínica) |
| planificador-features | planner | Fase de diseño previa a implementar |
| guia-tdd | tdd-guide | Disciplina test-first |
| cazador-fallos-silenciosos | silent-failure-hunter | Errores tragados, catch vacíos, promesas sin await |

## Convención

Frontmatter con `origin: ECC`, `ecc-version`, `ecc-source`, `ecc-imported` para trazabilidad y re-sync.
Contenido en inglés (convención del repo: nombre español, contenido upstream intacto).

## Sincronización upstream

Ver `scripts/audit-ecc-diff.sh` en la raíz del repo. Nunca pull automático.
