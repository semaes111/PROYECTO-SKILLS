---
name: shaders-webgpu-threejs
description: >
  Shaders GLSL/WGSL con Three.js, WebGPURenderer, TSL (Three Shading Language),
  ShaderGradient y postprocessing. Escribir materiales custom, efectos visuales
  y gradientes animados para webs de alto nivel grafico.
  Usar cuando: shader, GLSL, WGSL, WebGPU, ShaderMaterial, postprocessing,
  gradiente animado, ShaderGradient, TSL, node material, fragment shader.
triggers:
  - "shader"
  - "GLSL"
  - "WebGPU"
  - "ShaderMaterial"
  - "ShaderGradient"
  - "TSL"
  - "fragment shader"
  - "postprocessing"
type: reference
---

# Shaders WebGPU + Three.js — Materiales y Efectos Visuales Custom

## Arquitectura de Shaders en Three.js

```
Three.js Shader Pipeline:
┌─────────────────┐     ┌──────────────────┐     ┌────────────────┐
│ ShaderMaterial   │     │ NodeMaterial     │     │ WebGPURenderer │
│ (GLSL raw)      │     │ (TSL nodes)      │     │ (WGSL output)  │
│ vertexShader     │     │ colorNode        │     │ compute shaders│
│ fragmentShader   │     │ positionNode     │     │ storage buffers│
└─────────────────┘     └──────────────────┘     └────────────────┘
       ↓ WebGLRenderer         ↓ Ambos renderers        ↓ Solo WebGPU
```

## ShaderMaterial — GLSL Clasico

```javascript
import * as THREE from 'three'

const material = new THREE.ShaderMaterial({
  uniforms: {
    uTime: { value: 0 },
    uResolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
    uMouse: { value: new THREE.Vector2(0.5, 0.5) },
    uColor1: { value: new THREE.Color('#ff6b6b') },
    uColor2: { value: new THREE.Color('#4ecdc4') },
    uTexture: { value: texture },
  },
  vertexShader: `
    varying vec2 vUv;
    varying vec3 vPosition;
    varying vec3 vNormal;
    uniform float uTime;

    void main() {
      vUv = uv;
      vPosition = position;
      vNormal = normal;

      // Deformacion ondulada
      vec3 pos = position;
      pos.z += sin(pos.x * 3.0 + uTime) * 0.2;
      pos.z += cos(pos.y * 2.0 + uTime * 0.7) * 0.15;

      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    }
  `,
  fragmentShader: `
    uniform float uTime;
    uniform vec2 uResolution;
    uniform vec2 uMouse;
    uniform vec3 uColor1;
    uniform vec3 uColor2;
    varying vec2 vUv;

    void main() {
      // Gradiente animado con noise
      float gradient = sin(vUv.x * 6.28 + uTime) * 0.5 + 0.5;
      vec3 color = mix(uColor1, uColor2, gradient);

      // Distancia al mouse
      float dist = distance(vUv, uMouse);
      color += 0.1 / dist * 0.05;

      gl_FragColor = vec4(color, 1.0);
    }
  `,
  transparent: true,
  side: THREE.DoubleSide,
})

// Actualizar uniforms en el render loop
function animate(time) {
  material.uniforms.uTime.value = time * 0.001
  requestAnimationFrame(animate)
  renderer.render(scene, camera)
}
```

## RawShaderMaterial — Control Total

```javascript
// Sin prefijos automaticos — tu escribes TODO
const rawMaterial = new THREE.RawShaderMaterial({
  uniforms: {
    uTime: { value: 0 },
  },
  vertexShader: `
    precision highp float;
    attribute vec3 position;
    attribute vec2 uv;
    uniform mat4 projectionMatrix;
    uniform mat4 modelViewMatrix;
    varying vec2 vUv;

    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    precision highp float;
    uniform float uTime;
    varying vec2 vUv;

    void main() {
      gl_FragColor = vec4(vUv, sin(uTime) * 0.5 + 0.5, 1.0);
    }
  `,
})
```

