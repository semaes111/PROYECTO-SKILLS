---
name: lenis-smooth-scroll-cinematico
description: >
  Smooth scroll cinematico con Lenis — estandar 2025 en webs premium Awwwards/FWA.
  Scroll suave que elimina jank, normaliza input, mantiene APIs nativas.
  Integracion con GSAP ScrollTrigger, React Three Fiber, Next.js.
  Usar cuando: scroll suave, Lenis, smooth scroll, scroll cinematico,
  scroll premium, scroll parallax, scroll horizontal, infinite scroll.
triggers:
  - "smooth scroll"
  - "Lenis"
  - "scroll cinematico"
  - "scroll suave premium"
type: reference
---

# Lenis Smooth Scroll — Scroll Cinematico para Webs Premium

## Que Es

Lenis es el motor de smooth scroll estandar en webs de alto nivel (Awwwards, FWA).
Reemplaza el scroll nativo del navegador por uno interpolado que:
- Elimina jank y stuttering
- Normaliza input entre trackpad, mouse wheel y touch
- Mantiene compatibilidad con APIs nativas (anchors, find-in-page)
- Funciona a 60fps constante

**GitHub**: github.com/darkroomengineering/lenis | **8K+ stars**

## Instalacion

```bash
npm install lenis
# o
yarn add lenis
```

CDN:
```html
<script src="https://unpkg.com/lenis"></script>
```

## Setup Basico — Vanilla JS

```javascript
import Lenis from 'lenis'
import 'lenis/dist/lenis.css'

const lenis = new Lenis({
  duration: 1.2,          // Duracion de la interpolacion (segundos)
  easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)), // Easing exponencial
  orientation: 'vertical', // 'vertical' | 'horizontal'
  smoothWheel: true,       // Suavizar scroll de raton
  touchMultiplier: 2,      // Sensibilidad touch
  infinite: false,         // Scroll infinito
  autoResize: true,        // Recalcular al resize
})

// Bucle de animacion — OBLIGATORIO
function raf(time) {
  lenis.raf(time)
  requestAnimationFrame(raf)
}
requestAnimationFrame(raf)
```

## Setup React / Next.js

```tsx
// components/SmoothScroll.tsx
'use client'
import { useEffect } from 'react'
import Lenis from 'lenis'
import 'lenis/dist/lenis.css'

export function SmoothScroll({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
    })

    function raf(time: number) {
      lenis.raf(time)
      requestAnimationFrame(raf)
    }
    requestAnimationFrame(raf)

    return () => lenis.destroy()
  }, [])

  return <>{children}</>
}

// app/layout.tsx
import { SmoothScroll } from '@/components/SmoothScroll'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <SmoothScroll>{children}</SmoothScroll>
      </body>
    </html>
  )
}
```

## Opciones Completas

```javascript
const lenis = new Lenis({
  duration: 1.2,           // 0.5 (rapido) a 2.0 (ultra suave)
  easing: (t) => ...,      // Funcion de easing personalizada
  orientation: 'vertical', // 'vertical' | 'horizontal'
  gestureOrientation: 'vertical', // Orientacion del gesto
  smoothWheel: true,       // Suavizar rueda del raton
  touchMultiplier: 2,      // Multiplicador touch (1-3)
  wheelMultiplier: 1,      // Multiplicador rueda
  infinite: false,         // Scroll infinito
  autoResize: true,        // Auto-recalcular dimensiones
  prevent: (node) => false,// Funcion para prevenir scroll en nodos
  virtualScroll: (e) => true, // Controlar eventos de scroll virtual
  overscroll: true,        // Permitir overscroll en mobile
})
```

## API — Metodos Principales

