---
name: spline-3d-no-code
description: >
  Spline — editor 3D no-code para la web. Exportar escenas interactivas
  como componentes React, iframes o archivos .splinecode. Eventos de mouse,
  scroll, state machines, fisicas y morphing.
  Usar cuando: Spline, escena 3D no-code, @splinetool/react-spline,
  .splinecode, 3D interactivo sin codigo, editor 3D web.
triggers:
  - "Spline"
  - "spline 3D"
  - "@splinetool"
  - "splinecode"
  - "3D no-code web"
  - "editor 3D interactivo"
type: reference
---

# Spline — 3D Interactivo No-Code para la Web

## Que Es

Spline es un editor 3D basado en navegador que permite disenar escenas
3D interactivas y exportarlas directamente a la web como componentes
React, iframes o viewers embebidos. Sin escribir GLSL ni Three.js.

**URL**: https://spline.design
**Runtime**: ~200KB (viewer ligero)
**Formato**: `.splinecode` (binario optimizado)

## Instalacion React

```bash
npm install @splinetool/react-spline @splinetool/runtime
```

## Embed Basico — React

```tsx
import Spline from '@splinetool/react-spline'

function Hero3D() {
  return (
    <Spline
      scene="https://prod.spline.design/xxxxx/scene.splinecode"
      style={{ width: '100%', height: '100vh' }}
    />
  )
}
```

## Interaccion con la Escena via API

```tsx
import Spline from '@splinetool/react-spline'
import { Application, SPEObject } from '@splinetool/runtime'
import { useRef } from 'react'

function Interactive3D() {
  const splineRef = useRef<Application>()

  function onLoad(splineApp: Application) {
    splineRef.current = splineApp

    // Buscar objetos por nombre (definido en el editor Spline)
    const cube = splineApp.findObjectByName('MyCube')
    const button = splineApp.findObjectByName('CTAButton')

    if (cube) {
      // Modificar posicion
      cube.position.x = 100
      cube.position.y = 50

      // Modificar escala
      cube.scale.x = 1.5
      cube.scale.y = 1.5
      cube.scale.z = 1.5

      // Modificar rotacion (radianes)
      cube.rotation.y = Math.PI / 4
    }
  }

  // Evento: click en objeto 3D
  function onMouseDown(e: any) {
    if (e.target.name === 'CTAButton') {
      console.log('Boton 3D clickeado:', e.target.name)
      // Navegar, abrir modal, etc.
    }
  }

  // Evento: hover sobre objeto
  function onMouseHover(e: any) {
    console.log('Hover en:', e.target.name)
  }

  return (
    <Spline
      scene="https://prod.spline.design/xxxxx/scene.splinecode"
      onLoad={onLoad}
      onMouseDown={onMouseDown}
      onMouseHover={onMouseHover}
    />
  )
}
```

## Eventos Disponibles

```tsx
<Spline
  onLoad={onLoad}           // Escena cargada
  onMouseDown={handler}     // Click en objeto
  onMouseUp={handler}       // Soltar click
  onMouseHover={handler}    // Hover sobre objeto
  onKeyDown={handler}       // Tecla presionada
  onKeyUp={handler}         // Tecla soltada
  onWheel={handler}         // Scroll sobre la escena
  onLookAt={handler}        // Objeto mira a la camara
  onFollow={handler}        // Objeto sigue al mouse
/>

// Estructura del evento
// e.target.name  — nombre del objeto
// e.target.id    — ID unico
// e.target.position — {x, y, z}
// e.target.rotation — {x, y, z}
// e.target.scale    — {x, y, z}
```

## Control Programatico — Triggers y States

```tsx
function onLoad(spline: Application) {
  // Disparar evento definido en Spline
  spline.emitEvent('mouseDown', 'ButtonName')

  // Disparar evento custom por nombre de objeto
  spline.emitEventReverse('mouseDown', 'ButtonName')

  // Buscar todos los objetos
  const allObjects = spline.findObjectsByType('Mesh')

  // Cambiar variable de estado (definida en Spline)
  spline.setVariable('isOpen', true)
  spline.setVariable('progress', 0.75)
  spline.setVariable('color', '#ff0000')
}
```

