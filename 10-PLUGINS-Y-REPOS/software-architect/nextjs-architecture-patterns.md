---
name: nextjs-architecture-patterns
description: >
  Patrones de arquitectura Next.js 15 para aplicaciones de producción.
  Se activa automáticamente cuando el usuario discute estructura de proyecto,
  rutas, componentes, data fetching, o decisiones de arquitectura.
  Stack principal: Next.js 15 + Supabase + TypeScript + Vercel.
---

## Principios Arquitectónicos Fundamentales

### Jerarquía de Patrones de Data Fetching (orden de prioridad)

1. **Server Components + "use server" + acceso directo a DB** → Patrón por defecto ganador
   - Usar `createClient()` server-side para queries directas a Supabase
   - Sin API intermedia = menor latencia, menor complejidad
   - Ejemplo:
     ```tsx
     // app/dashboard/page.tsx (Server Component por defecto)
     import { createClient } from '@/lib/supabase/server'
     
     export default async function DashboardPage() {
       const supabase = await createClient()
       const { data: projects } = await supabase
         .from('projects')
         .select('id, name, status, created_at')
         .order('created_at', { ascending: false })
       
       return <ProjectList projects={projects ?? []} />
     }
     ```

2. **Route Handlers (API Routes)** → Cuando necesitas endpoints reutilizables, testing robusto, o alta seguridad
   - Para webhooks, integraciones externas, endpoints consumidos por múltiples clientes
   - Ejemplo:
     ```tsx
     // app/api/projects/route.ts
     import { createClient } from '@/lib/supabase/server'
     import { NextResponse } from 'next/server'
     import { z } from 'zod'
     
     const CreateProjectSchema = z.object({
       name: z.string().min(1).max(100),
       description: z.string().optional(),
     })
     
     export async function POST(request: Request) {
       const supabase = await createClient()
       const body = await request.json()
       const parsed = CreateProjectSchema.safeParse(body)
       
       if (!parsed.success) {
         return NextResponse.json(
           { error: parsed.error.flatten() },
           { status: 400 }
         )
       }
       
       const { data, error } = await supabase
         .from('projects')
         .insert(parsed.data)
         .select()
         .single()
       
       if (error) return NextResponse.json({ error: error.message }, { status: 500 })
       return NextResponse.json(data, { status: 201 })
     }
     ```

3. **Server Actions** → Solo para mutaciones simples con UX acoplado al componente
   - Formularios con `useActionState`, toggles, operaciones CRUD básicas
   - NUNCA para lógica de negocio compleja

4. **Client fetching** → Solo para datos públicos no sensibles + caching agresivo
   - O usar RSC + `force-dynamic` cuando sea estrictamente necesario

### TypeScript Estricto — Reglas Inquebrantables

- **`any` está PROHIBIDO** — No existe en código mantenible
- Siempre tipos específicos: interfaces para objetos de dominio, `z.infer<>` para schemas
- Generics antes que casteos
- `satisfies` para validación de tipos en tiempo de compilación
- `as const` para literales inmutables

### Estructura de Proyecto Canónica

```
src/
├── app/                          # App Router (Next.js 15)
│   ├── (auth)/                   # Grupo: rutas autenticadas
│   │   ├── dashboard/
│   │   ├── settings/
│   │   └── layout.tsx            # Layout con auth check
│   ├── (public)/                 # Grupo: rutas públicas
│   │   ├── login/
│   │   ├── register/
│   │   └── layout.tsx
│   ├── (marketing)/              # Grupo: landing pages
│   │   ├── page.tsx              # Homepage
│   │   └── pricing/
│   ├── api/                      # Route Handlers
│   │   ├── webhooks/
│   │   └── v1/
│   ├── layout.tsx                # Root layout
│   ├── error.tsx                 # Error boundary global
│   ├── not-found.tsx
│   └── loading.tsx
├── components/
│   ├── ui/                       # Componentes atómicos (shadcn/ui)
│   ├── forms/                    # Formularios reutilizables
│   ├── layouts/                  # Headers, sidebars, footers
│   └── features/                 # Componentes de dominio
│       ├── projects/
│       ├── patients/
│       └── billing/
├── lib/
│   ├── supabase/
│   │   ├── client.ts             # Browser client
│   │   ├── server.ts             # Server client
│   │   ├── middleware.ts          # Auth middleware helper
│   │   └── admin.ts              # Service role client (server only)
│   ├── actions/                  # Server Actions agrupadas por dominio
│   │   ├── projects.ts
│   │   └── patients.ts
│   ├── validations/              # Schemas Zod
│   │   ├── project.ts
│   │   └── patient.ts
│   └── utils/
│       ├── cn.ts                 # clsx + tailwind-merge
│       ├── format.ts
│       └── constants.ts
├── types/                        # TypeScript types globales
│   ├── database.ts               # Types generados por Supabase CLI
│   ├── api.ts
│   └── index.ts
├── hooks/                        # Custom hooks (client-side)
├── middleware.ts                  # Next.js middleware (auth redirect)
└── env.ts                        # Validación de env vars con zod
```

### Supabase — Reglas de Arquitectura

- **RLS siempre activo** en TODAS las tablas sin excepción
- Migraciones versionadas y atómicas
- Edge Functions para lógica serverless que no encaja en Route Handlers
- Realtime solo cuando hay necesidad real de datos en vivo (chat, dashboards live)
- `supabase gen types typescript` después de cada migración
- Service role SOLO en server-side, NUNCA expuesto al cliente

### Vercel — Configuración de Producción

- Preview deployments para cada PR
- Environment variables por entorno (preview/production)
- Edge Middleware para geolocalización y A/B testing
- ISR (Incremental Static Regeneration) para páginas semi-estáticas
- `next/image` con loader de Vercel para optimización automática
