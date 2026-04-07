---
name: wizard
description: >
  Metodología de ingeniería senior de 8 fases para Claude Code. Transforma a Claude
  de "coder rápido" a "arquitecto metódico": planifica antes de tocar código, explora
  antes de asumir, TDD estricto con assertions mutation-resistant, revisión adversarial
  y ciclo de quality gate. Activar con /wizard en Claude Code CLI.
triggers:
  - "/wizard"
  - "usa el wizard"
  - "modo senior"
  - "revisa como senior"
  - "metodología completa"
type: workflow
---

# /wizard — Metodología de Ingeniería Senior (8 Fases)

> **Principio fundamental:** Un junior lee el ticket y empieza a escribir.
> Un senior lee el ticket, lee el código alrededor, lee los tests, revisa el git history,
> y **entonces** empieza a escribir. Es más lento para arrancar, más rápido para terminar.
> Esta skill convierte a Claude en el segundo tipo.

---

## 🎯 Cuándo activar /wizard

Activar en **cualquier tarea que implique modificar código de producción**:

| Tarea | ¿Usar wizard? |
|-------|---------------|
| Nueva feature desde un issue | ✅ Siempre |
| Bug fix en código crítico | ✅ Siempre |
| Refactor de módulo existente | ✅ Siempre |
| Fix urgente de producción | ✅ Especialmente |
| Snippet rápido desechable | ❌ No necesario |
| Exploración / prototipo | ❌ Opcional |

---

## FASE 1 — Planificación (Plan Before You Touch Anything)

**Objetivo:** Construir un todo list estructurado ANTES de escribir una sola línea de código.

### 1.1 Inputs requeridos

```
□ CLAUDE.md del proyecto (convenciones, stack, comandos)
□ Issue/ticket con descripción del problema
□ Feature branch limpio creado
```

### 1.2 Proceso

**Paso 1 — Leer CLAUDE.md completo**
Identificar y anotar:
- Stack tecnológico exacto y versiones
- Comandos de test, lint, build
- Convenciones de código (naming, estructura de carpetas)
- Patrones preferidos del proyecto

**Paso 2 — Leer el issue/ticket**
Identificar:
- Qué se pide exactamente (no asumir)
- Criterios de aceptación explícitos
- Casos edge mencionados
- Dependencias con otros sistemas

**Paso 3 — Evaluar complejidad** (elegir uno):

```
SIMPLE   → 1-3 archivos, sin impacto arquitectural, bajo riesgo
MEDIUM   → 4-6 archivos, impacto moderado, riesgo controlado
COMPLEX  → 7+ archivos, impacto arquitectural, alto riesgo
```

**Paso 4 — Construir TODO list**

```markdown
## Plan de Implementación

**Complejidad:** [SIMPLE|MEDIUM|COMPLEX]
**Archivos estimados:** N
**Riesgo:** [Bajo|Medio|Alto]

### TODOs (en orden de ejecución)
- [ ] [FASE 2] Verificar existencia de: modelo X, relación Y, constante Z
- [ ] [FASE 3] Escribir tests para: caso A, caso B, edge case C
- [ ] [FASE 4] Implementar: servicio X, handler Y, componente Z
- [ ] [FASE 5] Ejecutar suite completa, verificar 0 regresiones
- [ ] [FASE 6] Documentar: comentarios inline, CHANGELOG
- [ ] [FASE 7] Revisión adversarial: concurrencia, nulls, asunciones
- [ ] [FASE 8] PR + quality gate cycle
```

> ⚠️ **No avanzar a Fase 2 sin el TODO list aprobado.**

---

## FASE 2 — Exploración (Explore Before You Assume)

**Objetivo:** Verificar que todo lo que se va a usar **realmente existe** en el codebase antes de construir sobre ello.

### 2.1 La regla de oro

> Claude puede llamar con completa convicción a `user.clientProfile.accounts` — una cadena de relaciones que se inventó. Esta fase existe para prevenir exactamente eso.

### 2.2 Checklist de verificación

Para cada modelo, método, tipo, constante o relación que se planea usar:

```bash
# Verificar existencia de tipos/interfaces
grep -r "interface UserProfile" src/
grep -r "type TransferStatus" src/

# Verificar exports de módulos
grep -r "export.*createTransfer" src/
grep -r "export.*VALID_TRANSITIONS" src/

# Verificar relaciones en schema de DB (Supabase)
grep -r "references" supabase/migrations/
grep -r "foreign key" supabase/migrations/

# Verificar rutas de API existentes
grep -r "route\|app.get\|app.post" src/app/api/

# Verificar nombres exactos de columnas
cat supabase/migrations/[relevant_migration].sql
```