## Vanilla JS (Sin React)

```html
<canvas id="canvas3d" style="width: 100%; height: 100vh;"></canvas>

<script type="module">
  import { Application } from '@splinetool/runtime'

  const canvas = document.getElementById('canvas3d')
  const app = new Application(canvas)

  app.load('https://prod.spline.design/xxxxx/scene.splinecode')
    .then(() => {
      console.log('Escena cargada')

      const hero = app.findObjectByName('HeroObject')
      if (hero) {
        // Animar con requestAnimationFrame
        function animate() {
          hero.rotation.y += 0.01
          requestAnimationFrame(animate)
        }
        animate()
      }
    })
</script>
```

## Embed via iframe (Sin Dependencias)

```html
<!-- Metodo mas simple — sin npm -->
<iframe
  src="https://my.spline.design/xxxxx/"
  frameborder="0"
  width="100%"
  height="600"
  style="border: none;"
></iframe>
```

## Next.js — Dynamic Import (SSR-Safe)

```tsx
import dynamic from 'next/dynamic'

const Spline = dynamic(() => import('@splinetool/react-spline'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-screen flex items-center justify-center bg-black">
      <div className="animate-pulse text-white">Cargando escena 3D...</div>
    </div>
  ),
})

export default function HeroSection() {
  return (
    <section className="relative w-full h-screen">
      <Spline scene="https://prod.spline.design/xxxxx/scene.splinecode" />
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
        <h1 className="text-6xl font-bold text-white">Tu Producto</h1>
      </div>
    </section>
  )
}
```

## Patron: Hero 3D con Scroll-Linked Animation

```tsx
import Spline from '@splinetool/react-spline'
import { Application } from '@splinetool/runtime'
import { useEffect, useRef } from 'react'

function ScrollLinked3D() {
  const splineRef = useRef<Application>()
  const objectRef = useRef<SPEObject>()

  function onLoad(spline: Application) {
    splineRef.current = spline
    objectRef.current = spline.findObjectByName('ProductModel')
  }

  useEffect(() => {
    const handleScroll = () => {
      if (!objectRef.current) return
      const progress = window.scrollY / (document.body.scrollHeight - window.innerHeight)

      // Rotar modelo segun scroll
      objectRef.current.rotation.y = progress * Math.PI * 2

      // Escalar segun scroll
      const scale = 1 + progress * 0.5
      objectRef.current.scale.set(scale, scale, scale)
    }

    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <div className="fixed inset-0 z-0">
      <Spline
        scene="https://prod.spline.design/xxxxx/scene.splinecode"
        onLoad={onLoad}
      />
    </div>
  )
}
```

## Capacidades del Editor Spline

| Feature | Descripcion |
|---------|-------------|
| Modelado 3D | Primitivas, Boolean, Subdivision |
| Materiales | PBR, Glass, Gradient, Custom |
| Luces | Point, Directional, Spot, Area, HDRI |
| Animaciones | Keyframes, States, Hover, Click |
| Fisicas | Gravity, Collision, Spring |
| Interacciones | Mouse follow, Look at, Scroll |
| Camara | Orbit, Fixed, Path-based |
| Exportacion | React, Vanilla JS, iframe, video |
| Colaboracion | Tiempo real, como Figma |

## Performance

- Lazy load la escena con `loading="lazy"` o dynamic import
- Escenas complejas: usar `.splinecode` (comprimido) no `.spline`
- Reducir poligonos en el editor para mobile
- Usar `will-change: transform` en el container
- Canvas fijo con `position: fixed` evita re-renders

## Cuando Usar Spline vs Alternativas

| Caso | Spline | Three.js/R3F | Babylon.js |
|------|--------|-------------|------------|
| Prototipo rapido 3D | IDEAL | Lento | Lento |
| Landing page hero 3D | IDEAL | Bueno | Overkill |
| Producto configurator | Bueno | IDEAL | IDEAL |
| Juego web | NO | Bueno | IDEAL |
| Animaciones complejas | Bueno | IDEAL (Theatre.js) | Bueno |
| Sin conocimientos 3D | IDEAL | Requiere codigo | Requiere codigo |
