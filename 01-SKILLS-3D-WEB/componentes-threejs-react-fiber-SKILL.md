---
name: threejs-react-components
description: "Biblioteca de componentes Three.js + React Three Fiber para webs 3D. Usar cuando el usuario pida: esferas 3D con texturas, campos de estrellas, modelos glTF, partículas WebGL, Earth 3D, floating objects, orbit controls, canvas loader, luces y sombras, icosaedros, point clouds, animaciones useFrame. Incluye: 8 componentes R3F copy-paste, configuración Canvas optimizada, detección móvil con fallback, y reglas de rendimiento WebGL."
---

---
name: threejs-react-components
description: "Biblioteca de componentes Three.js + React Three Fiber para webs 3D. Usar cuando el usuario pida: esferas 3D con texturas, campos de estrellas, modelos glTF, partículas WebGL, Earth 3D, floating objects, orbit controls, canvas loader, luces y sombras, icosaedros, point clouds, animaciones useFrame. Incluye: 8 componentes R3F copy-paste, configuración Canvas optimizada, detección móvil con fallback, y reglas de rendimiento WebGL."
---

# Three.js React Components — Biblioteca R3F para Webs 3D

## Cuándo Usar

Activar cuando el usuario necesite:
- Componentes Three.js en React (R3F)
- Esferas 3D flotantes con iconos/texturas
- Campos de estrellas o partículas
- Modelos 3D glTF/GLB cargados en web
- Earth/planeta 3D con auto-rotación
- Cualquier escena WebGL en una web React

## Dependencias

```bash
npm install three @react-three/fiber @react-three/drei maath
npm install -D @types/three
```

---

## Componente 1: Canvas Wrapper (Base para todo)

SIEMPRE usar este wrapper. NUNCA crear Canvas sin estas configuraciones:

```tsx
import { Suspense } from "react";
import { Canvas } from "@react-three/fiber";
import { Preload } from "@react-three/drei";

const Scene3D = ({ children }: { children: React.ReactNode }) => (
  <Canvas
    frameloop="demand"    // Solo renderiza cuando hay interacción
    dpr={[1, 2]}          // Cap DPR para rendimiento
    gl={{ preserveDrawingBuffer: true }}
    camera={{ position: [0, 0, 5], fov: 45 }}
  >
    <Suspense fallback={<CanvasLoader />}>
      {children}
    </Suspense>
    <Preload all />
  </Canvas>
);
```

**REGLA**: En móvil (<640px), NO renderizar Canvas. Usar fallback flat:
```tsx
const [isMobile, setIsMobile] = useState(false);
useEffect(() => {
  const mq = window.matchMedia("(max-width: 640px)");
  setIsMobile(mq.matches);
  const handler = (e: MediaQueryListEvent) => setIsMobile(e.matches);
  mq.addEventListener("change", handler);
  return () => mq.removeEventListener("change", handler);
}, []);

return isMobile ? <FlatFallback /> : <Scene3D>...</Scene3D>;
```

---

## Componente 2: Canvas Loader

```tsx
import { Html, useProgress } from "@react-three/drei";

const CanvasLoader = () => {
  const { progress } = useProgress();
  return (
    <Html as="div" center>
      <div className="three-body">
        <div className="three-body__dot" />
        <div className="three-body__dot" />
        <div className="three-body__dot" />
      </div>
      <p className="mt-4 text-sm font-mono text-accent">{progress.toFixed(0)}%</p>
    </Html>
  );
};
```

---

## Componente 3: Floating Ball con Textura (Tech Icons)

Icosaedro flotante con una imagen decal (logo de tecnología):

```tsx
import { Float, Decal, useTexture, OrbitControls } from "@react-three/drei";

const Ball = ({ imgUrl }: { imgUrl: string }) => {
  const [decal] = useTexture([imgUrl]);
  return (
    <Float speed={1.75} rotationIntensity={1} floatIntensity={2}>
      <ambientLight intensity={0.25} />
      <directionalLight position={[0, 0, 0.05]} />
      <mesh castShadow receiveShadow scale={2.75}>
        <icosahedronGeometry args={[1, 1]} />
        <meshStandardMaterial
          color="#0f0f1a"
          polygonOffset
          polygonOffsetFactor={-5}
          flatShading
        />
        <Decal position={[0, 0, 1]} rotation={[2 * Math.PI, 0, 6.25]} scale={1} map={decal} />
      </mesh>
    </Float>
  );
};

const BallCanvas = ({ icon }: { icon: string }) => (
  <Canvas frameloop="demand" dpr={[1, 2]} gl={{ preserveDrawingBuffer: true }}>
    <Suspense fallback={null}>
      <OrbitControls enablePan={false} enableZoom={false} />
      <Ball imgUrl={icon} />
    </Suspense>
    <Preload all />
  </Canvas>
);
```

Uso:
```tsx
<div className="w-28 h-28">
  <BallCanvas icon="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg" />
</div>
```

---

## Componente 4: Star Field (Partículas Animadas)

