---
name: mojs-motion-graphics
description: >
  Mo.js — motion graphics toolbox para la web. Shape, ShapeSwirl, Burst,
  Stagger, Timeline, curvas custom. Explosiones de particulas, micro-
  interacciones, animaciones de UI con precision de motion design.
  Usar cuando: mo.js, burst, explosion particulas, shape animation,
  motion graphics web, micro-interacciones, confetti, sparkle.
triggers:
  - "mo.js"
  - "mojs"
  - "burst animation"
  - "explosion particulas"
  - "shape animation web"
  - "micro-interacciones"
  - "confetti"
  - "sparkle effect"
type: reference
---

# Mo.js — Motion Graphics Toolbox para la Web

## Que Es

Mo.js es una libreria de motion graphics para crear animaciones de
particulas, bursts, shapes y timelines con precision cinematica.
Ideal para micro-interacciones (like buttons, success states, tooltips)
y efectos visuales tipo After Effects en la web.

**Repositorio**: https://github.com/mojs/mojs (18K+ stars)
**Bundle**: ~30KB gzipped

## Instalacion

```bash
npm install @mojs/core
```

```javascript
import mojs from '@mojs/core'
```

## Shape — Figura Animada

```javascript
// Shape basico: circulo que aparece y desaparece
const circle = new mojs.Shape({
  shape: 'circle',           // circle, rect, polygon, cross, plus, zigzag
  fill: 'none',
  stroke: '#ff6b6b',
  strokeWidth: { 30: 0 },   // De 30 a 0 (animado)
  radius: { 0: 100 },       // De 0 a 100
  opacity: { 1: 0 },        // Fade out
  duration: 700,
  easing: 'cubic.out',
  isShowStart: true,         // Visible desde el inicio
})

circle.play()
```

### Sintaxis de Valores Animados

```javascript
// { from: to } — Transicion
radius: { 0: 100 }          // De 0 a 100

// String con 'rand' — Valor aleatorio
radius: 'rand(20, 50)'      // Aleatorio entre 20 y 50

// String con 'stagger' — Escalonado
delay: 'stagger(100)'       // Cada instancia +100ms

// Curva custom
y: { 0: -150, curve: 'M0,100 C0,100 25,10 50,50 75,0 100,100' }
```

### Shapes Disponibles

```javascript
// Todas las formas built-in
'circle'    // Circulo
'rect'      // Rectangulo
'polygon'   // Poligono (usar 'points' para lados)
'cross'     // Cruz
'plus'      // Signo +
'zigzag'    // Zigzag
'equal'     // Signo =
'curve'     // Curva

// Poligono con N lados
new mojs.Shape({
  shape: 'polygon',
  points: 6,          // Hexagono
  fill: '#4ecdc4',
  radius: { 0: 50 },
})
```

## ShapeSwirl — Shape con Movimiento Organico

```javascript
// ShapeSwirl = Shape + movimiento curvo tipo particula
const swirl = new mojs.ShapeSwirl({
  shape: 'circle',
  fill: '#ff6b6b',
  radius: { 6: 0 },
  pathScale: 'rand(0.5, 1)',    // Escala del path
  swirlSize: 'rand(10, 15)',    // Tamano del swirl
  swirlFrequency: 'rand(2, 4)', // Frecuencia de oscilacion
  direction: 1,                  // 1 o -1
  y: { 0: 'rand(-80, -120)' },  // Sube
  x: { 0: 'rand(-30, 30)' },    // Lateral aleatorio
  duration: 'rand(600, 1000)',
  isSwirl: true,
})
```

## Burst — Explosion de Particulas

```javascript
// Burst = Multiples shapes explotando desde un punto
const burst = new mojs.Burst({
  radius: { 0: 100 },           // Radio de expansion
  count: 10,                      // Numero de particulas
  angle: { 0: 90 },             // Rotacion del burst

  children: {
    shape: 'circle',
    fill: ['#ff6b6b', '#4ecdc4', '#45b7d1', '#ffd93d'],  // Colores aleatorios
    radius: { 8: 0 },
    strokeWidth: 0,
    duration: 700,
    delay: 'stagger(25)',        // Escalonado
    easing: 'cubic.out',
  },
})

// Disparar en click
document.addEventListener('click', (e) => {
  burst
    .tune({ x: e.clientX, y: e.clientY })
    .replay()
})
```

### Burst Avanzado — Fireworks

```javascript
const firework = new mojs.Burst({
  radius: { 0: 150 },
  count: 20,
  children: {
    shape: 'line',
    stroke: ['#ff6b6b', '#4ecdc4', '#ffd93d', '#ff85a2'],
    strokeWidth: { 3: 0 },
    radius: { 'rand(15, 40)': 0 },
    scale: { 1: 0 },
    duration: 'rand(500, 900)',
    delay: 'rand(0, 150)',
    easing: 'quad.out',
    isSwirl: true,
    swirlSize: 'rand(5, 15)',
    pathScale: 'rand(0.5, 0.8)',
  },
})
```

## Stagger — Escalonar Multiples Animaciones

```javascript
// Crear HTML burst (particulas como elementos DOM)
const htmlBurst = new mojs.Html({
  el: '#my-element',
  x: { 0: 100 },
  y: { 0: -50 },
  opacity: { 1: 0 },
  duration: 600,
  delay: 'stagger(50)',   // Cada elemento 50ms despues
})
```

## Timeline — Orquestacion de Animaciones

