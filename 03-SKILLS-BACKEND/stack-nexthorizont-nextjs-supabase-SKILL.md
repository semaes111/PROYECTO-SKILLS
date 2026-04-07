---
name: nexthorizont
description: "Stack de desarrollo para NextHorizont AI. Usar cuando se cree cualquier aplicación, componente, API, dashboard o feature con Next.js + Supabase + TypeScript. Incluye patrones de Server Components, Route Handlers, autenticación, y estructura de proyectos. Activar para: crear apps, scaffolding, APIs REST, dashboards, integración Supabase, componentes React, testing."
---

# NextHorizont AI - Stack de Desarrollo

## Filosofía del Stack

NextHorizont AI construye soluciones enterprise de IA. Todo el código debe ser:
- **Production-ready**: No prototipos, código deployable desde el inicio
- **Type-safe**: TypeScript estricto, NUNCA usar `any`
- **Performant**: Server Components por defecto, mínimo JavaScript en cliente
- **Mantenible**: Estructura clara, separación de responsabilidades

---

## Stack Tecnológico

| Capa | Tecnología | Versión |
|------|------------|---------|
| Framework | Next.js (App Router) | 15+ |
| Base de datos | Supabase (PostgreSQL) | Latest |
| Auth | Supabase Auth / Clerk | Latest |
| Styling | Tailwind CSS | 4+ |
| UI Components | shadcn/ui | Latest |
| Estado cliente | Zustand / React Query | Latest |
| Validación | Zod | Latest |
| Deploy | Vercel | - |

---

## Patrón de Decisión: Cómo Acceder a Datos

```
┌─────────────────────────────────────────────────────────────────┐
│                    ¿CÓMO ACCEDO A DATOS?                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │ ¿Es lectura para renderizar?  │
              └───────────────────────────────┘
                     │              │
                    SÍ             NO
                     │              │
                     ▼              ▼
        ┌─────────────────┐  ┌──────────────────────┐
        │ SERVER COMPONENT│  │ ¿Es mutación simple  │
        │ + acceso directo│  │ con UX acoplada?     │
        │ a Supabase      │  └──────────────────────┘
        │ (PATRÓN DEFAULT)│       │           │
        └─────────────────┘      SÍ          NO
                                  │           │
                                  ▼           ▼
                    ┌──────────────┐  ┌─────────────────┐
                    │SERVER ACTION │  │ ROUTE HANDLER   │
                    │"use server"  │  │ API REST        │
                    │Forms simples │  │ (RECOMENDADO)   │
                    └──────────────┘  └─────────────────┘
```

### 1. Server Components + Acceso Directo (DEFAULT - 80% de casos)

```typescript
// app/dashboard/page.tsx
import { createClient } from '@/lib/supabase/server'

export default async function DashboardPage() {
  const supabase = await createClient()
  
  const { data: projects, error } = await supabase
    .from('projects')
    .select('id, name, status, created_at')
    .order('created_at', { ascending: false })
  
  if (error) throw new Error(error.message)
  
  return (
    <div className="grid gap-4">
      {projects.map(project => (
        <ProjectCard key={project.id} project={project} />
      ))}
    </div>
  )
}
```

### 2. Route Handlers (APIs reutilizables, testing, seguridad)

```typescript
// app/api/projects/route.ts
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import { z } from 'zod'

const CreateProjectSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().optional(),
})

export async function GET() {
  const supabase = await createClient()
  
  const { data, error } = await supabase
    .from('projects')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
  
  return NextResponse.json(data)
}

export async function POST(request: Request) {
  const supabase = await createClient()
  const body = await request.json()
  
  const parsed = CreateProjectSchema.safeParse(body)
  if (!parsed.success) {
    return NextResponse.json(
      { error: 'Validation failed', details: parsed.error.flatten() },
      { status: 400 }
    )
  }
  
  const { data, error } = await supabase
    .from('projects')
    .insert(parsed.data)
    .select()
    .single()
  
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
  
  return NextResponse.json(data, { status: 201 })
}
```

### 3. Server Actions (SOLO para mutaciones simples con UX acoplada)

```typescript
// app/actions/project.ts
'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
})

export async function createProject(formData: FormData) {
  const supabase = await createClient()
  
  const parsed = schema.safeParse({
    name: formData.get('name'),
  })
  
  if (!parsed.success) {
    return { error: 'Invalid data' }
  }
  
  const { error } = await supabase
    .from('projects')
    .insert(parsed.data)
  
  if (error) {
    return { error: error.message }
  }
  
  revalidatePath('/dashboard')
  return { success: true }
}
```

---

## Estructura de Proyecto

```
nexthorizont-app/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── projects/
│   │       ├── page.tsx
│   │       ├── [id]/page.tsx
│   │       └── new/page.tsx
│   ├── api/
│   │   ├── projects/
│   │   │   ├── route.ts
│   │   │   └── [id]/route.ts
│   │   └── webhooks/
│   │       └── stripe/route.ts
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── ui/                    # shadcn/ui components
│   ├── forms/                 # Form components
│   ├── layouts/               # Layout components
│   └── features/              # Feature-specific components
├── lib/
│   ├── supabase/
│   │   ├── client.ts          # Browser client
│   │   ├── server.ts          # Server client
│   │   ├── middleware.ts      # Auth middleware
│   │   └── types.ts           # Generated types
│   ├── utils/
│   │   ├── cn.ts              # classnames helper
│   │   └── format.ts          # Formatting utilities
│   └── validations/
│       └── schemas.ts         # Zod schemas
├── hooks/
│   └── use-projects.ts        # Custom hooks
├── types/
│   ├── database.ts            # Supabase generated types
│   └── index.ts               # App types
├── middleware.ts              # Next.js middleware
└── supabase/
    ├── migrations/            # SQL migrations
    └── seed.sql               # Seed data
```

