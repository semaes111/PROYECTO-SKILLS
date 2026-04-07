---
name: architecture-review
description: >
  Criterios de revisión y auditoría de arquitectura de software.
  Se activa cuando el usuario pide evaluar, auditar, revisar, o mejorar
  código, estructura de proyecto, rendimiento o seguridad.
  Genera informes estructurados con scores y recomendaciones accionables.
---

## Framework de Revisión Arquitectónica

### Categorías de Evaluación (Score 1-10 cada una)

#### 1. SEGURIDAD (Peso: 30%)
- RLS habilitado y políticas correctas en TODAS las tablas de Supabase
- Validación de inputs con Zod en Server Actions Y Route Handlers
- Middleware de autenticación en rutas protegidas
- Variables de entorno NO expuestas al cliente (NEXT_PUBLIC_ solo para datos públicos)
- CORS configurado correctamente en Route Handlers
- CSP (Content Security Policy) headers configurados
- Rate limiting en endpoints sensibles
- Sanitización de HTML para prevenir XSS
- Service role key NUNCA en client-side
- RBAC (Role-Based Access Control) implementado si hay múltiples roles

#### 2. RENDIMIENTO (Peso: 25%)
- Server Components por defecto (no "use client" innecesarios)
- Lazy loading (`dynamic()`) para componentes pesados
- `next/image` con width/height explícitos
- Queries con índices apropiados en PostgreSQL
- Cache headers en Route Handlers (`Cache-Control`, `s-maxage`)
- Bundle size < 100KB first load JS por ruta
- No N+1 queries (usar `.select('*, relation(*)')` en Supabase)
- `Suspense` boundaries para streaming progresivo
- `loading.tsx` en cada ruta significativa
- Prefetching inteligente con `<Link prefetch>`

#### 3. MANTENIBILIDAD (Peso: 20%)
- Cero `any` en TypeScript — tipos estrictos en todo el codebase
- Componentes < 200 líneas (refactorizar si exceden)
- Separación clara de responsabilidades (UI / lógica / datos)
- Naming consistente: PascalCase componentes, camelCase funciones, UPPER_SNAKE constantes
- Schemas de validación colocados junto a sus formularios/acciones
- Error boundaries (`error.tsx`) en cada segmento de ruta
- Tests para lógica crítica de negocio (mínimo: acciones, utils, validaciones)
- README actualizado con setup, variables de entorno, y decisiones de arquitectura

#### 4. ESCALABILIDAD (Peso: 15%)
- Conexiones a DB gestionadas correctamente (connection pooling via Supabase)
- Separación de concerns por dominio (feature-based structure)
- Edge Functions para operaciones que necesitan baja latencia global
- Estrategia de caché definida (ISR, on-demand revalidation, stale-while-revalidate)
- Queue system para tareas pesadas (n8n, Inngest, o similar)

#### 5. DX (Developer Experience) (Peso: 10%)
- ESLint + Prettier configurados con reglas estrictas
- Husky + lint-staged para pre-commit hooks
- Path aliases configurados (`@/components`, `@/lib`)
- `.env.example` con todas las variables documentadas
- Scripts útiles en `package.json` (dev, build, lint, type-check, db:migrate)
- CI/CD configurado (GitHub Actions o Vercel auto-deploy)

### Formato de Informe

Al generar un informe de revisión, seguir esta estructura:

```
## Informe de Arquitectura — [Nombre del Proyecto]
Fecha: [fecha]
Score Global: [X]/10

### Resumen Ejecutivo
[2-3 frases sobre el estado general]

### Scores por Categoría
| Categoría       | Score | Peso  | Ponderado |
|-----------------|-------|-------|-----------|
| Seguridad       | X/10  | 30%   | X.X       |
| Rendimiento     | X/10  | 25%   | X.X       |
| Mantenibilidad  | X/10  | 20%   | X.X       |
| Escalabilidad   | X/10  | 15%   | X.X       |
| DX              | X/10  | 10%   | X.X       |
| **TOTAL**       |       |       | **X.X/10**|

### Issues Críticos (resolver inmediatamente)
1. [Issue con código de ejemplo del fix]

### Issues Importantes (resolver esta semana)
1. [Issue con código de ejemplo del fix]

### Mejoras Recomendadas (backlog)
1. [Mejora con beneficio esperado]

### Código de Ejemplo para Fixes
[Bloques de código listos para copiar/pegar]
```
