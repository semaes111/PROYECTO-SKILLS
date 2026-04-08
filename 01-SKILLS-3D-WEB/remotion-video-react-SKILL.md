---
name: remotion-video-react
description: >
  Remotion — crear videos programaticamente con React. Compositions,
  useCurrentFrame, interpolate, spring, sequences, audio, rendering
  a MP4/WebM. Videos dinamicos con datos, motion graphics con codigo.
  Usar cuando: Remotion, video programatico, React video, generar video
  con codigo, motion graphics React, video template, renderizar video.
triggers:
  - "Remotion"
  - "video programatico"
  - "React video"
  - "generar video con codigo"
  - "motion graphics React"
  - "renderizar video"
type: reference
---

# Remotion — Videos Programaticos con React

## Que Es

Remotion permite crear videos usando componentes React. Cada frame es
un render de React. Puedes usar CSS, SVG, Canvas, Three.js, y cualquier
libreria React para crear motion graphics, videos con datos dinamicos,
y templates de video reutilizables.

**Repositorio**: https://github.com/remotion-dev/remotion (20K+ stars)

## Setup

```bash
npx create-video@latest my-video
cd my-video
npm start     # Preview en el navegador
```

```bash
# O anadir a proyecto existente
npm install remotion @remotion/cli @remotion/player
```

## Conceptos Core

```
Composition = Un video definido (duracion, fps, resolucion)
Frame       = Un unico instante del video (numero entero)
Sequence    = Sub-seccion con timeline propia
Series      = Secuencias una tras otra
interpolate = Mapear frame a valor animado
spring      = Animacion con fisica (bounce, damping)
```

## Composition — Definir un Video

```tsx
// src/Root.tsx
import { Composition } from 'remotion'
import { MyVideo } from './MyVideo'

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="MyVideo"
        component={MyVideo}
        durationInFrames={300}   // 10 segundos a 30fps
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          title: 'Mi Video',
          color: '#ff6b6b',
        }}
      />
    </>
  )
}
```

## useCurrentFrame + interpolate

```tsx
import { useCurrentFrame, interpolate, AbsoluteFill } from 'remotion'

export const MyVideo: React.FC<{ title: string; color: string }> = ({ title, color }) => {
  const frame = useCurrentFrame()  // 0, 1, 2, 3... hasta durationInFrames

  // Interpolacion: frame 0-30 → opacity 0-1
  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateRight: 'clamp',  // No pasar de 1
  })

  // Mover de abajo hacia arriba: frame 0-30 → translateY 100→0
  const translateY = interpolate(frame, [0, 30], [100, 0], {
    extrapolateRight: 'clamp',
  })

  // Escala con spring (bounce)
  const scale = interpolate(frame, [30, 60], [0.5, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  })

  return (
    <AbsoluteFill style={{ backgroundColor: color, justifyContent: 'center', alignItems: 'center' }}>
      <h1
        style={{
          fontSize: 120,
          color: 'white',
          fontFamily: 'Inter',
          opacity,
          transform: `translateY(${translateY}px) scale(${scale})`,
        }}
      >
        {title}
      </h1>
    </AbsoluteFill>
  )
}
```

## spring — Animacion con Fisica

```tsx
import { useCurrentFrame, useVideoConfig, spring } from 'remotion'

export const BouncyTitle: React.FC = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  // Spring animation (empieza en frame 0)
  const scale = spring({
    frame,
    fps,
    config: {
      damping: 10,      // Amortiguacion (mas alto = menos bounce)
      stiffness: 100,   // Rigidez (mas alto = mas rapido)
      mass: 1,          // Masa (mas alto = mas lento)
      overshootClamping: false,  // Permitir bounce
    },
  })

  // Spring con delay
  const opacity = spring({
    frame: frame - 15,  // Empieza 15 frames despues
    fps,
    config: { damping: 20, stiffness: 80 },
    durationInFrames: 30,
  })

  return (
    <AbsoluteFill style={{ justifyContent: 'center', alignItems: 'center' }}>
      <div style={{ transform: `scale(${scale})`, opacity }}>
        <h1 style={{ fontSize: 100 }}>Bouncy!</h1>
      </div>
    </AbsoluteFill>
  )
}
```

## Sequence — Timeline de Sub-Secciones

```tsx
import { Sequence, AbsoluteFill } from 'remotion'

export const MultiScene: React.FC = () => {
  return (
    <AbsoluteFill>
      {/* Escena 1: frames 0-89 (3 segundos) */}
      <Sequence from={0} durationInFrames={90}>
        <IntroScene />
      </Sequence>

      {/* Escena 2: frames 60-179 (overlap de 30 frames) */}
      <Sequence from={60} durationInFrames={120}>
        <MainContent />
      </Sequence>

      {/* Escena 3: frames 150 hasta el final */}
      <Sequence from={150}>
        <OutroScene />
      </Sequence>

      {/* Nombre para debugging en el timeline */}
      <Sequence from={0} durationInFrames={300} name="Background Music">
        <BackgroundAudio />
      </Sequence>
    </AbsoluteFill>
  )
}
```

## Series — Secuencias Consecutivas

```tsx
import { Series } from 'remotion'

export const SlideShow: React.FC = () => {
  return (
    <Series>
      <Series.Sequence durationInFrames={90}>
        <Slide text="Primer punto" />
      </Series.Sequence>
      <Series.Sequence durationInFrames={90} offset={-15}> {/* Overlap 15 frames */}
        <Slide text="Segundo punto" />
      </Series.Sequence>
      <Series.Sequence durationInFrames={90}>
        <Slide text="Tercer punto" />
      </Series.Sequence>
    </Series>
  )
}
```

