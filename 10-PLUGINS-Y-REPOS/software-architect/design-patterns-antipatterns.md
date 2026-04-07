---
name: design-patterns-antipatterns
description: >
  Catálogo de patrones de diseño y anti-patrones para el stack
  Next.js + Supabase + TypeScript. Se activa cuando el usuario
  necesita tomar decisiones de diseño, refactorizar código,
  o resolver problemas de arquitectura comunes.
---

## Patrones de Diseño Recomendados

### 1. Repository Pattern para Supabase

Encapsula el acceso a datos en funciones tipadas:

```typescript
// lib/repositories/projects.ts
import { createClient } from '@/lib/supabase/server'
import type { Database } from '@/types/database'

type Project = Database['public']['Tables']['projects']['Row']
type ProjectInsert = Database['public']['Tables']['projects']['Insert']

export async function getProjectsByUser(userId: string): Promise<Project[]> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('projects')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
  
  if (error) throw new Error(`Failed to fetch projects: ${error.message}`)
  return data
}

export async function createProject(project: ProjectInsert): Promise<Project> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('projects')
    .insert(project)
    .select()
    .single()
  
  if (error) throw new Error(`Failed to create project: ${error.message}`)
  return data
}
```

### 2. Validation Layer con Zod

```typescript
// lib/validations/project.ts
import { z } from 'zod'

export const CreateProjectSchema = z.object({
  name: z.string()
    .min(1, 'El nombre es obligatorio')
    .max(100, 'Máximo 100 caracteres'),
  description: z.string().max(500).optional(),
  status: z.enum(['draft', 'active', 'archived']).default('draft'),
})

export const UpdateProjectSchema = CreateProjectSchema.partial()

export type CreateProjectInput = z.infer<typeof CreateProjectSchema>
export type UpdateProjectInput = z.infer<typeof UpdateProjectSchema>
```

### 3. Error Boundary Pattern

```typescript
// app/(auth)/projects/error.tsx
'use client'

export default function ProjectsError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] gap-4">
      <h2 className="text-xl font-semibold">Algo salió mal</h2>
      <p className="text-muted-foreground">{error.message}</p>
      <button onClick={reset} className="btn btn-primary">
        Reintentar
      </button>
    </div>
  )
}
```

### 4. Composable Server Actions

```typescript
// lib/actions/projects.ts
'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { CreateProjectSchema } from '@/lib/validations/project'

type ActionResult<T = void> = 
  | { success: true; data: T }
  | { success: false; error: string }

export async function createProjectAction(
  formData: FormData
): Promise<ActionResult<{ id: string }>> {
  const raw = Object.fromEntries(formData)
  const parsed = CreateProjectSchema.safeParse(raw)
  
  if (!parsed.success) {
    return { success: false, error: parsed.error.issues[0].message }
  }
  
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    return { success: false, error: 'No autenticado' }
  }
  
  const { data, error } = await supabase
    .from('projects')
    .insert({ ...parsed.data, user_id: user.id })
    .select('id')
    .single()
  
  if (error) {
    return { success: false, error: error.message }
  }
  
  revalidatePath('/dashboard/projects')
  return { success: true, data: { id: data.id } }
}
```

### 5. Middleware de Autenticación

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

const PUBLIC_ROUTES = ['/login', '/register', '/forgot-password', '/']
const AUTH_ROUTES = ['/login', '/register'] // Redirigir a dashboard si ya autenticado

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request })
  
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options)
          })
        },
      },
    }
  )
  
  const { data: { user } } = await supabase.auth.getUser()
  const pathname = request.nextUrl.pathname
  
  // No autenticado intentando acceder a ruta protegida
  if (!user && !PUBLIC_ROUTES.some(r => pathname.startsWith(r))) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  
  // Autenticado intentando acceder a login/register
  if (user && AUTH_ROUTES.some(r => pathname.startsWith(r))) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }
  
  return response
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|api/webhooks).*)'],
}
```

---

## Anti-Patrones a Evitar

### ❌ "use client" innecesario
```tsx
// MAL — componente marcado como client sin razón
'use client'
export default function UserProfile({ user }: { user: User }) {
  return <div>{user.name}</div> // No hay estado ni interactividad
}

// BIEN — Server Component (por defecto)
export default function UserProfile({ user }: { user: User }) {
  return <div>{user.name}</div>
}
```

### ❌ Fetch en Client Component cuando Server Component basta
```tsx
// MAL
'use client'
import { useEffect, useState } from 'react'
export default function Projects() {
  const [projects, setProjects] = useState([])
  useEffect(() => { fetch('/api/projects').then(r => r.json()).then(setProjects) }, [])
  return <ProjectList projects={projects} />
}

// BIEN
export default async function Projects() {
  const supabase = await createClient()
  const { data } = await supabase.from('projects').select('*')
  return <ProjectList projects={data ?? []} />
}
```

### ❌ `any` en cualquier parte del código
```typescript
// MAL
const handleData = (data: any) => { ... }

// BIEN
interface ProjectData {
  id: string
  name: string
  status: 'draft' | 'active' | 'archived'
}
const handleData = (data: ProjectData) => { ... }
```

### ❌ RLS deshabilitado o policies permisivas
```sql
-- MAL — permite todo a todos
CREATE POLICY "allow all" ON public.patients FOR ALL USING (true);

-- BIEN — scoped al usuario autenticado
CREATE POLICY "users see own patients"
  ON public.patients FOR SELECT
  USING (auth.uid() = doctor_id);
```

### ❌ Secrets en NEXT_PUBLIC_
```env
# MAL
NEXT_PUBLIC_SUPABASE_SERVICE_KEY=eyJhbGci...

# BIEN
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...  # Solo server-side
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...  # OK, es público
```

### ❌ God Components (>300 líneas)
Refactorizar en composables: extraer hooks, sub-componentes, y lógica a utils.

### ❌ Prop Drilling profundo
Usar Server Components para pasar datos directamente, o React Context solo cuando sea estrictamente necesario en client components.