---

## Configuración Supabase

### Cliente del Servidor

```typescript
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '@/types/database'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // Server Component - ignore
          }
        },
      },
    }
  )
}
```

### Cliente del Browser

```typescript
// lib/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Middleware de Auth

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()

  // Rutas protegidas
  if (!user && request.nextUrl.pathname.startsWith('/dashboard')) {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

---

## TypeScript Estricto

### Reglas NO NEGOCIABLES

```typescript
// ❌ PROHIBIDO - NUNCA usar any
const data: any = await fetch('/api/data')
function process(input: any): any { }

// ✅ CORRECTO - Tipos específicos siempre
interface Project {
  id: string
  name: string
  status: 'active' | 'archived' | 'draft'
  createdAt: Date
}

const data: Project[] = await fetch('/api/data').then(r => r.json())

function process<T extends Record<string, unknown>>(input: T): T {
  return input
}
```

### tsconfig.json Recomendado

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true
  }
}
```

---

## Componentes UI con shadcn/ui

### Instalación Base

```bash
npx shadcn@latest init
npx shadcn@latest add button card form input table dialog
```

### Patrón de Componente

```typescript
// components/features/project-card.tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import type { Project } from '@/types'

interface ProjectCardProps {
  project: Project
  onSelect?: (id: string) => void
}

export function ProjectCard({ project, onSelect }: ProjectCardProps) {
  const statusColors = {
    active: 'bg-green-500',
    archived: 'bg-gray-500',
    draft: 'bg-yellow-500',
  } as const

  return (
    <Card 
      className="cursor-pointer hover:shadow-md transition-shadow"
      onClick={() => onSelect?.(project.id)}
    >
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">{project.name}</CardTitle>
          <Badge className={statusColors[project.status]}>
            {project.status}
          </Badge>
        </div>
      </CardHeader>
      <CardContent>
        <p className="text-sm text-muted-foreground">
          Created {project.createdAt.toLocaleDateString()}
        </p>
      </CardContent>
    </Card>
  )
}
```

---

## Manejo de Errores

### Error Boundaries

```typescript
// app/dashboard/error.tsx
'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error(error)
  }, [error])

  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] gap-4">
      <h2 className="text-xl font-semibold">Algo salió mal</h2>
      <p className="text-muted-foreground">{error.message}</p>
      <Button onClick={reset}>Intentar de nuevo</Button>
    </div>
  )
}
```

### Loading States

```typescript
// app/dashboard/loading.tsx
import { Skeleton } from '@/components/ui/skeleton'

export default function Loading() {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {Array.from({ length: 6 }).map((_, i) => (
        <Skeleton key={i} className="h-32 w-full" />
      ))}
    </div>
  )
}
```

---

## Validación con Zod

```typescript
// lib/validations/schemas.ts
import { z } from 'zod'

export const ProjectSchema = z.object({
  name: z.string()
    .min(1, 'El nombre es requerido')
    .max(100, 'Máximo 100 caracteres'),
  description: z.string().max(500).optional(),
  status: z.enum(['active', 'archived', 'draft']).default('draft'),
})

export const PaginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})

export type Project = z.infer<typeof ProjectSchema>
export type Pagination = z.infer<typeof PaginationSchema>
```

---

## Testing

### Vitest Config

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    include: ['**/*.test.{ts,tsx}'],
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './'),
    },
  },
})
```

### Test de Componente

```typescript
// components/features/__tests__/project-card.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import { ProjectCard } from '../project-card'

describe('ProjectCard', () => {
  const mockProject = {
    id: '1',
    name: 'Test Project',
    status: 'active' as const,
    createdAt: new Date('2025-01-01'),
  }

  it('renders project name', () => {
    render(<ProjectCard project={mockProject} />)
    expect(screen.getByText('Test Project')).toBeInTheDocument()
  })

  it('calls onSelect when clicked', () => {
    const onSelect = vi.fn()
    render(<ProjectCard project={mockProject} onSelect={onSelect} />)
    
    fireEvent.click(screen.getByRole('article'))
    expect(onSelect).toHaveBeenCalledWith('1')
  })
})
```

---

## Checklist Pre-Deploy

- [ ] TypeScript: `npx tsc --noEmit` sin errores
- [ ] Lint: `npx eslint . --ext .ts,.tsx` sin errores
- [ ] Tests: `npm run test` pasando
- [ ] Build: `npm run build` exitoso
- [ ] Variables de entorno configuradas en Vercel
- [ ] RLS policies activas en Supabase
- [ ] Migrations aplicadas en producción

---

## DO NOT

- ❌ Usar `any` - siempre tipos específicos
- ❌ Fetch en Client Components para datos iniciales - usar Server Components
- ❌ `getServerSideProps` o `getStaticProps` - son de Pages Router
- ❌ Guardar secretos en código - usar variables de entorno
- ❌ Desactivar RLS en Supabase - siempre políticas activas
- ❌ Console.log en producción - usar logger estructurado
- ❌ Exponer errores de DB al cliente - mensajes genéricos
