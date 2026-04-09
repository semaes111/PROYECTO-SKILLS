---
name: review-architecture
description: >
  Ejecuta una auditoría completa de arquitectura sobre el proyecto actual.
  Analiza estructura, seguridad, rendimiento, mantenibilidad y DX.
  Genera un informe con scores ponderados y fixes con código listo.
---

Ejecuta una auditoría arquitectónica completa del proyecto actual. Sigue estos pasos en orden:

## Paso 1: Reconocimiento
- Lee la estructura completa del proyecto (tree del directorio `src/` o `app/`)
- Identifica el framework y las dependencias principales en `package.json`
- Lee `tsconfig.json` para verificar configuración de TypeScript
- Lee `.env.example` o `.env.local` para entender las integraciones

## Paso 2: Análisis de Seguridad (30%)
- Verifica que NO hay `NEXT_PUBLIC_` con secrets
- Revisa middleware de autenticación
- Comprueba RLS en Supabase (si hay acceso al proyecto)
- Busca validaciones Zod en Server Actions y Route Handlers
- Identifica endpoints sin protección de autenticación

## Paso 3: Análisis de Rendimiento (25%)
- Cuenta componentes con "use client" innecesario
- Verifica uso de `next/image` vs `<img>`
- Busca N+1 queries en accesos a Supabase
- Revisa strategy de caching (ISR, revalidate, headers)
- Analiza bundle size si hay `next.config.js` con bundle analyzer

## Paso 4: Análisis de Mantenibilidad (20%)
- Busca `any` en todo el codebase (grep recursivo)
- Identifica componentes > 200 líneas
- Verifica estructura de carpetas vs patrón canónico
- Revisa naming conventions
- Busca código duplicado

## Paso 5: Análisis de Escalabilidad (15%)
- Evalúa separación por dominios
- Verifica manejo de conexiones a DB
- Identifica cuellos de botella potenciales
- Revisa estrategia de background jobs

## Paso 6: Análisis de DX (10%)
- Verifica ESLint, Prettier, Husky
- Revisa scripts en package.json
- Comprueba path aliases
- Verifica CI/CD config

## Paso 7: Generar Informe
Usa el formato definido en la skill `architecture-review` para generar el informe completo con scores, issues priorizados, y código de ejemplo para cada fix.

$ARGUMENTS