### 2.3 Mapa de dependencias

Antes de implementar, construir este mapa:

```
ENTIDADES A USAR:
├── [Model/Type] UserProfile          → ✅ Existe en src/types/user.ts:23
├── [Enum] TransferStatus             → ✅ Existe en src/constants/transfer.ts:5
├── [Function] processTransfer()      → ✅ Existe en src/services/transfer.ts:67
├── [DB Table] transfer_requests      → ✅ Existe en migration 20240115_transfers.sql
├── [API Route] /api/transfers/[id]   → ✅ Existe en src/app/api/transfers/[id]/route.ts
└── [Component] TransferStatusBadge  → ❌ NO EXISTE — crear en Fase 4
```

> ✅ = verificado con grep  
> ❌ = necesita crearse (documentar en TODO list)

### 2.4 Señales de alerta

Si encuentras alguno de estos, **PARAR y reevaluar el plan**:

- Un modelo que no existe pero el issue asume que sí
- Una migración de DB que renombró una columna (buscar en git history)
- Una función deprecada que aún aparece en el código con otro nombre
- Tipos que no coinciden con lo que el issue describe

---

## FASE 3 — TDD (Write Tests First — Siempre)

**Objetivo:** Tests que fallen primero, luego código que los pase. En ese orden. Sin excepciones.

### 3.1 Secuencia obligatoria

```
1. Escribir tests (deben fallar al ejecutar)
2. Ejecutar tests → CONFIRMAR que fallan
3. Implementar código mínimo (Fase 4)
4. Ejecutar tests → CONFIRMAR que pasan
5. Refactor si es necesario → tests siguen pasando
```

### 3.2 Mutation-resistant assertions

**El problema con assertions débiles:**

```typescript
// ❌ MAL — Pasa aunque el código no haga nada útil
expect(result).toBeTruthy()
expect(result).toBeDefined()
expect(() => processTransfer()).not.toThrow()

// ✅ BIEN — Falla si el efecto exacto no ocurrió
expect(result.status).toBe('completed')
expect(result.completedAt).toBeInstanceOf(Date)
expect(result.notificationSent).toBe(true)
expect(auditLog.action).toBe('TRANSFER_COMPLETED')
expect(auditLog.userId).toBe(testUser.id)
```

**Regla:** Cada test debe verificar **efectos concretos**, no solo que "no explotó".

### 3.3 Estructura de test suite

```typescript
// Ejemplo: Transfer Status Service
describe('TransferStatusService', () => {

  // GRUPO 1: Happy path — flujo principal
  describe('processTransition()', () => {
    it('debe cambiar status de pending a processing', async () => {
      const transfer = await createTestTransfer({ status: 'pending' })
      const result = await service.processTransition(transfer.id, 'processing')
      
      expect(result.status).toBe('processing')
      expect(result.updatedAt).toBeInstanceOf(Date)
      expect(result.processedBy).toBe(testUser.id)
    })
  })

  // GRUPO 2: Side effects — efectos secundarios que DEBEN ocurrir
  describe('side effects', () => {
    it('debe crear audit log al cambiar status', async () => {
      await service.processTransition(transfer.id, 'processing')
      
      const log = await getAuditLog(transfer.id)
      expect(log.action).toBe('STATUS_TRANSITION')
      expect(log.fromStatus).toBe('pending')
      expect(log.toStatus).toBe('processing')
      expect(log.timestamp).toBeInstanceOf(Date)
    })

    it('debe enviar notificación al cliente', async () => {
      const spy = vi.spyOn(notificationService, 'send')
      await service.processTransition(transfer.id, 'completed')
      
      expect(spy).toHaveBeenCalledOnce()
      expect(spy).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: transfer.clientId,
          type: 'TRANSFER_COMPLETED',
          // No strings hardcodeadas — usar enums
          category: NotificationCategory.TRANSFER
        })
      )
    })
  })

  // GRUPO 3: Edge cases — los que producen bugs en producción
  describe('edge cases', () => {
    it('debe rechazar transición inválida', async () => {
      const transfer = await createTestTransfer({ status: 'completed' })
      
      await expect(
        service.processTransition(transfer.id, 'pending')
      ).rejects.toThrow(InvalidTransitionError)
    })

    it('debe manejar transfer con initiated_at null', async () => {
      const transfer = await createTestTransfer({ initiatedAt: null })
      
      // No debe crashear
      const result = await service.getDisplayData(transfer.id)
      expect(result.initiatedAtFormatted).toBeNull()
    })

    it('debe ser idempotente bajo llamadas concurrentes', async () => {
      const transfer = await createTestTransfer({ status: 'pending' })
      
      // Simular 2 requests concurrentes
      const [result1, result2] = await Promise.all([
        service.processTransition(transfer.id, 'processing'),
        service.processTransition(transfer.id, 'processing')
      ])
      
      // Solo uno debe tener éxito — el otro debe fallar limpiamente
      const results = [result1, result2]
      expect(results.filter(r => r.status === 'processing')).toHaveLength(1)
    })
  })
})
```

