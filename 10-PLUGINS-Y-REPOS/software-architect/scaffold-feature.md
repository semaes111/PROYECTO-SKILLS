---
name: scaffold-feature
description: >
  Genera la estructura completa de una nueva feature siguiendo
  los patrones arquitectónicos del proyecto. Crea todos los archivos
  necesarios: página, componentes, actions, validaciones, y tipos.
---

Genera toda la estructura de archivos necesaria para implementar una nueva feature en el proyecto. Sigue el patrón arquitectónico canónico.

## Archivos a generar (adaptar según la feature):

### 1. Página (Server Component)
```
app/(auth)/[feature]/page.tsx
app/(auth)/[feature]/loading.tsx
app/(auth)/[feature]/error.tsx
app/(auth)/[feature]/[id]/page.tsx        (si hay detalle)
```

### 2. Componentes
```
components/features/[feature]/[feature]-list.tsx
components/features/[feature]/[feature]-card.tsx
components/features/[feature]/[feature]-form.tsx
components/features/[feature]/[feature]-filters.tsx  (si aplica)
```

### 3. Server Actions
```
lib/actions/[feature].ts
```

### 4. Validaciones Zod
```
lib/validations/[feature].ts
```

### 5. Types
```
types/[feature].ts   (o actualizar types/index.ts)
```

### 6. Repository (opcional, para features complejas)
```
lib/repositories/[feature].ts
```

## Reglas:
- Páginas son Server Components (NO "use client")
- Forms usan Server Actions con `useActionState`
- Validación con Zod antes de cualquier operación de DB
- Tipos inferidos de Zod (`z.infer<>`) y de Supabase gen types
- Componentes interactivos son los únicos con "use client"
- Error boundaries en cada ruta
- Loading states con Suspense

## Feature a implementar:
$ARGUMENTS
