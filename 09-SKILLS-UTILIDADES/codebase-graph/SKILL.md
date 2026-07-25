---
name: codebase-graph
description: Comprensión estructural de repositorios mediante CodeGraph y su servidor MCP. Usar para arquitectura, callers/callees, impacto, tests afectados, onboarding y repositorios grandes. No indexar repos pequeños sin necesidad recurrente.
license: MIT para CodeGraph; verificar herramientas complementarias por separado
---

# Codebase Graph

## Regla de activación
- Menos de 100 ficheros y consulta puntual: `rg`, lectura directa y herramientas nativas.
- Más de 100 ficheros o trabajo recurrente: inicializar CodeGraph.
- Monorepo: indexar por servicio o usar `projectPath`.

## Seguridad previa
1. Revisar `.gitignore` y secretos antes de indexar.
2. Ejecutar `codegraph telemetry off` por defecto.
3. No indexar credenciales, historiales clínicos ni expedientes de clientes.

## Instalación reproducible
Ejecutar `scripts/install-codegraph.sh`. No usa `curl | sh`; instala el paquete npm oficial, desactiva telemetría y muestra primero las configuraciones MCP.

## Flujo
```bash
cd /ruta/repositorio
codegraph init
codegraph status
codegraph explore "explica el flujo de autenticación"
codegraph impact nombreSimbolo
codegraph affected $(git diff --name-only)
```

## MCP
La superficie principal es `codegraph_explore`. Para herramientas adicionales:
```bash
export CODEGRAPH_MCP_TOOLS=explore,node,search,callers,callees,impact,status
```

## Alias
- `$codegraph`: consulta estructural puntual.
- `$understand-codebase`: análisis global; usa CodeGraph y solo recomienda una capa visual adicional cuando aporte valor.