### 3.4 Comando de ejecución

```bash
# Next.js/Vitest (stack NextHorizont)
npx vitest run --reporter=verbose

# Ver que los tests FALLAN antes de implementar
npx vitest run src/__tests__/transfer-service.test.ts
# Expected: X tests failed — si pasan, algo está mal con el test
```

---

## FASE 4 — Implementación Mínima (Implement The Minimum)

**Objetivo:** El mínimo código para pasar los tests de Fase 3. Nada más.

### 4.1 Reglas de implementación

```
✅ Implementar exactamente lo que los tests requieren
✅ Usar los tipos/enums del mapa de dependencias (Fase 2)
✅ Seguir patrones de CLAUDE.md
❌ No implementar "por si acaso" lo necesitamos después
❌ No abstracciones prematuras
❌ No features no cubiertas por tests
❌ No usar `any` en TypeScript — NUNCA
```

### 4.2 Pattern de Server Component (stack NextHorizont)

```typescript
// ✅ Patrón preferido: Server Component + direct DB access
// src/app/transfers/[id]/page.tsx

import { createClient } from '@/lib/supabase/server'
import { TransferStatusBadge } from '@/components/TransferStatusBadge'
import type { Transfer } from '@/types/transfer'

// Directo a DB — sin API route intermedia para datos del servidor
async function getTransfer(id: string): Promise<Transfer | null> {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('transfers')
    .select('*, client:profiles(*)')
    .eq('id', id)
    .single()
  
  if (error) return null
  return data
}

export default async function TransferPage({ params }: { params: { id: string } }) {
  const transfer = await getTransfer(params.id)
  if (!transfer) notFound()
  
  return <TransferStatusBadge transfer={transfer} />
}
```

### 4.3 Locking para operaciones concurrentes

```typescript
// ✅ Siempre usar locking en transiciones de estado críticas
// src/services/transfer-status.service.ts

import { createClient } from '@/lib/supabase/server'
import type { TransferStatus } from '@/types/transfer'

export async function processTransition(
  transferId: string,
  newStatus: TransferStatus
): Promise<Transfer> {
  const supabase = await createClient()
  
  // Transacción atómica con locking optimista via RLS + check
  const { data, error } = await supabase.rpc('process_transfer_transition', {
    p_transfer_id: transferId,
    p_new_status: newStatus,
    p_user_id: (await supabase.auth.getUser()).data.user?.id
  })
  
  if (error) throw new TransitionError(error.message)
  return data
}
```

```sql
-- supabase/functions/process_transfer_transition.sql
-- La lógica de locking va aquí, en la DB, donde es atómica por naturaleza
CREATE OR REPLACE FUNCTION process_transfer_transition(
  p_transfer_id UUID,
  p_new_status transfer_status,
  p_user_id UUID
) RETURNS transfers AS $$
DECLARE
  v_transfer transfers;
BEGIN
  -- Lock explícito para prevenir race conditions
  SELECT * INTO v_transfer
  FROM transfers
  WHERE id = p_transfer_id
  FOR UPDATE;  -- ← Este es el lockForUpdate() equivalente
  
  -- Validar transición
  IF NOT is_valid_transition(v_transfer.status, p_new_status) THEN
    RAISE EXCEPTION 'Invalid transition: % → %', v_transfer.status, p_new_status;
  END IF;
  
  -- Aplicar cambio
  UPDATE transfers
  SET status = p_new_status, updated_at = NOW()
  WHERE id = p_transfer_id
  RETURNING * INTO v_transfer;
  
  RETURN v_transfer;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## FASE 5 — Verificación de Regresiones (Verify Nothing Regressed)

**Objetivo:** Confirmar que los cambios no rompieron nada fuera del scope.

### 5.1 Secuencia

```bash
# 1. Tests nuevos — deben pasar 100%
npx vitest run src/__tests__/[nuevo-modulo].test.ts

