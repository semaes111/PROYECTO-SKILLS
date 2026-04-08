---
name: unicorn-studio-webgl
description: >
  Unicorn Studio — efectos WebGL no-code para la web. 70+ shaders
  predefinidos, embed ligero (36KB), gradientes animados, distorsiones,
  blur dinamico, particulas. Alternativa visual a ShaderGradient.
  Usar cuando: Unicorn Studio, WebGL no-code, shader visual, gradiente
  WebGL, efecto visual web sin codigo, background animado.
triggers:
  - "Unicorn Studio"
  - "unicornstudio"
  - "WebGL no-code"
  - "shader visual editor"
  - "efecto WebGL sin codigo"
  - "background WebGL animado"
type: reference
---

# Unicorn Studio — Efectos WebGL No-Code para la Web

## Que Es

Unicorn Studio es un editor visual de efectos WebGL que permite crear
backgrounds animados, distorsiones, particulas y efectos de shader sin
escribir GLSL. Se embebe en cualquier web con un script de ~36KB.

**URL**: https://www.unicorn.studio
**Runtime**: ~36KB (muy ligero)
**Compatibilidad**: Todos los navegadores modernos con WebGL

## Embed Basico — Script Tag

```html
<!-- 1. Container donde se renderiza el efecto -->
<div
  data-us-project="tu-project-id-aqui"
  style="width: 100%; height: 100vh;"
></div>

<!-- 2. Script del runtime (al final del body) -->
<script src="https://cdn.unicorn.studio/v1.3.2/unicornStudio.umd.js"></script>
<script>
  UnicornStudio.init().then(scenes => {
    console.log('Escenas cargadas:', scenes)
  })
</script>
```

## Embed con Opciones

```html
<div
  data-us-project="tu-project-id"
  data-us-scale="1"
  data-us-dpi="1.5"
  data-us-fps="60"
  data-us-alttext="Efecto visual animado"
  data-us-arialabel="Background decorativo"
  style="width: 100%; height: 500px; position: relative;"
></div>

<script src="https://cdn.unicorn.studio/v1.3.2/unicornStudio.umd.js"></script>
<script>
  UnicornStudio.init({
    scale: 1,           // Escala del canvas (1 = 100%)
    dpi: 1.5,          // Pixel ratio (1-2, mas alto = mas nitido pero mas pesado)
    fps: 60,           // Frames por segundo
    lazyLoad: true,    // Solo cargar cuando es visible
  }).then(scenes => {
    // scenes[0] es la primera escena
    const scene = scenes[0]

    // Acceder a la API
    scene.pause()
    scene.play()
    scene.destroy()
  })
})
</script>
```

## React Component

```tsx
import { useEffect, useRef } from 'react'

interface UnicornSceneProps {
  projectId: string
  className?: string
  style?: React.CSSProperties
  dpi?: number
  fps?: number
}

function UnicornScene({ projectId, className, style, dpi = 1.5, fps = 60 }: UnicornSceneProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const sceneRef = useRef<any>(null)

  useEffect(() => {
    let destroyed = false

    // Cargar script dinamicamente si no existe
    const loadScript = () => {
      return new Promise<void>((resolve) => {
        if ((window as any).UnicornStudio) {
          resolve()
          return
        }
        const script = document.createElement('script')
        script.src = 'https://cdn.unicorn.studio/v1.3.2/unicornStudio.umd.js'
        script.onload = () => resolve()
        document.body.appendChild(script)
      })
    }

    loadScript().then(() => {
      if (destroyed || !containerRef.current) return

      ;(window as any).UnicornStudio.init({
        scale: 1,
        dpi,
        fps,
      }).then((scenes: any[]) => {
        if (!destroyed) {
          sceneRef.current = scenes[0]
        }
      })
    })

    return () => {
      destroyed = true
      sceneRef.current?.destroy()
    }
  }, [projectId, dpi, fps])

  return (
    <div
      ref={containerRef}
      data-us-project={projectId}
      className={className}
      style={style}
    />
  )
}

// Uso
function HeroSection() {
  return (
    <section className="relative h-screen">
      <UnicornScene
        projectId="abc123"
        className="absolute inset-0 -z-10"
        style={{ width: '100%', height: '100%' }}
      />
      <div className="relative z-10 flex items-center justify-center h-full">
        <h1 className="text-6xl font-bold text-white">Tu Producto</h1>
      </div>
    </section>
  )
}
```

