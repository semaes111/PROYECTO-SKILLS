---
name: generate-migration
description: >
  Genera una migración SQL completa para Supabase con RLS policies,
  índices, triggers de updated_at, y comentarios. Lista para aplicar.
---

Genera una migración SQL completa y segura para Supabase basándote en los requisitos del usuario.

## Requisitos obligatorios de la migración:

1. **Tabla(s)** con tipos PostgreSQL correctos:
   - `id UUID DEFAULT gen_random_uuid() PRIMARY KEY`
   - `created_at TIMESTAMPTZ DEFAULT now() NOT NULL`
   - `updated_at TIMESTAMPTZ DEFAULT now() NOT NULL`
   - FK con `ON DELETE CASCADE` o `SET NULL` según el caso

2. **RLS habilitado** con policies para SELECT, INSERT, UPDATE, DELETE:
   - Scope por `auth.uid()` como mínimo
   - Policies con nombres descriptivos en inglés

3. **Índices** recomendados para las queries esperadas:
   - Índice en cada FK
   - Índice en campos de búsqueda frecuente
   - Índices parciales si hay filtros comunes (ej: `WHERE status = 'active'`)

4. **Trigger** `handle_updated_at` para actualización automática

5. **Comentarios** SQL en tabla y columnas principales

6. **Extensiones** si son necesarias (pg_trgm, pgcrypto, etc.)

## Output esperado:
- SQL listo para copiar en Supabase → SQL Editor o aplicar como migración
- Tipos TypeScript inferidos de la tabla (para actualizar `database.ts`)
- Schema Zod de validación correspondiente

## Requisitos del usuario:
$ARGUMENTS
