---
name: optimize-performance
description: >
  Analiza y optimiza el rendimiento de una página, componente,
  o query específica. Genera código optimizado listo para reemplazar.
---

Analiza el rendimiento del elemento especificado y genera una versión optimizada.

## Áreas de optimización:

### Next.js
- Convertir Client Components innecesarios a Server Components
- Añadir `Suspense` boundaries con fallbacks
- Implementar streaming con `loading.tsx`
- Usar `dynamic()` para lazy loading de componentes pesados
- Configurar `revalidate` para ISR donde aplique
- Optimizar imágenes con `next/image`
- Reducir JavaScript del bundle (tree-shaking, code splitting)

### Supabase Queries
- Eliminar N+1 queries (usar joins: `.select('*, relation(*)')`)
- Añadir índices faltantes
- Usar `.range()` para paginación eficiente
- Implementar cursor-based pagination para datasets grandes
- Añadir `count: 'exact'` solo cuando se necesita el total
- Usar `.abortSignal()` para cancelar queries en cleanup

### React
- Memoización con `React.memo` solo donde hay re-renders medibles
- `useMemo` y `useCallback` solo cuando el profiler lo justifica
- Virtualización de listas largas (react-window o @tanstack/virtual)
- Debounce en inputs de búsqueda

### Database
- Queries EXPLAIN ANALYZE para identificar seq scans
- Índices parciales para filtros frecuentes
- Materialied views para queries complejas frecuentes
- Connection pooling verificado

## Elemento a optimizar:
$ARGUMENTS
