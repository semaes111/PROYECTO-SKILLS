---
name: supabase-database-architecture
description: >
  Patrones de diseño de base de datos con Supabase/PostgreSQL.
  Se activa cuando el usuario trabaja con migraciones, schemas,
  RLS policies, Edge Functions, triggers, o diseño de tablas.
  Incluye templates para migraciones seguras y optimizadas.
---

## Supabase Database Architecture Patterns

### Template de Migración Estándar

Toda migración debe seguir este patrón:

```sql
-- ============================================================
-- Migración: [nombre_descriptivo]
-- Descripción: [qué hace esta migración]
-- Autor: [autor]
-- Fecha: [fecha]
-- ============================================================

-- 1. TABLA(S)
CREATE TABLE IF NOT EXISTS public.nombre_tabla (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  -- campos de negocio
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  -- FK si aplica
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- 2. ÍNDICES
CREATE INDEX IF NOT EXISTS idx_nombre_tabla_user_id 
  ON public.nombre_tabla(user_id);
CREATE INDEX IF NOT EXISTS idx_nombre_tabla_created_at 
  ON public.nombre_tabla(created_at DESC);

-- 3. RLS (OBLIGATORIO)
ALTER TABLE public.nombre_tabla ENABLE ROW LEVEL SECURITY;

-- Policy: Usuarios solo ven sus propios datos
CREATE POLICY "Users can view own data"
  ON public.nombre_tabla FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Usuarios solo insertan sus propios datos
CREATE POLICY "Users can insert own data"
  ON public.nombre_tabla FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Usuarios solo actualizan sus propios datos
CREATE POLICY "Users can update own data"
  ON public.nombre_tabla FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Usuarios solo eliminan sus propios datos
CREATE POLICY "Users can delete own data"
  ON public.nombre_tabla FOR DELETE
  USING (auth.uid() = user_id);

-- 4. TRIGGER updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.nombre_tabla
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- 5. COMENTARIOS
COMMENT ON TABLE public.nombre_tabla IS 'Descripción de la tabla';
COMMENT ON COLUMN public.nombre_tabla.id IS 'Identificador único';
```

### Patrones de RLS Avanzados

#### Multi-tenant con organizaciones
```sql
-- El usuario pertenece a una org que tiene acceso
CREATE POLICY "Org members can view"
  ON public.projects FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_members.org_id = projects.org_id
        AND org_members.user_id = auth.uid()
    )
  );
```

#### Roles jerárquicos (admin > editor > viewer)
```sql
CREATE POLICY "Admins can do everything"
  ON public.projects FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_members.org_id = projects.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'admin'
    )
  );
```

#### Datos públicos + privados en la misma tabla
```sql
CREATE POLICY "Public data is visible to all"
  ON public.posts FOR SELECT
  USING (
    is_public = true
    OR auth.uid() = author_id
  );
```

### Patrones de Índices para Rendimiento

```sql
-- Búsqueda por texto (trigram para LIKE/ILIKE)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_patients_name_trgm 
  ON public.patients USING gin(name gin_trgm_ops);

-- Índice parcial (solo filas activas)
CREATE INDEX idx_subscriptions_active 
  ON public.subscriptions(user_id) 
  WHERE status = 'active';

-- Índice compuesto para queries frecuentes
CREATE INDEX idx_appointments_user_date 
  ON public.appointments(user_id, appointment_date DESC);

-- Índice GIN para columnas JSONB
CREATE INDEX idx_metadata_gin 
  ON public.records USING gin(metadata);
```

### Edge Functions — Cuándo Usar

| Caso | ¿Edge Function? | Alternativa |
|------|-----------------|-------------|
| Webhook externo (Stripe, etc.) | ✅ Sí | Route Handler si ya tienes Next.js |
| Cron job (tareas programadas) | ✅ Sí | pg_cron si es solo SQL |
| Procesamiento de imágenes | ✅ Sí | Vercel Image Optimization |
| Envío de emails | ✅ Sí | n8n workflow |
| Lógica que NO necesita Next.js | ✅ Sí | — |
| CRUD estándar | ❌ No | Server Component directo |
| Validación de formularios | ❌ No | Server Action + Zod |

### Checklist Post-Migración

1. `supabase gen types typescript --project-id <ref> > src/types/database.ts`
2. Verificar que RLS está habilitado: `SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';`
3. Ejecutar `SUPABASE:get_advisors` para security checks
4. Test manual de las policies con diferentes roles
5. Actualizar schemas Zod si cambió la estructura