## Audio y Video

```tsx
import { Audio, Video, staticFile, useCurrentFrame, interpolate } from 'remotion'

export const WithMedia: React.FC = () => {
  const frame = useCurrentFrame()
  const volume = interpolate(frame, [0, 30], [0, 1], { extrapolateRight: 'clamp' })

  return (
    <AbsoluteFill>
      {/* Audio local */}
      <Audio
        src={staticFile('music.mp3')}  // Desde /public/
        volume={volume}                // Fade in
        startFrom={60}                 // Empezar desde frame 60 del audio
      />

      {/* Video como fondo */}
      <Video
        src={staticFile('background.mp4')}
        style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        volume={0}  // Muted
      />

      {/* Audio desde URL */}
      <Audio src="https://example.com/audio.mp3" />
    </AbsoluteFill>
  )
}
```

## Datos Dinamicos — Videos con API Data

```tsx
import { useCurrentFrame, delayRender, continueRender } from 'remotion'
import { useEffect, useState } from 'react'

export const DataDrivenVideo: React.FC<{ apiUrl: string }> = ({ apiUrl }) => {
  const [data, setData] = useState<any>(null)
  const [handle] = useState(() => delayRender())  // Pausar render hasta tener datos

  useEffect(() => {
    fetch(apiUrl)
      .then(res => res.json())
      .then(json => {
        setData(json)
        continueRender(handle)  // Datos listos, continuar render
      })
  }, [])

  if (!data) return null

  return (
    <AbsoluteFill style={{ padding: 80 }}>
      <h1 style={{ fontSize: 60 }}>{data.title}</h1>
      <p style={{ fontSize: 30 }}>{data.description}</p>
      {/* Grafico animado con los datos */}
      <AnimatedChart data={data.metrics} />
    </AbsoluteFill>
  )
}
```

## Transiciones entre Escenas

```tsx
import { TransitionSeries, linearTiming, fade, slide, wipe } from '@remotion/transitions'

export const WithTransitions: React.FC = () => {
  return (
    <TransitionSeries>
      <TransitionSeries.Sequence durationInFrames={90}>
        <SceneA />
      </TransitionSeries.Sequence>

      {/* Fade transition de 30 frames */}
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 30 })}
      />

      <TransitionSeries.Sequence durationInFrames={90}>
        <SceneB />
      </TransitionSeries.Sequence>

      {/* Slide desde la derecha */}
      <TransitionSeries.Transition
        presentation={slide({ direction: 'from-right' })}
        timing={linearTiming({ durationInFrames: 20 })}
      />

      <TransitionSeries.Sequence durationInFrames={90}>
        <SceneC />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  )
}
```

## Remotion Player — Embed en tu Web

```tsx
import { Player } from '@remotion/player'
import { MyVideo } from './MyVideo'

function VideoPreview() {
  return (
    <Player
      component={MyVideo}
      inputProps={{ title: 'Preview', color: '#4ecdc4' }}
      durationInFrames={300}
      fps={30}
      compositionWidth={1920}
      compositionHeight={1080}
      style={{ width: '100%' }}
      controls                    // Mostrar controles de play/pause
      autoPlay                    // Auto-play
      loop                        // Loop infinito
      clickToPlay={false}         // No pausar al hacer click
    />
  )
}
```

## Renderizar a MP4/WebM

```bash
# Renderizar a MP4
npx remotion render src/index.ts MyVideo out/video.mp4

# Renderizar WebM (mas rapido, menor calidad)
npx remotion render src/index.ts MyVideo out/video.webm --codec=vp8

# Con props custom
npx remotion render src/index.ts MyVideo out/video.mp4 \
  --props='{"title": "Custom Title", "color": "#ff0000"}'

# Renderizar solo un rango de frames
npx remotion render src/index.ts MyVideo out/clip.mp4 \
  --frames=0-89

# GIF
npx remotion render src/index.ts MyVideo out/animation.gif \
  --codec=gif --every-nth-frame=2
```

## Renderizado Programatico (Server-Side)

```typescript
import { bundle } from '@remotion/bundler'
import { renderMedia, selectComposition } from '@remotion/renderer'

async function renderVideo(props: Record<string, any>) {
  // 1. Bundle el proyecto
  const bundleLocation = await bundle({
    entryPoint: './src/index.ts',
    webpackOverride: (config) => config,
  })

  // 2. Seleccionar composition
  const composition = await selectComposition({
    serveUrl: bundleLocation,
    id: 'MyVideo',
    inputProps: props,
  })

  // 3. Renderizar
  await renderMedia({
    composition,
    serveUrl: bundleLocation,
    codec: 'h264',
    outputLocation: `out/${Date.now()}.mp4`,
    inputProps: props,
  })
}

// Ejemplo: video personalizado por usuario
await renderVideo({ title: 'Bienvenido Juan', color: '#ff6b6b' })
```

## Casos de Uso Awwwards-Level

| Caso | Descripcion |
|------|-------------|
| Social media assets | Generar videos para Instagram/TikTok con datos |
| Product demos | Videos animados de features con datos reales |
| Reportes animados | Dashboards que se animan como video |
| Invitaciones | Videos personalizados por destinatario |
| Showreels | Portfolio de proyectos como motion reel |
| Tutoriales | Code walkthroughs animados |

## Performance Tips

- Usar `staticFile()` para assets (no imports directos)
- `delayRender()` / `continueRender()` para datos async
- Renderizado paralelo: `--concurrency=4` para mas velocidad
- Usar `@remotion/lambda` para renderizar en AWS (masivo)
- Evitar re-renders: memoizar componentes pesados
