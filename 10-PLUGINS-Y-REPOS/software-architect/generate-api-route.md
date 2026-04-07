---
name: generate-api-route
description: >
  Genera un Route Handler (API route) completo y seguro para Next.js 15.
  Incluye autenticación, validación Zod, manejo de errores, y tipado estricto.
---

Genera un Route Handler seguro y completo siguiendo este patrón:

## Estructura del Route Handler:

```typescript
// app/api/v1/[resource]/route.ts
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import { z } from 'zod'

// 1. Schema de validación
const RequestSchema = z.object({ ... })

// 2. Helper de respuesta tipada
function jsonResponse<T>(data: T, status = 200) {
  return NextResponse.json(data, { status })
}

function errorResponse(message: string, status = 400) {
  return NextResponse.json({ error: message }, { status })
}

// 3. GET - Listar/obtener
export async function GET(request: Request) {
  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) return errorResponse('Unauthorized', 401)
  
  // Query params
  const { searchParams } = new URL(request.url)
  const page = Number(searchParams.get('page') ?? '1')
  const limit = Number(searchParams.get('limit') ?? '20')
  
  const { data, error, count } = await supabase
    .from('resource')
    .select('*', { count: 'exact' })
    .eq('user_id', user.id)
    .range((page - 1) * limit, page * limit - 1)
    .order('created_at', { ascending: false })
  
  if (error) return errorResponse(error.message, 500)
  
  return jsonResponse({
    data,
    pagination: { page, limit, total: count ?? 0 }
  })
}

// 4. POST - Crear
export async function POST(request: Request) {
  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) return errorResponse('Unauthorized', 401)
  
  const body = await request.json()
  const parsed = RequestSchema.safeParse(body)
  if (!parsed.success) {
    return errorResponse(parsed.error.issues[0].message, 422)
  }
  
  const { data, error } = await supabase
    .from('resource')
    .insert({ ...parsed.data, user_id: user.id })
    .select()
    .single()
  
  if (error) return errorResponse(error.message, 500)
  return jsonResponse(data, 201)
}
```

## Requisitos:
- Autenticación verificada en CADA método
- Validación Zod en POST/PUT/PATCH
- Paginación en GET de listas
- Códigos HTTP correctos (200, 201, 400, 401, 404, 422, 500)
- Tipado estricto sin `any`
- Cache headers donde aplique

## API route a generar:
$ARGUMENTS
