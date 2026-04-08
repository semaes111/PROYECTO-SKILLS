---
name: theatre-js-timeline-animacion
description: >
  Theatre.js — editor visual de timeline para animaciones 3D/2D con keyframes.
  Control director-level sobre animaciones Three.js y React Three Fiber.
  Editor grafico integrado, exportacion para produccion.
  Usar cuando: timeline de animacion, keyframes visual, Theatre.js,
  animacion 3D con editor, animacion cinematica, motion design 3D.
triggers:
  - "Theatre.js"
  - "timeline de animacion"
  - "keyframes visual"
  - "editor de animacion 3D"
  - "animacion cinematica"
type: reference
---

# Theatre.js — Timeline Visual para Animaciones 3D/2D

## Que Es

Theatre.js es una libreria de motion design con UI grafica para editar
animaciones con keyframes en 3D y 2D. Piensa en After Effects pero para
Three.js/R3F directamente en el navegador.

**GitHub**: github.com/theatre-js/theatre | **12K+ stars**

## Paquetes

```bash
npm install @theatre/core @theatre/studio @theatre/r3f
```

- `@theatre/core`: Motor de animacion (produccion)
- `@theatre/studio`: Editor visual (solo desarrollo)
- `@theatre/r3f`: Extension para React Three Fiber

## Conceptos Clave

```
Project (proyecto)
  └── Sheet (hoja de animacion)
       ├── Object (objeto animable con propiedades)
       │    ├── prop: position.x (number)
       │    ├── prop: color (rgba)
       │    └── prop: visible (boolean)
       └── Sequence (timeline con keyframes)
```

## Setup Basico

```javascript
import { getProject, types } from '@theatre/core'
import studio from '@theatre/studio'

// Solo en desarrollo — NUNCA en produccion
if (process.env.NODE_ENV === 'development') {
  studio.initialize()
}

// Crear proyecto
const project = getProject('Mi Animacion')

// Crear sheet (hoja de animacion)
const sheet = project.sheet('Escena Principal')

// Crear objeto animable con propiedades
const cubeObj = sheet.object('Cubo', {
  position: types.compound({
    x: types.number(0, { range: [-10, 10] }),
    y: types.number(0, { range: [-10, 10] }),
    z: types.number(0, { range: [-10, 10] }),
  }),
  rotation: types.compound({
    x: types.number(0, { range: [-Math.PI, Math.PI] }),
    y: types.number(0, { range: [-Math.PI, Math.PI] }),
  }),
  scale: types.number(1, { range: [0.1, 5] }),
  color: types.rgba({ r: 1, g: 0, b: 0, a: 1 }),
  visible: types.boolean(true),
})

// Escuchar cambios en tiempo real
cubeObj.onValuesChange((values) => {
  cube.position.set(values.position.x, values.position.y, values.position.z)
  cube.rotation.set(values.rotation.x, values.rotation.y, 0)
  cube.scale.setScalar(values.scale)
})
```

## Tipos de Propiedades

```javascript
import { types } from '@theatre/core'

types.number(default, { range: [min, max], nudgeMultiplier: 0.1 })
types.boolean(default)
types.string(default)
types.stringLiteral(default, { option1: 'Option 1', option2: 'Option 2' })
types.rgba({ r: 1, g: 1, b: 1, a: 1 })
types.compound({ x: types.number(0), y: types.number(0) })
types.image('', { label: 'Texture' })
```

## Control de Secuencia (Timeline)

```javascript
const sequence = sheet.sequence

// Reproducir
sequence.play()                          // Desde posicion actual
sequence.play({ iterationCount: 3 })     // 3 veces
sequence.play({ iterationCount: Infinity }) // Loop infinito
sequence.play({ range: [0, 2] })         // Solo segundos 0-2
sequence.play({ rate: 0.5 })             // A mitad de velocidad
sequence.play({ direction: 'reverse' })  // Reversa
sequence.play({ direction: 'alternate' })// Ping-pong

// Pausar
sequence.pause()

// Ir a posicion
sequence.position = 1.5 // Ir a segundo 1.5

// Escuchar posicion
sequence.pointer // Puntero reactivo

// Evento de fin
const promise = sequence.play()
await promise // Se resuelve cuando termina
```

## Integracion con React Three Fiber

```tsx
import { Canvas } from '@react-three/fiber'
import { SheetProvider, editable as e, PerspectiveCamera } from '@theatre/r3f'
import { getProject } from '@theatre/core'

const project = getProject('Mi Proyecto 3D')
const sheet = project.sheet('Escena')

function App() {
  return (
    <Canvas>
      <SheetProvider sheet={sheet}>
        {/* Camara editable */}
        <PerspectiveCamera
          theatreKey="Camera"
          makeDefault
          position={[0, 5, 10]}
        />

        {/* Mesh editable — se puede animar desde el editor */}
        <e.mesh theatreKey="Cubo">
          <boxGeometry args={[1, 1, 1]} />
          <e.meshStandardMaterial theatreKey="Material Cubo" color="hotpink" />
        </e.mesh>

        {/* Luz editable */}
        <e.pointLight theatreKey="Luz Principal" position={[5, 5, 5]} />
      </SheetProvider>
    </Canvas>
  )
}
```

## Exportar para Produccion

En desarrollo, editas con el Studio. Para produccion:

```javascript
// 1. En el Studio, click "Export" para obtener el JSON del estado
// 2. Guardar como archivo .json

// 3. En produccion, cargar el estado
import projectState from './animation-state.json'

const project = getProject('Mi Animacion', { state: projectState })
const sheet = project.sheet('Escena')

// 4. NO importar @theatre/studio en produccion
// if (process.env.NODE_ENV === 'development') {
//   const studio = await import('@theatre/studio')
//   studio.default.initialize()
// }

// 5. Auto-play al cargar
project.ready.then(() => {
  sheet.sequence.play({ iterationCount: Infinity })
})
```

## Patron Scroll-Linked con Theatre.js

```javascript
import Lenis from 'lenis'

const lenis = new Lenis()
const sheet = project.sheet('Scroll Scene')

lenis.on('scroll', ({ progress }) => {
  // Mapear scroll progress a posicion en timeline
  const sequenceLength = sheet.sequence.pointer.length
  sheet.sequence.position = progress * sequenceLength
})
```

## Cuando Usar Theatre.js

| Situacion | Theatre.js? |
|-----------|-------------|
| Animacion 3D cinematica con timing preciso | SI |
| Animaciones de scroll complejas con keyframes | SI |
| UI micro-interactions simples | NO (usar Framer Motion) |
| Scroll suave basico | NO (usar Lenis + GSAP) |
| Editor visual para que diseñadores ajusten animaciones | SI |
| Animaciones procedurales/aleatorias | NO (usar codigo directo) |
