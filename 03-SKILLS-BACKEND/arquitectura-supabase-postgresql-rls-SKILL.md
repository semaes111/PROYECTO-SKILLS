---
name: supabase-backend
description: "Arquitectura y estructuración de proyectos backend en Supabase. Usar cuando se diseñe base de datos PostgreSQL, migraciones, Row Level Security (RLS), Edge Functions, triggers, funciones SQL, políticas de seguridad, Storage, Realtime, o Auth. Activar para: diseño de esquemas, modelado de datos, seguridad de base de datos, APIs con PostgREST, webhooks, y arquitectura serverless."
---

# Supabase Backend Architecture

## Filosofía de Diseño

Supabase es PostgreSQL con superpoderes. El backend se construye directamente en la base de datos:

- **Database-first**: La lógica vive en PostgreSQL, no en middleware
- **RLS obligatorio**: Nunca desactivar Row Level Security en producción
- **Migrations versionadas**: Todo cambio de esquema en archivos SQL
- **Type-safe**: Generar tipos TypeScript desde el esquema

---

## Estructura de Proyecto Supabase

```
proyecto/
├── supabase/
│   ├── config.toml                 # Configuración local
│   ├── migrations/                 # Migraciones SQL versionadas
│   │   ├── 20250101000000_init.sql
│   │   ├── 20250101000001_auth_setup.sql
│   │   └── 20250101000002_rls_policies.sql
│   ├── functions/                  # Edge Functions (Deno)
│   │   ├── hello-world/
│   │   │   └── index.ts
│   │   └── webhook-handler/
│   │       └── index.ts
│   ├── seed.sql                    # Datos iniciales
│   └── tests/                      # Tests de base de datos
│       └── database.test.sql
├── src/
│   └── types/
│       └── database.ts             # Tipos generados
└── .env.local
```

---

## Migraciones

### Convención de Nombres

```
YYYYMMDDHHMMSS_descripcion_corta.sql
```

Ejemplos:
```
20250125100000_create_users_table.sql
20250125100001_add_projects_table.sql
20250125100002_create_rls_policies.sql
20250125100003_add_indexes.sql
```

### Comandos CLI

```bash
# Crear nueva migración
supabase migration new create_users_table

# Aplicar migraciones pendientes
supabase db push

# Reset completo (dev only)
supabase db reset

# Ver estado
supabase migration list

# Generar tipos TypeScript
supabase gen types typescript --local > src/types/database.ts
```

### Template de Migración

```sql
-- supabase/migrations/20250125100000_create_users_table.sql

-- ============================================
-- TABLA: profiles
-- Extiende auth.users con datos de aplicación
-- ============================================

CREATE TABLE public.profiles (
  -- Clave primaria vinculada a auth
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Campos de perfil
  full_name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
  
  -- Metadata
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comentarios de documentación
COMMENT ON TABLE public.profiles IS 'Perfiles de usuario extendidos';
COMMENT ON COLUMN public.profiles.role IS 'Rol del usuario: user, admin, moderator';

-- Trigger para updated_at automático
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Índices
CREATE INDEX idx_profiles_role ON public.profiles(role);

-- RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
```

---

## Row Level Security (RLS)

### REGLA DE ORO

```sql
-- SIEMPRE habilitar RLS en TODAS las tablas
ALTER TABLE public.mi_tabla ENABLE ROW LEVEL SECURITY;

-- NUNCA usar esto en producción:
-- ALTER TABLE public.mi_tabla DISABLE ROW LEVEL SECURITY; ❌
```

### Patrones de Políticas

#### 1. Usuario ve solo sus datos

```sql
-- SELECT: Usuario ve sus propios registros
CREATE POLICY "Users view own data"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- ALL: Usuario CRUD completo en sus datos
CREATE POLICY "Users manage own data"
  ON public.profiles
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

#### 2. Datos públicos (lectura) + privados (escritura)

```sql
-- Cualquiera puede leer
CREATE POLICY "Public read access"
  ON public.posts
  FOR SELECT
  USING (published = true);

-- Solo el autor puede modificar
CREATE POLICY "Authors manage own posts"
  ON public.posts
  FOR ALL
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);
```

#### 3. Roles y permisos

```sql
-- Admin tiene acceso total
CREATE POLICY "Admin full access"
  ON public.profiles
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Función helper para verificar rol
CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = required_role
  );
END;
$$;

-- Uso en política
CREATE POLICY "Moderators can update"
  ON public.posts
  FOR UPDATE
  USING (public.has_role('moderator') OR auth.uid() = author_id);
```

#### 4. Acceso por organización/equipo

```sql
-- Usuario pertenece a organización
CREATE POLICY "Org members access"
  ON public.projects
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.organization_members
      WHERE organization_id = projects.organization_id
        AND user_id = auth.uid()
    )
  );
```

#### 5. Service Role (bypass RLS)

```sql
-- Para operaciones de servidor (Edge Functions, webhooks)
-- Usar service_role key que bypasea RLS automáticamente
-- NUNCA exponer service_role key en cliente
```

---

## Funciones SQL

### Template de Función

```sql
CREATE OR REPLACE FUNCTION public.nombre_funcion(
  param1 TEXT,
  param2 INTEGER DEFAULT 10
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  total BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER  -- Ejecuta con permisos del creador
SET search_path = public  -- Seguridad: evita hijacking de schema
AS $$
DECLARE
  variable_local TEXT;
BEGIN
  -- Validación de entrada
  IF param1 IS NULL THEN
    RAISE EXCEPTION 'param1 es requerido';
  END IF;
  
  -- Lógica
  RETURN QUERY
  SELECT 
    t.id,
    t.name,
    COUNT(*)::BIGINT as total
  FROM public.tabla t
  WHERE t.category = param1
  GROUP BY t.id, t.name
  LIMIT param2;
END;
$$;

-- Permisos
GRANT EXECUTE ON FUNCTION public.nombre_funcion TO authenticated;
```

### Función para updated_at automático

```sql
-- Crear una vez, usar en todas las tablas
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;
```

### Función RPC para agregaciones

```sql
CREATE OR REPLACE FUNCTION public.get_dashboard_stats()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_users', (SELECT COUNT(*) FROM profiles WHERE id = auth.uid()),
    'total_projects', (
      SELECT COUNT(*) FROM projects 
      WHERE owner_id = auth.uid()
    ),
    'recent_activity', (
      SELECT json_agg(row_to_json(a))
      FROM (
        SELECT id, action, created_at
        FROM activity_log
        WHERE user_id = auth.uid()
        ORDER BY created_at DESC
        LIMIT 10
      ) a
    )
  ) INTO result;
  
  RETURN result;
