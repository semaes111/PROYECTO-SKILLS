---
name: babylonjs-game-engine
description: >
  Babylon.js — game engine completo para la web. WebGPU nativo, PBR
  materials, Havok physics, GUI 3D, Node Material Editor, XR/AR/VR.
  Motor de nivel AAA para experiencias web interactivas complejas.
  Usar cuando: Babylon.js, game engine web, WebGPU game, PBR web,
  Havok physics, Node Material, XR web, juego 3D navegador.
triggers:
  - "Babylon.js"
  - "BabylonJS"
  - "game engine web"
  - "WebGPU game"
  - "Havok physics"
  - "Node Material Editor"
  - "juego 3D navegador"
  - "XR web"
type: reference
---

# Babylon.js — Game Engine Completo para la Web

## Que Es

Babylon.js es un motor 3D/game engine open-source de Microsoft para
la web. Soporte nativo de WebGPU (primera engine en implementarlo),
fisicas Havok, materiales PBR, sistema de particulas avanzado, GUI 3D,
WebXR, y herramientas visuales (Node Material Editor, Playground).

**Repositorio**: https://github.com/BabylonJS/Babylon.js (23K+ stars)
**Version actual**: 8.x (con WebGPU estable)
**Playground**: https://playground.babylonjs.com

## Instalacion

```bash
npm install @babylonjs/core @babylonjs/loaders
# Opcional
npm install @babylonjs/gui           # GUI 2D/3D
npm install @babylonjs/materials     # Materiales avanzados
npm install @babylonjs/inspector     # Debug inspector
npm install @babylonjs/havok         # Fisicas Havok
```

## Setup Basico

```typescript
import { Engine, Scene, ArcRotateCamera, HemisphericLight, Vector3, MeshBuilder } from '@babylonjs/core'

// Canvas HTML
const canvas = document.getElementById('renderCanvas') as HTMLCanvasElement

// Motor de renderizado
const engine = new Engine(canvas, true, {
  preserveDrawingBuffer: true,
  stencil: true,
})

// Escena
const scene = new Scene(engine)
scene.clearColor = new BABYLON.Color4(0.05, 0.05, 0.1, 1)

// Camara orbital
const camera = new ArcRotateCamera('camera', Math.PI / 4, Math.PI / 3, 10, Vector3.Zero(), scene)
camera.attachControl(canvas, true)
camera.lowerRadiusLimit = 5
camera.upperRadiusLimit = 20

// Luz
const light = new HemisphericLight('light', new Vector3(0, 1, 0), scene)
light.intensity = 0.8

// Mesh basico
const sphere = MeshBuilder.CreateSphere('sphere', { diameter: 2, segments: 32 }, scene)

// Render loop
engine.runRenderLoop(() => {
  scene.render()
})

// Resize
window.addEventListener('resize', () => engine.resize())
```

## WebGPU Renderer

```typescript
import { WebGPUEngine } from '@babylonjs/core'

// WebGPU engine (asincrono)
const engine = new WebGPUEngine(canvas)
await engine.initAsync()

// El resto es identico — Scene, Camera, etc.
const scene = new Scene(engine)

// Beneficios WebGPU:
// - 2-3x mas rendimiento en scenes complejos
// - Compute shaders nativos
// - Mejor manejo de draw calls
// - Storage buffers para particulas masivas
```

## PBR Materials — Physically Based Rendering