```javascript
const timeline = new mojs.Timeline({
  delay: 0,
  repeat: 0,
  // onStart, onComplete, onProgress, etc.
})

// Secuenciar animaciones
const shape1 = new mojs.Shape({
  shape: 'circle',
  radius: { 0: 50 },
  fill: '#ff6b6b',
  duration: 500,
})

const shape2 = new mojs.Shape({
  shape: 'rect',
  radius: { 0: 50 },
  fill: '#4ecdc4',
  duration: 500,
  delay: 300,  // Empieza 300ms despues
})

const burst1 = new mojs.Burst({
  radius: { 0: 80 },
  count: 8,
  delay: 600,
  children: {
    shape: 'circle',
    fill: '#45b7d1',
    radius: { 5: 0 },
    duration: 500,
  },
})

// Agregar al timeline
timeline.add(shape1, shape2, burst1)

// Controles
timeline.play()
timeline.pause()
timeline.stop()
timeline.replay()
timeline.setProgress(0.5)  // Ir al 50%

// Callbacks
timeline.onComplete = () => console.log('Timeline completo')
```

## Patron: Like Button con Burst

```tsx
import mojs from '@mojs/core'
import { useRef, useEffect, useCallback } from 'react'

function LikeButton() {
  const buttonRef = useRef<HTMLButtonElement>(null)
  const burstRef = useRef<any>(null)
  const scaleRef = useRef<any>(null)

  useEffect(() => {
    if (!buttonRef.current) return

    // Burst de corazones
    burstRef.current = new mojs.Burst({
      parent: buttonRef.current,
      radius: { 20: 60 },
      count: 8,
      children: {
        shape: 'circle',
        fill: ['#E05297', '#E05297', '#CC208E', '#CC208E', '#A5006D'],
        radius: { 8: 0 },
        duration: 700,
        delay: 'stagger(25)',
        easing: 'cubic.out',
      },
    })

    // Ring que se expande
    const ring = new mojs.Shape({
      parent: buttonRef.current,
      shape: 'circle',
      fill: 'none',
      stroke: '#E05297',
      strokeWidth: { 15: 0 },
      radius: { 0: 40 },
      opacity: { 1: 0 },
      duration: 600,
      easing: 'cubic.out',
    })

    // Escala bounce del icono
    scaleRef.current = new mojs.Html({
      el: buttonRef.current,
      scale: { 1.3: 1 },
      duration: 400,
      easing: 'elastic.out',
    })

    burstRef.current.add(ring)
  }, [])

  const handleClick = useCallback(() => {
    burstRef.current?.replay()
    scaleRef.current?.replay()
  }, [])

  return (
    <button ref={buttonRef} onClick={handleClick} className="relative p-4">
      <svg width="24" height="24" fill="#E05297" viewBox="0 0 24 24">
        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
      </svg>
    </button>
  )
}
```

## Patron: Success Checkmark Animation

```javascript
const successTimeline = new mojs.Timeline()

// Circulo que se expande
const successCircle = new mojs.Shape({
  shape: 'circle',
  fill: '#4ecdc4',
  radius: { 0: 60 },
  duration: 400,
  easing: 'cubic.out',
})

// Ring exterior
const successRing = new mojs.Shape({
  shape: 'circle',
  fill: 'none',
  stroke: '#4ecdc4',
  strokeWidth: { 20: 0 },
  radius: { 0: 80 },
  opacity: { 1: 0 },
  duration: 600,
  delay: 100,
  easing: 'cubic.out',
})

// Particulas de celebracion
const successBurst = new mojs.Burst({
  radius: { 0: 100 },
  count: 12,
  delay: 200,
  children: {
    shape: ['circle', 'rect', 'polygon'],
    fill: ['#4ecdc4', '#45b7d1', '#ffd93d', '#ff6b6b'],
    radius: { 'rand(5, 10)': 0 },
    duration: 800,
    delay: 'stagger(30)',
    easing: 'quad.out',
  },
})

successTimeline.add(successCircle, successRing, successBurst)
// successTimeline.play()
```

## Patron: Page Transition Particles

```javascript
// Burst fullscreen para transiciones de pagina
function createPageTransition(x: number, y: number) {
  const timeline = new mojs.Timeline()

  // Onda expansiva
  const wave = new mojs.Shape({
    shape: 'circle',
    fill: '#0a0a0a',
    radius: { 0: Math.max(window.innerWidth, window.innerHeight) },
    x, y,
    duration: 800,
    easing: 'cubic.in',
  })

  // Particulas que acompanan
  const particles = new mojs.Burst({
    x, y,
    radius: { 0: 200 },
    count: 15,
    children: {
      shape: 'circle',
      fill: 'white',
      radius: { 'rand(3, 8)': 0 },
      opacity: { 1: 0 },
      duration: 600,
      delay: 'stagger(20)',
    },
  })

  timeline.add(wave, particles)
  return timeline
}
```

## Curvas de Easing

```javascript
// Built-in easings
'linear.none'
'ease.in', 'ease.out', 'ease.inout'
'sin.in', 'sin.out', 'sin.inout'
'quad.in', 'quad.out', 'quad.inout'
'cubic.in', 'cubic.out', 'cubic.inout'
'quart.in', 'quart.out', 'quart.inout'
'quint.in', 'quint.out', 'quint.inout'
'expo.in', 'expo.out', 'expo.inout'
'circ.in', 'circ.out', 'circ.inout'
'back.in', 'back.out', 'back.inout'
'elastic.in', 'elastic.out', 'elastic.inout'
'bounce.in', 'bounce.out', 'bounce.inout'

// Custom path easing (SVG path)
easing: 'M0,100 C0,100 25,10 50,50 75,0 100,100'
```

## Performance

- Usa `requestAnimationFrame` internamente (optimizado)
- Burst con >30 particulas: considerar `isShowEnd: false`
- Evitar bursts simultaneos masivos (>5)
- Reutilizar instancias con `.tune()` + `.replay()` en vez de crear nuevas
- En mobile: reducir `count` de bursts a la mitad