# 2. Suite relacionada — tests de módulos que interactúan con lo cambiado
npx vitest run src/__tests__/[modulos-relacionados]/

# 3. Suite completa — zero regressions
npx vitest run

# 4. Type checking — especialmente si se cambiaron tipos
npx tsc --noEmit

# 5. Linting
npx eslint src/ --max-warnings=0
```

### 5.2 Criterio de éxito

```
✅ Todos los tests nuevos: PASS
✅ Todos los tests existentes: PASS (0 regresiones)
✅ TypeScript: 0 errores
✅ ESLint: 0 warnings nuevos
```

Si algo falla → **VOLVER a Fase 4** antes de continuar.

---

## FASE 6 — Documentación (Document While Context Is Fresh)

**Objetivo:** Documentar mientras el contexto está vivo. El próximo lector podría ser tú en 3 meses.

### 6.1 Comentarios inline (solo cuando añaden valor)

```typescript
// ❌ Comentario inútil — el código ya lo dice
// Obtener el transfer
const transfer = await getTransfer(id)

// ✅ Comentario que añade WHY, no WHAT
// Lock optimista necesario: múltiples workers pueden procesar
// la misma cola simultáneamente. Sin esto, dos transitions
// concurrentes pueden resultar en estado inválido.
const transfer = await getTransferWithLock(id)

// ✅ Explicación de decisión no obvia
// Usamos RPC en lugar de query directa para mantener
// la lógica de transición en la DB donde puede ser atómica.
// Ver: docs/adr/0003-transfer-transitions-in-db.md
const result = await supabase.rpc('process_transfer_transition', params)
```

### 6.2 CHANGELOG entry

```markdown
## [Unreleased]