## Funciones GLSL Esenciales para Webs Premium

```glsl
// ===== NOISE — Simplex/Perlin =====
// Incluir via glslify: #pragma glslify: snoise = require(glsl-noise/simplex/3d)
// O copiar la funcion directamente

// Simplex 2D noise (copy-paste ready)
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                      -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy));
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod289(i);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m; m = m*m;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// ===== UTILIDADES =====
// Remap value
float remap(float value, float low1, float high1, float low2, float high2) {
  return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

// Smooth min (para blobs/metaballs)
float smin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}
```

## TSL — Three Shading Language (Node-Based)

```javascript
// TSL es el futuro de shaders en Three.js
// Funciona con WebGLRenderer Y WebGPURenderer
import {
  uniform, attribute, varying, vec2, vec3, vec4, float,
  color, texture, uv, time, position, normal,
  sin, cos, mix, smoothstep, step, length, distance,
  MeshStandardNodeMaterial, MeshPhysicalNodeMaterial,
} from 'three/tsl'

// Material con TSL nodes
const material = new MeshStandardNodeMaterial()

// Uniforms reactivos
const uColor1 = uniform(color('#ff6b6b'))
const uColor2 = uniform(color('#4ecdc4'))
const uStrength = uniform(float(1.0))

// Gradiente animado
const gradient = sin(uv().x.mul(6.28).add(time)).mul(0.5).add(0.5)
material.colorNode = mix(uColor1, uColor2, gradient)

// Desplazamiento de vertices
const wave = sin(position.x.mul(3).add(time)).mul(uStrength.mul(0.2))
material.positionNode = position.add(vec3(0, 0, wave))

// Emision basada en Fresnel
const fresnel = float(1).sub(normal.dot(vec3(0, 0, 1)).abs()).pow(3)
material.emissiveNode = color('#ffffff').mul(fresnel.mul(0.5))
```

## WebGPURenderer — Setup

```javascript
import * as THREE from 'three/webgpu'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'

// WebGPURenderer se importa del bundle webgpu
const renderer = new THREE.WebGPURenderer({ antialias: true })
renderer.setSize(window.innerWidth, window.innerHeight)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
document.body.appendChild(renderer.domElement)

// Inicializar WebGPU (asincrono)
await renderer.init()

// El resto es identico a WebGLRenderer
const scene = new THREE.Scene()
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 100)

function animate() {
  renderer.render(scene, camera)
}
renderer.setAnimationLoop(animate)
```

## Compute Shaders (Solo WebGPU)

```javascript
import { compute, storage, instanceIndex, float } from 'three/tsl'

// Buffer de particulas
const count = 100000
const positionBuffer = new THREE.StorageInstancedBufferAttribute(
  new Float32Array(count * 3), 3
)

// Compute shader para actualizar particulas
const computeParticles = compute(() => {
  const pos = storage(positionBuffer, 'vec3', count).element(instanceIndex)
  const t = time
  pos.x.assign(sin(instanceIndex.toFloat().mul(0.01).add(t)).mul(10))
  pos.y.assign(cos(instanceIndex.toFloat().mul(0.013).add(t)).mul(10))
  pos.z.assign(sin(instanceIndex.toFloat().mul(0.017).add(t.mul(0.5))).mul(10))
}, count)

// Ejecutar en el loop
function animate() {
  renderer.compute(computeParticles)
  renderer.render(scene, camera)
}
```

## ShaderGradient — Gradientes 3D Animados

```bash
npm install shadergradient three @react-three/fiber
```