```typescript
import { PBRMaterial, Color3, Texture, CubeTexture } from '@babylonjs/core'

const pbr = new PBRMaterial('pbr', scene)

// Metalico
pbr.metallic = 1.0                    // 0 = dielectrico, 1 = metalico
pbr.roughness = 0.2                   // 0 = espejo, 1 = mate
pbr.albedoColor = new Color3(0.95, 0.64, 0.37)  // Color cobre

// Texturas
pbr.albedoTexture = new Texture('textures/albedo.jpg', scene)
pbr.bumpTexture = new Texture('textures/normal.jpg', scene)
pbr.metallicTexture = new Texture('textures/metallic.jpg', scene)
pbr.ambientTexture = new Texture('textures/ao.jpg', scene)

// Environment map (reflejos)
const envTexture = CubeTexture.CreateFromPrefilteredData('textures/environment.env', scene)
scene.environmentTexture = envTexture

// Clearcoat (capa superior brillante, como barniz)
pbr.clearCoat.isEnabled = true
pbr.clearCoat.intensity = 0.8
pbr.clearCoat.roughness = 0.1

// Subsurface scattering (piel, cera, marmol)
pbr.subSurface.isTranslucencyEnabled = true
pbr.subSurface.translucencyIntensity = 0.5
pbr.subSurface.tintColor = new Color3(1, 0.5, 0.5)

sphere.material = pbr
```

## Havok Physics

```typescript
import HavokPhysics from '@babylonjs/havok'
import { HavokPlugin, PhysicsAggregate, PhysicsShapeType } from '@babylonjs/core'

// Inicializar Havok (WASM)
const havokInstance = await HavokPhysics()
const havokPlugin = new HavokPlugin(true, havokInstance)
scene.enablePhysics(new Vector3(0, -9.81, 0), havokPlugin)

// Suelo con fisicas
const ground = MeshBuilder.CreateGround('ground', { width: 20, height: 20 }, scene)
new PhysicsAggregate(ground, PhysicsShapeType.BOX, {
  mass: 0,  // Estatico
  friction: 0.5,
  restitution: 0.3,
}, scene)

// Esfera con fisicas
const ball = MeshBuilder.CreateSphere('ball', { diameter: 1 }, scene)
ball.position.y = 5
const ballAggregate = new PhysicsAggregate(ball, PhysicsShapeType.SPHERE, {
  mass: 1,
  friction: 0.5,
  restitution: 0.7,  // Rebote
}, scene)

// Aplicar impulso
ballAggregate.body.applyImpulse(
  new Vector3(2, 5, 0),   // Fuerza
  ball.position             // Punto de aplicacion
)

// Detectar colisiones
ballAggregate.body.setCollisionCallbackEnabled(true)
scene.onAfterPhysicsObservable.add(() => {
  // Check collisions via observable
})
```

## Node Material Editor — Shaders Visuales

```typescript
import { NodeMaterial } from '@babylonjs/core'

// Cargar material creado en el Node Material Editor
// URL: https://nme.babylonjs.com
const nodeMaterial = await NodeMaterial.ParseFromSnippetAsync('snippet-id', scene)
sphere.material = nodeMaterial

// Acceder a inputs del material
const timeInput = nodeMaterial.getInputBlockByPredicate(b => b.name === 'Time')
if (timeInput) {
  scene.registerBeforeRender(() => {
    timeInput.value += engine.getDeltaTime() / 1000
  })
}

// Crear Node Material por codigo
const nm = new NodeMaterial('custom', scene)
// (Normalmente se usa el editor visual y se exporta)
```

## Sistema de Particulas

```typescript
import { ParticleSystem, Texture, Color4, Vector3 } from '@babylonjs/core'

const particles = new ParticleSystem('particles', 2000, scene)

// Textura de particula
particles.particleTexture = new Texture('textures/flare.png', scene)

// Emisor
particles.emitter = new Vector3(0, 1, 0)
particles.minEmitBox = new Vector3(-0.5, 0, -0.5)
particles.maxEmitBox = new Vector3(0.5, 0, 0.5)

// Colores (ciclo de vida)
particles.color1 = new Color4(1, 0.5, 0, 1)      // Naranja
particles.color2 = new Color4(1, 0, 0, 1)          // Rojo
particles.colorDead = new Color4(0.2, 0, 0, 0)     // Oscuro con fade

// Tamano
particles.minSize = 0.1
particles.maxSize = 0.5
particles.minLifeTime = 0.5
particles.maxLifeTime = 2.0

// Velocidad
particles.emitRate = 200
particles.direction1 = new Vector3(-1, 2, -1)
particles.direction2 = new Vector3(1, 4, 1)
particles.gravity = new Vector3(0, -9.81, 0)

// Blend mode
particles.blendMode = ParticleSystem.BLENDMODE_ADD  // Brillo aditivo

particles.start()
```