```tsx
import { useRef, useState } from "react";
import { useFrame } from "@react-three/fiber";
import { Points, PointMaterial } from "@react-three/drei";
import { random } from "maath";

const Stars = () => {
  const ref = useRef<any>(null);
  const [sphere] = useState(() =>
    random.inSphere(new Float32Array(6000), { radius: 1.2 }) as Float32Array
  );

  useFrame((_state, delta) => {
    if (ref.current) {
      ref.current.rotation.x -= delta / 10;
      ref.current.rotation.y -= delta / 15;
    }
  });

  return (
    <group rotation={[0, 0, Math.PI / 4]}>
      <Points ref={ref} positions={sphere} stride={3} frustumCulled>
        <PointMaterial
          transparent
          color="#00f0ff"
          size={0.002}
          sizeAttenuation
          depthWrite={false}
        />
      </Points>
    </group>
  );
};
```

Personalización: cambiar `color` para diferentes vibes, `size` para densidad, `radius` para dispersión.

---

## Componente 5: Modelo glTF

```tsx
import { useGLTF, OrbitControls } from "@react-three/drei";

const Model = ({ path, scale = 1, position = [0, 0, 0] }: {
  path: string; scale?: number; position?: [number, number, number]
}) => {
  const { scene } = useGLTF(path);
  return <primitive object={scene} scale={scale} position={position} />;
};

const ModelCanvas = ({ modelPath }: { modelPath: string }) => (
  <Canvas shadows frameloop="demand" dpr={[1, 2]}
    camera={{ fov: 45, near: 0.1, far: 200, position: [-4, 3, 6] }}>
    <Suspense fallback={<CanvasLoader />}>
      <OrbitControls autoRotate enablePan={false} enableZoom={false}
        maxPolarAngle={Math.PI / 2} minPolarAngle={Math.PI / 2} />
      <Model path={modelPath} scale={2.5} />
    </Suspense>
    <Preload all />
  </Canvas>
);
```

---

## Componente 6: Computer Desktop (Hero 3D)

```tsx
const Computers = ({ isMobile }: { isMobile: boolean }) => {
  const computer = useGLTF("./desktop_pc/scene.gltf");
  return (
    <mesh>
      <hemisphereLight intensity={0.15} groundColor="black" />
      <spotLight position={[-20, 50, 10]} angle={0.12} penumbra={1}
        intensity={1} castShadow shadow-mapSize={1024} />
      <pointLight intensity={1} />
      <primitive
        object={computer.scene}
        scale={isMobile ? 0.7 : 0.75}
        position={isMobile ? [0, -3, -2.2] : [0, -4.25, -1.5]}
        rotation={[-0.01, -0.2, -0.1]}
      />
    </mesh>
  );
};
```

---

## Componente 7: Luces Estándar

Setup de iluminación que funciona para el 90% de las escenas:

```tsx
const StandardLighting = () => (
  <>
    <ambientLight intensity={0.25} />
    <hemisphereLight intensity={0.15} groundColor="black" />
    <directionalLight position={[5, 5, 5]} intensity={0.5} />
    <pointLight position={[-5, -5, -5]} intensity={0.3} color="#00f0ff" />
    <spotLight position={[-20, 50, 10]} angle={0.12} penumbra={1}
      intensity={1} castShadow shadow-mapSize={1024} />
  </>
);
```

---

## Componente 8: Escena Completa Ejemplo

```tsx
const PortfolioScene = () => (
  <Canvas frameloop="demand" dpr={[1, 2]} shadows
    camera={{ position: [20, 3, 5], fov: 25 }}
    gl={{ preserveDrawingBuffer: true }}>
    <Suspense fallback={<CanvasLoader />}>
      <OrbitControls enablePan={false} enableZoom={false}
        maxPolarAngle={Math.PI / 2} minPolarAngle={Math.PI / 2} />
      <StandardLighting />
      <Model path="./model/scene.gltf" scale={0.75} position={[0, -4.25, -1.5]} />
    </Suspense>
    <Preload all />
  </Canvas>
);
```

---

## Reglas de Rendimiento WebGL

| Regla | Valor | Por qué |
|-------|-------|---------|
| `frameloop` | `"demand"` | No renderiza sin interacción = 0 GPU idle |
| `dpr` | `[1, 2]` | Cap en 2x para retina, evita 3x+ |
| `preserveDrawingBuffer` | `true` | Necesario para screenshots/export |
| Móvil <640px | Skip Canvas | WebGL drena batería en móvil |
| `Preload all` | Siempre último | Precarga texturas/modelos |
| `Suspense` | Siempre wrapper | Muestra loader mientras carga |
| Polycount | <50K por modelo | Más = lag en mid-range devices |
| Texturas | Max 2048x2048 | Usar ktx2 o webp si posible |
| Shadows | Solo desktop | `castShadow` costoso en móvil |

## URLs de Iconos para Tech Balls

```ts
const TECH_ICONS = {
  react: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg",
  typescript: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/typescript/typescript-original.svg",
  threejs: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/threejs/threejs-original.svg",
  nextjs: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nextjs/nextjs-original.svg",
  nodejs: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg",
  tailwind: "https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/tailwindcss/tailwindcss-original.svg",
  blender: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/blender/blender-original.svg",
  docker: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg",
  postgresql: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/postgresql/postgresql-original.svg",
  git: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg",
  figma: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/figma/figma-original.svg",
  python: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg",
};
```