```tsx
// Componente React listo para usar
import { ShaderGradient, ShaderGradientCanvas } from 'shadergradient'

function AnimatedBackground() {
  return (
    <ShaderGradientCanvas
      style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', zIndex: -1 }}
      pointerEvents="none"
    >
      <ShaderGradient
        type="waterPlane"           // waterPlane | plane | sphere
        animate="on"
        uTime={0}
        uSpeed={0.3}               // Velocidad de animacion
        uStrength={3}              // Intensidad de deformacion
        uDensity={1.5}             // Densidad del patron
        uFrequency={5.5}           // Frecuencia del noise
        // Colores del gradiente
        color1="#ff6b6b"
        color2="#4ecdc4"
        color3="#45b7d1"
        // Camara
        cAzimuthAngle={180}
        cPolarAngle={90}
        cDistance={3}
        cameraZoom={1}
        // Entorno
        brightness={1.2}
        grain="off"
        lightType="3d"
        envPreset="city"
      />
    </ShaderGradientCanvas>
  )
}
```

```tsx
// Con URL preset (compartible)
<ShaderGradient
  urlString="https://www.shadergradient.co/customize?type=waterPlane&animate=on&uTime=0&uSpeed=0.3&uStrength=3&uDensity=1.5&uFrequency=5.5&color1=%23ff6b6b&color2=%234ecdc4&color3=%2345b7d1"
/>
```

## Post-Processing con Shaders

```javascript
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js'

const composer = new EffectComposer(renderer)
composer.addPass(new RenderPass(scene, camera))

// Shader custom de post-processing
const chromaticAberration = {
  uniforms: {
    tDiffuse: { value: null },
    uOffset: { value: 0.003 },
  },
  vertexShader: `
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform sampler2D tDiffuse;
    uniform float uOffset;
    varying vec2 vUv;
    void main() {
      float r = texture2D(tDiffuse, vUv + vec2(uOffset, 0.0)).r;
      float g = texture2D(tDiffuse, vUv).g;
      float b = texture2D(tDiffuse, vUv - vec2(uOffset, 0.0)).b;
      gl_FragColor = vec4(r, g, b, 1.0);
    }
  `,
}

composer.addPass(new ShaderPass(chromaticAberration))

// En el loop: composer.render() en lugar de renderer.render()
```

## Patron: Blob Organico Animado (Awwwards-Level)

```javascript
const blobMaterial = new THREE.ShaderMaterial({
  uniforms: {
    uTime: { value: 0 },
    uHover: { value: 0 },  // 0 a 1, animado con GSAP
  },
  vertexShader: `
    uniform float uTime;
    uniform float uHover;
    varying vec3 vNormal;
    varying vec2 vUv;

    // Incluir snoise aqui...

    void main() {
      vUv = uv;
      vNormal = normal;

      float noise = snoise(vec3(
        position.x * 1.5 + uTime * 0.3,
        position.y * 1.5 + uTime * 0.2,
        position.z * 1.5
      ));

      vec3 pos = position + normal * noise * (0.15 + uHover * 0.1);
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    }
  `,
  fragmentShader: `
    varying vec3 vNormal;
    varying vec2 vUv;

    void main() {
      // Fresnel iridiscente
      float fresnel = pow(1.0 - abs(dot(vNormal, vec3(0.0, 0.0, 1.0))), 3.0);
      vec3 color = mix(
        vec3(0.1, 0.05, 0.2),   // Centro oscuro
        vec3(1.0, 0.4, 0.8),    // Borde brillante
        fresnel
      );
      gl_FragColor = vec4(color, 0.9);
    }
  `,
  transparent: true,
})

// Geometria: IcosahedronGeometry con subdivisions altas
const geometry = new THREE.IcosahedronGeometry(1, 64)
const blob = new THREE.Mesh(geometry, blobMaterial)
```

## Performance Shaders

- Minimizar `texture2D` lookups en fragment shader
- Usar `lowp`/`mediump` donde sea posible en mobile
- Compute shaders (WebGPU) para particulas masivas (100K+)
- Evitar branching (`if/else`) — usar `mix()` y `step()`
- Pre-calcular en vertex shader, interpolar via `varying`
- WebGPURenderer: 2-3x mas eficiente que WebGL para scenes complejos