### Added
- Transfer status tracking con notificaciones automáticas (#123)
  - Service `TransferStatusService` con locking de concurrencia
  - 5 tipos de notificación (pending, processing, completed, failed, cancelled)
  - Dashboard con badge de estado en tiempo real

### Fixed  
- Crash en páginas con `initiated_at` null (#124)
```

### 6.3 Actualizar documentación de API si aplica

Si se añadió/modificó una Route Handler o RPC de Supabase → actualizar:
- Comentarios JSDoc en la función
- README del módulo si existe
- Tipos exportados en `src/types/`

---

## FASE 7 — Revisión Adversarial (The Adversarial Review)

**Objetivo:** Revisar el propio código NO como el autor, sino como un atacante buscando fallos.

> Esta fase es donde /wizard "gana su sueldo". Sin ella, bugs sutiles llegan a producción.

### 7.1 Checklist adversarial completo

Para **cada función implementada**, responder:

```
CONCURRENCIA
□ ¿Qué pasa si esto se ejecuta 2 veces simultáneamente?
□ ¿Hay race conditions en acceso a recursos compartidos?
□ ¿Las operaciones de DB son atómicas o pueden quedar a medias?
□ ¿Los locks están en el lugar correcto (DB, no app)?

VALORES NULL / VACÍOS / EDGE
□ ¿Qué pasa si el input es null? ¿undefined? ¿string vacío?
□ ¿Qué pasa si el array está vacío? ¿Si tiene un solo elemento?
□ ¿Qué pasa si el número es negativo? ¿Cero? ¿Muy grande?
□ ¿Qué pasa si la fecha es null o en el futuro?
□ ¿Todos los campos opcionales en el tipo tienen manejo explícito?

ASUNCIONES
□ ¿Qué asunciones estoy haciendo que podrían ser falsas en producción?
□ ¿Estoy asumiendo que el usuario existe? ¿Que tiene permisos?
□ ¿Estoy asumiendo un orden específico en los datos?
□ ¿Estoy asumiendo que un servicio externo responde en tiempo?

STRINGS HARDCODEADOS
□ ¿Hay strings que deberían ser enums o constantes?
□ ¿Hay valores mágicos (números, strings) sin nombrar?
□ ¿Los mensajes de error dan información suficiente para debuggear?

SEGURIDAD (RLS / Auth)
□ ¿Las Row Level Security policies cubren este caso?
□ ¿Se valida que el usuario tiene acceso al recurso solicitado?
□ ¿Los datos sensibles se filtran antes de enviar al cliente?
□ ¿Las funciones SECURITY DEFINER son necesarias aquí?

RENDIMIENTO
□ ¿Esta query tiene los índices necesarios?
□ ¿Hay N+1 queries que se pueden eliminar con joins?
□ ¿La operación puede timeout si los datos crecen 10x?

VERGÜENZA TEST
□ ¿Me daría vergüenza si esto falla en producción a las 2am?
□ Si la respuesta es sí → arreglarlo ahora.
```

### 7.2 Bugs reales que esta fase atrapa (ejemplos del artículo)

**Bug 1: Race condition en status transitions**
```typescript
// ❌ Sin locking — 2 requests concurrentes aplican transiciones conflictivas
const transfer = await getTransfer(id)
if (transfer.status === 'pending') {
  await updateStatus(id, 'processing') // Race condition aquí
}

// ✅ Con locking en DB — atómico por naturaleza
await supabase.rpc('process_transfer_transition', { id, newStatus: 'processing' })
```

**Bug 2: NPE en campo nullable**
```typescript
// ❌ Crash si initiated_at es null
return transfer.initiatedAt.toISOString()

// ✅ Null-safe
return transfer.initiatedAt?.toISOString() ?? null
```

**Bug 3: String hardcodeado en lugar de enum**
```typescript
// ❌ String hardcodeado — se desincroniza con el enum
await notify({ category: 'transfer' })

// ✅ Usar el enum que existe
await notify({ category: NotificationCategory.TRANSFER })
```

### 7.3 Documentar hallazgos

Para cada issue encontrado en 7.1:
1. Identificar el bug potencial
2. Evaluar severidad: [CRÍTICO|ALTO|MEDIO|BAJO]
3. Aplicar el fix
4. Añadir test que lo cubra (si no existe)
5. Marcar en el TODO list

---

## FASE 8 — Quality Gate (The PR Lifecycle)

**Objetivo:** Abrir PR, procesar todos los findings del bot de revisión, iterar hasta clean.

### 8.1 Abrir el PR

```bash
# Commit con mensaje descriptivo (Conventional Commits)
git add -A
git commit -m "feat(transfers): add status tracking with notifications (#123)

- TransferStatusService with DB-level locking
- 5 notification types using NotificationCategory enum  
- Null-safe handling for initiated_at field
- 49 tests, 108 assertions"

# Push y abrir PR
git push origin feature/transfer-status-tracking
gh pr create --title "feat: Transfer status tracking with notifications" \
  --body "Closes #123" \
  --draft
```

### 8.2 Ciclo de quality gate

```
REPETIR HASTA QUE BOT = CLEAN:

1. Esperar findings del bot (CodeRabbit, Bug Bot, etc.)
2. Leer CADA finding
3. Para cada finding:
   a. ¿Es válido? → Aplicar fix, run tests, commit
   b. ¿Es falso positivo? → Responder con justificación técnica
4. Push cambios
5. Verificar que el bot procesa el nuevo commit
6. Evaluar nuevo status
```

### 8.3 Responder findings

```
FINDING VÁLIDO → fix:
  "You're right. Applied fix in [commit hash].
   Added test in [test file] to prevent regression."

FALSO POSITIVO → explicar:
  "This is intentional because [technical reason].
   The [X] pattern here is required by [constraint/spec].
   No change needed."
```

### 8.4 Definition of Done

```
✅ Todos los tests pasan (npx vitest run)
✅ TypeScript: 0 errores (npx tsc --noEmit)
✅ Bot de revisión: status CLEAN
✅ PR description actualizada con cambios finales
✅ CHANGELOG actualizado
✅ Draft → Ready for Review
```

---

## 📋 Quick Start (Resumen Ejecutivo)

```
/wizard activado para: [descripción de la tarea]

FASE 1: Leer CLAUDE.md + issue → TODO list con complejidad estimada
FASE 2: grep de todo lo que se usará → verificar existencia real
FASE 3: Escribir tests → ejecutar → CONFIRMAR que fallan
FASE 4: Implementar mínimo → ejecutar → CONFIRMAR que pasan
FASE 5: Suite completa → 0 regresiones, 0 errores TS
FASE 6: Comentarios inline + CHANGELOG
FASE 7: Revisión adversarial → concurrencia, nulls, asunciones, strings
FASE 8: PR → leer findings → fix/justificar → iterar → CLEAN
```

---

## 📚 Referencias

- **[CHECKLISTS.md](CHECKLISTS.md)** — Checklists rápidos por fase para consulta durante ejecución
- **[PATTERNS.md](PATTERNS.md)** — Patrones comunes y anti-patrones con ejemplos TypeScript/Next.js/Supabase