```javascript
// Scroll programatico
lenis.scrollTo(targetElement)           // Scroll a elemento DOM
lenis.scrollTo('#section-2')            // Scroll a anchor
lenis.scrollTo(500)                     // Scroll a posicion en px
lenis.scrollTo(targetElement, {
  offset: -100,                         // Offset en px
  duration: 2,                          // Duracion custom
  easing: (t) => t,                     // Easing custom
  immediate: false,                     // Sin animacion
  lock: true,                           // Bloquear scroll durante animacion
  onComplete: () => console.log('done') // Callback al completar
})

// Control
lenis.start()    // Reactivar scroll
lenis.stop()     // Pausar scroll
lenis.destroy()  // Destruir instancia y limpiar listeners

// Eventos
lenis.on('scroll', ({ scroll, limit, velocity, direction, progress }) => {
  // scroll: posicion actual en px
  // limit: scroll maximo
  // velocity: velocidad actual
  // direction: 1 (abajo) | -1 (arriba)
  // progress: 0 a 1
})

// Propiedades
lenis.scroll      // Posicion actual
lenis.progress     // Progreso 0-1
lenis.velocity     // Velocidad actual
lenis.isScrolling  // Esta scrolleando?
lenis.direction    // Direccion actual
```

## Integracion con GSAP ScrollTrigger

```javascript
import Lenis from 'lenis'
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger)

const lenis = new Lenis()

// Sincronizar Lenis con GSAP ScrollTrigger
lenis.on('scroll', ScrollTrigger.update)

gsap.ticker.add((time) => {
  lenis.raf(time * 1000)
})
gsap.ticker.lagSmoothing(0)

// Ahora ScrollTrigger funciona con Lenis automaticamente
gsap.to('.hero-title', {
  scrollTrigger: {
    trigger: '.hero',
    start: 'top top',
    end: 'bottom top',
    scrub: 1,
  },
  y: -100,
  opacity: 0,
})
```

## Integracion con React Three Fiber

```tsx
import { useFrame } from '@react-three/fiber'
import { useEffect, useRef } from 'react'
import Lenis from 'lenis'

export function ScrollLinked3D() {
  const meshRef = useRef()
  const scrollRef = useRef(0)

  useEffect(() => {
    const lenis = new Lenis()

    lenis.on('scroll', ({ progress }) => {
      scrollRef.current = progress
    })

    function raf(time) {
      lenis.raf(time)
      requestAnimationFrame(raf)
    }
    requestAnimationFrame(raf)

    return () => lenis.destroy()
  }, [])

  useFrame(() => {
    if (meshRef.current) {
      meshRef.current.rotation.y = scrollRef.current * Math.PI * 2
      meshRef.current.position.y = scrollRef.current * -5
    }
  })

  return <mesh ref={meshRef}><boxGeometry /><meshStandardMaterial /></mesh>
}
```

## Scroll Horizontal

```javascript
const lenis = new Lenis({
  orientation: 'horizontal',
  gestureOrientation: 'both', // Permite scroll vertical que mueve horizontal
})

// CSS necesario
// .horizontal-wrapper { display: flex; width: fit-content; }
// .horizontal-section { width: 100vw; height: 100vh; flex-shrink: 0; }
```

## Performance Tips

1. **duration**: 1.0-1.4 es el sweet spot. Mas alto = mas suave pero mas latencia
2. **Mobile**: Considerar `smoothWheel: false` en mobile si el scroll nativo es suficiente
3. **Cleanup**: SIEMPRE llamar `lenis.destroy()` en cleanup de useEffect
4. **Scroll largo**: Usar `virtualScroll` para controlar cuando aplicar smooth
5. **Accesibilidad**: Lenis mantiene `prefers-reduced-motion` automaticamente

## Patron Completo — Web Premium

```javascript
import Lenis from 'lenis'
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger)

// 1. Inicializar Lenis
const lenis = new Lenis({ duration: 1.2 })

// 2. Sincronizar con GSAP
lenis.on('scroll', ScrollTrigger.update)
gsap.ticker.add((time) => lenis.raf(time * 1000))
gsap.ticker.lagSmoothing(0)

// 3. Animaciones de scroll
gsap.utils.toArray('.reveal').forEach(el => {
  gsap.from(el, {
    scrollTrigger: { trigger: el, start: 'top 80%', toggleActions: 'play none none reverse' },
    y: 60, opacity: 0, duration: 1, ease: 'power3.out'
  })
})

// 4. Parallax
gsap.to('.parallax-bg', {
  scrollTrigger: { trigger: '.parallax-section', scrub: 1 },
  y: -200, ease: 'none'
})

// 5. Progress bar
lenis.on('scroll', ({ progress }) => {
  document.querySelector('.progress-bar').style.scaleX = progress
})
```