## Next.js — Dynamic Import (SSR-Safe)

```tsx
'use client'

import dynamic from 'next/dynamic'

const UnicornScene = dynamic(() => import('./UnicornScene'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-full bg-gradient-to-br from-purple-900 to-black" />
  ),
})

export default function Hero() {
  return (
    <div className="relative h-screen">
      <UnicornScene projectId="abc123" className="absolute inset-0" />
      <div className="relative z-10">
        {/* Contenido sobre el efecto */}
      </div>
    </div>
  )
}
```

## API JavaScript

```javascript
UnicornStudio.init().then(scenes => {
  const scene = scenes[0]

  // Controles de reproduccion
  scene.play()           // Reanudar animacion
  scene.pause()          // Pausar animacion
  scene.destroy()        // Destruir y liberar recursos

  // Interaccion con mouse (si el efecto lo soporta)
  // La mayoria de efectos responden automaticamente al mouse

  // Resize
  scene.resize()         // Forzar recalculo de tamano
})
```

## Tipos de Efectos Disponibles

| Categoria | Ejemplos |
|-----------|----------|
| Gradientes | Mesh gradient, aurora, liquid, wave |
| Particulas | Dots, stars, fireflies, snow, confetti |
| Distorsion | Ripple, warp, glitch, chromatic aberration |
| Blur | Gaussian, radial, motion blur |
| Texturas | Noise, grain, fabric, water |
| Geometria | Grid, voronoi, polygons, lines |
| Luces | Glow, lens flare, god rays |
| Organico | Blob, smoke, clouds, fire |

## Patron: Background para Secciones

```html
<!-- Hero con gradiente WebGL -->
<section class="relative min-h-screen overflow-hidden">
  <div
    data-us-project="gradient-project-id"
    class="absolute inset-0 -z-10"
    style="width: 100%; height: 100%;"
  ></div>

  <div class="relative z-10 container mx-auto px-6 py-24">
    <h1 class="text-7xl font-bold text-white">Premium Landing</h1>
    <p class="mt-6 text-xl text-white/80">Con efecto WebGL de fondo</p>
  </div>
</section>

<!-- Seccion con particulas -->
<section class="relative py-24">
  <div
    data-us-project="particles-project-id"
    class="absolute inset-0 -z-10 opacity-30"
  ></div>

  <div class="relative z-10">
    <!-- Contenido -->
  </div>
</section>
```

## Unicorn Studio vs Alternativas

| Feature | Unicorn Studio | ShaderGradient | Spline | Custom GLSL |
|---------|---------------|----------------|--------|-------------|
| Editor visual | SI (completo) | NO (props) | SI (3D) | NO |
| Bundle size | 36KB | ~200KB | ~200KB | Variable |
| Curva aprendizaje | Baja | Baja | Media | Alta |
| Personalizacion | 70+ efectos | Limitada | Alta | Total |
| Interactividad mouse | Automatica | NO | SI | Manual |
| Precio | Freemium | Gratis | Freemium | Gratis |
| Performance | Excelente | Buena | Buena | Variable |

## Performance Tips

- `dpi: 1` en mobile (vs 1.5-2 en desktop)
- `fps: 30` es suficiente para la mayoria de efectos
- `lazyLoad: true` para escenas below the fold
- Llamar `scene.pause()` cuando la seccion no es visible (IntersectionObserver)
- Usar `will-change: transform` en el container para layer promotion
- Destruir escenas al desmontar componentes para liberar GPU memory

## Accesibilidad

```html
<!-- Siempre incluir alt text y aria-label -->
<div
  data-us-project="project-id"
  data-us-alttext="Gradiente animado decorativo"
  data-us-arialabel="Fondo animado con efecto de aurora boreal"
  role="img"
></div>

<!-- Respetar prefers-reduced-motion -->
<script>
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  UnicornStudio.init({
    fps: prefersReduced ? 0 : 60,  // fps 0 = estatico
  })
</script>
```
