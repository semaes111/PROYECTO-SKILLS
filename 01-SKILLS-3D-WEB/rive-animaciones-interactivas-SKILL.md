---
name: rive-animaciones-interactivas
description: >
  Rive — animaciones interactivas con state machines para UI/motion branding.
  Archivos .riv ultra-ligeros, state machines con triggers/booleans/numbers.
  useRive() hook para React, eventos, layout responsivo.
  Usar cuando: Rive, animacion interactiva, state machine animacion,
  motion branding, animacion UI estados, Lottie alternativa.
triggers:
  - "Rive"
  - "animacion interactiva"
  - "state machine animacion"
  - "motion branding"
  - "animacion con estados"
type: reference
---

# Rive — Animaciones Interactivas con State Machines

## Que Es

Rive es un motor de animaciones interactivas con state machines.
A diferencia de Lottie (solo reproduccion lineal), Rive permite
animaciones que reaccionan a inputs del usuario en tiempo real.

**Sitio**: rive.app | **Runtime ultra-ligero** | **State machines integradas**

## Instalacion

```bash
npm install @rive-app/react-canvas
# o para vanilla JS:
npm install @rive-app/canvas
```

## Setup React — Basico

```tsx
import { useRive } from '@rive-app/react-canvas'

export function AnimatedIcon() {
  const { RiveComponent } = useRive({
    src: '/animations/icon.riv',     // Archivo .riv
    stateMachines: 'State Machine 1', // Nombre de la state machine
    autoplay: true,
  })

  return <RiveComponent style={{ width: 200, height: 200 }} />
}
```

## State Machines — El Poder de Rive

Las state machines permiten que la animacion reaccione a inputs:

```tsx
import { useRive, useStateMachineInput } from '@rive-app/react-canvas'

export function InteractiveButton() {
  const { rive, RiveComponent } = useRive({
    src: '/animations/button.riv',
    stateMachines: 'Button State Machine',
    autoplay: true,
  })

  // Tipos de input:
  // - Trigger: se dispara una vez (click, tap)
  // - Boolean: on/off (hover, active, disabled)
  // - Number: valor numerico (progress, level)

  const hoverInput = useStateMachineInput(rive, 'Button State Machine', 'isHovering')
  const clickInput = useStateMachineInput(rive, 'Button State Machine', 'onClick')
  const progressInput = useStateMachineInput(rive, 'Button State Machine', 'progress')

  return (
    <RiveComponent
      style={{ width: 300, height: 80, cursor: 'pointer' }}
      onMouseEnter={() => { if (hoverInput) hoverInput.value = true }}
      onMouseLeave={() => { if (hoverInput) hoverInput.value = false }}
      onClick={() => { if (clickInput) clickInput.fire() }}  // Trigger
      onScroll={(e) => {
        if (progressInput) progressInput.value = e.target.scrollTop / 1000
      }}
    />
  )
}
```

## Tipos de Input

```typescript
// TRIGGER — se dispara una vez, sin valor
const clickTrigger = useStateMachineInput(rive, 'SM', 'onClick')
clickTrigger.fire()  // Dispara el trigger

// BOOLEAN — on/off
const isHovering = useStateMachineInput(rive, 'SM', 'isHovering')
isHovering.value = true   // Activa
isHovering.value = false  // Desactiva

// NUMBER — valor numerico continuo
const progress = useStateMachineInput(rive, 'SM', 'progress')
progress.value = 0.5  // Valor entre el rango definido en Rive
```

## Layout y Fit

```tsx
import { useRive, Layout, Fit, Alignment } from '@rive-app/react-canvas'

const { RiveComponent } = useRive({
  src: '/animation.riv',
  stateMachines: 'SM',
  layout: new Layout({
    fit: Fit.Cover,        // Cover | Contain | Fill | FitWidth | FitHeight | None | ScaleDown
    alignment: Alignment.Center, // Center | TopLeft | TopCenter | TopRight | etc.
  }),
  autoplay: true,
})
```

## Eventos y Listeners

```tsx
import { useRive, EventType } from '@rive-app/react-canvas'

const { rive, RiveComponent } = useRive({
  src: '/animation.riv',
  stateMachines: 'SM',
  autoplay: true,
  onStateChange: (event) => {
    // Se dispara cuando cambia de estado en la state machine
    console.log('State changed:', event.data)
  },
})

// Listener manual
useEffect(() => {
  if (!rive) return

  const handler = (event) => {
    console.log('Rive event:', event)
  }

  rive.on(EventType.StateChange, handler)
  return () => rive.off(EventType.StateChange, handler)
}, [rive])
```

## Patron: Boton Animado Completo

```tsx
import { useRive, useStateMachineInput, Layout, Fit } from '@rive-app/react-canvas'

export function AnimatedCTA({ onClick, label }: { onClick: () => void; label: string }) {
  const { rive, RiveComponent } = useRive({
    src: '/animations/cta-button.riv',
    stateMachines: 'Button',
    layout: new Layout({ fit: Fit.Cover }),
    autoplay: true,
  })

  const hover = useStateMachineInput(rive, 'Button', 'isHover')
  const press = useStateMachineInput(rive, 'Button', 'isPressed')
  const success = useStateMachineInput(rive, 'Button', 'onSuccess')

  const handleClick = async () => {
    if (press) press.value = true
    await onClick()
    if (success) success.fire()
    setTimeout(() => { if (press) press.value = false }, 300)
  }

  return (
    <div style={{ position: 'relative', width: 280, height: 64 }}>
      <RiveComponent
        style={{ width: '100%', height: '100%' }}
        onMouseEnter={() => hover && (hover.value = true)}
        onMouseLeave={() => { hover && (hover.value = false); press && (press.value = false) }}
        onClick={handleClick}
      />
      <span style={{
        position: 'absolute', inset: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: 'white', fontWeight: 700, pointerEvents: 'none',
      }}>
        {label}
      </span>
    </div>
  )
}
```

## Patron: Loading Animado con Progreso

```tsx
export function AnimatedLoader({ progress }: { progress: number }) {
  const { rive, RiveComponent } = useRive({
    src: '/animations/loader.riv',
    stateMachines: 'Loader',
    autoplay: true,
  })

  const progressInput = useStateMachineInput(rive, 'Loader', 'progress')
  const completeInput = useStateMachineInput(rive, 'Loader', 'onComplete')

  useEffect(() => {
    if (progressInput) progressInput.value = progress
    if (progress >= 100 && completeInput) completeInput.fire()
  }, [progress])

  return <RiveComponent style={{ width: 120, height: 120 }} />
}
```

## Performance

- Archivos .riv son 10-50x mas pequenos que Lottie JSON
- Runtime renderiza en Canvas 2D (ligero) o WebGL (potente)
- State machines se ejecutan en el runtime, no en JS
- Lazy load: `import('@rive-app/react-canvas')` con dynamic import

## Rive vs Lottie

| Feature | Rive | Lottie |
|---------|------|--------|
| Interactividad | State machines | Solo play/pause |
| Tamano archivo | Muy pequeno (.riv binario) | Grande (JSON) |
| Inputs de usuario | Triggers, booleans, numbers | No |
| Rendimiento | Canvas/WebGL optimizado | Canvas basico |
| Editor | rive.app (gratuito) | After Effects ($$$) |
| React hooks | useRive, useStateMachineInput | useLottie |