## GUI — Interfaz 2D sobre 3D

```typescript
import { AdvancedDynamicTexture, Button, StackPanel, TextBlock } from '@babylonjs/gui'

// GUI fullscreen (2D overlay)
const gui = AdvancedDynamicTexture.CreateFullscreenUI('ui')

// Boton
const button = Button.CreateSimpleButton('btn', 'Click Me')
button.width = '200px'
button.height = '50px'
button.color = 'white'
button.background = '#ff6b6b'
button.cornerRadius = 10
button.onPointerUpObservable.add(() => {
  console.log('Clicked!')
})
gui.addControl(button)

// Texto
const text = new TextBlock('label', 'Babylon.js Scene')
text.color = 'white'
text.fontSize = 24
text.top = '-40%'
gui.addControl(text)

// GUI en textura 3D (en un plano dentro de la escena)
const plane = MeshBuilder.CreatePlane('guiPlane', { width: 2, height: 1 }, scene)
const gui3D = AdvancedDynamicTexture.CreateForMesh(plane)
```

## Cargar Modelos glTF/GLB

```typescript
import '@babylonjs/loaders/glTF'
import { SceneLoader } from '@babylonjs/core'

// Cargar modelo
const result = await SceneLoader.ImportMeshAsync(
  '',                          // Nombres de mesh ('' = todos)
  'models/',                   // Path base
  'robot.glb',               // Archivo
  scene
)

const model = result.meshes[0]
model.scaling = new Vector3(0.5, 0.5, 0.5)
model.position.y = 0

// Animaciones del modelo
const animations = result.animationGroups
if (animations.length > 0) {
  animations[0].start(true)  // Loop primera animacion
}
```

## React Integration

```tsx
import { useEffect, useRef } from 'react'
import { Engine, Scene, ArcRotateCamera, HemisphericLight, Vector3, MeshBuilder } from '@babylonjs/core'

function BabylonScene() {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    if (!canvasRef.current) return

    const engine = new Engine(canvasRef.current, true)
    const scene = new Scene(engine)

    const camera = new ArcRotateCamera('cam', 0, Math.PI / 3, 10, Vector3.Zero(), scene)
    camera.attachControl(canvasRef.current, true)

    new HemisphericLight('light', new Vector3(0, 1, 0), scene)

    const sphere = MeshBuilder.CreateSphere('sphere', { diameter: 2 }, scene)

    engine.runRenderLoop(() => scene.render())

    const handleResize = () => engine.resize()
    window.addEventListener('resize', handleResize)

    return () => {
      window.removeEventListener('resize', handleResize)
      engine.dispose()
    }
  }, [])

  return <canvas ref={canvasRef} style={{ width: '100%', height: '100vh' }} />
}
```

## Babylon.js vs Three.js

| Feature | Babylon.js | Three.js |
|---------|-----------|----------|
| WebGPU | Nativo, estable | Experimental |
| Fisicas | Havok (AAA) | Cannon/Rapier (community) |
| GUI | Built-in | Ninguno (usar HTML) |
| Editor visual | Node Material Editor | NO |
| Playground | SI (online) | NO |
| Inspector/Debug | Built-in | Lil-gui manual |
| Bundle size | ~800KB | ~150KB |
| Ecosistema React | Basico | R3F (excelente) |
| Documentacion | Excelente | Buena |
| Caso ideal | Juegos, apps complejas | Webs, portfolios, landing |

## Performance Tips

- Usar WebGPU cuando disponible (2-3x mas rapido)
- `scene.freezeActiveMeshes()` para escenas estaticas
- LOD (Level of Detail) para modelos lejanos
- Instanced meshes para objetos repetidos
- `engine.setHardwareScalingLevel(2)` en mobile para bajar resolucion
- Havok WASM se carga async — mostrar loading state
- Usar `scene.performancePriority` para auto-optimizacion