END;
$$;

-- Llamar desde cliente:
-- const { data } = await supabase.rpc('get_dashboard_stats')
```

---

## Triggers

### Crear perfil automáticamente al registrarse

```sql
-- Trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$;

-- Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### Auditoría automática

```sql
-- Tabla de auditoría
CREATE TABLE public.audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data JSONB,
  new_data JSONB,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Función genérica de auditoría
CREATE OR REPLACE FUNCTION public.audit_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.audit_log (table_name, record_id, action, old_data, new_data, user_id)
  VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD)::JSONB ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW)::JSONB ELSE NULL END,
    auth.uid()
  );
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Aplicar a cualquier tabla
CREATE TRIGGER audit_projects
  AFTER INSERT OR UPDATE OR DELETE ON public.projects
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_trigger();
```

---

## Edge Functions

### Estructura de Edge Function

```typescript
// supabase/functions/process-webhook/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Crear cliente Supabase con service role (bypasea RLS)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const body = await req.json()
    
    // Validar payload
    if (!body.event_type) {
      throw new Error('event_type is required')
    }

    // Procesar webhook
    const { data, error } = await supabase
      .from('webhook_events')
      .insert({
        event_type: body.event_type,
        payload: body,
      })
      .select()
      .single()

    if (error) throw error

    return new Response(
      JSON.stringify({ success: true, id: data.id }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})
```

### Deploy Edge Functions

```bash
# Deploy función específica
supabase functions deploy process-webhook

# Deploy todas
supabase functions deploy

# Logs en tiempo real
supabase functions logs process-webhook --follow
```

---

## Storage

### Configurar Bucket

```sql
-- Crear bucket privado
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false);

-- Crear bucket público
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);
```

### Políticas de Storage

```sql
-- Usuarios suben a su propia carpeta
CREATE POLICY "Users upload own files"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Usuarios ven sus archivos
CREATE POLICY "Users view own files"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Usuarios eliminan sus archivos
CREATE POLICY "Users delete own files"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Avatares públicos (cualquiera lee)
CREATE POLICY "Public avatar access"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'avatars');

-- Solo el usuario sube su avatar
CREATE POLICY "Users upload own avatar"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

---

## Realtime

### Habilitar Realtime en tabla

```sql
-- En el Dashboard o por SQL
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
```

### Suscripción desde cliente

```typescript
// Escuchar cambios en mensajes del usuario
const channel = supabase
  .channel('user-messages')
  .on(
    'postgres_changes',
    {
      event: '*',  // INSERT, UPDATE, DELETE
      schema: 'public',
      table: 'messages',
      filter: `recipient_id=eq.${userId}`,
    },
    (payload) => {
      console.log('Change:', payload)
    }
  )
  .subscribe()

// Cleanup
channel.unsubscribe()
```

---

## Índices y Performance

### Índices Esenciales

```sql
-- Índice para foreign keys (PostgreSQL no los crea automáticamente)
CREATE INDEX idx_posts_author ON public.posts(author_id);
CREATE INDEX idx_comments_post ON public.comments(post_id);

-- Índice compuesto para queries frecuentes
CREATE INDEX idx_posts_author_status ON public.posts(author_id, status);

-- Índice para búsqueda de texto
CREATE INDEX idx_posts_title_search ON public.posts 
  USING gin(to_tsvector('spanish', title));

-- Índice parcial (solo filas activas)
CREATE INDEX idx_active_users ON public.profiles(id) 
  WHERE status = 'active';

-- Índice para JSONB
CREATE INDEX idx_metadata_tags ON public.posts 
  USING gin(metadata->'tags');
```

### Analizar queries lentas

```sql
-- Habilitar logging de queries lentas
ALTER DATABASE postgres SET log_min_duration_statement = 1000;

-- Ver queries más lentas
SELECT 
  query,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## Checklist de Seguridad

- [ ] RLS habilitado en TODAS las tablas públicas
- [ ] Políticas RLS probadas con diferentes roles
- [ ] Funciones SECURITY DEFINER tienen `SET search_path = public`
- [ ] Service role key NUNCA en código cliente
- [ ] Anon key solo para operaciones públicas
- [ ] JWT secret rotado de default
- [ ] CORS configurado correctamente
- [ ] Rate limiting en Edge Functions
- [ ] Validación de inputs en funciones SQL
- [ ] Backups automáticos habilitados

---

## Comandos Útiles

```bash
# Iniciar proyecto local
supabase init
supabase start

# Estado del proyecto
supabase status

# Logs de base de datos
supabase db logs

# Diff entre local y remoto
supabase db diff

# Pull esquema remoto
supabase db pull

# Generar tipos
supabase gen types typescript --local > src/types/database.ts

# Reset base de datos (dev)
supabase db reset

# Link a proyecto remoto
supabase link --project-ref <project-id>

# Push migraciones a producción
supabase db push
```
