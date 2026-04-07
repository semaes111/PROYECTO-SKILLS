---
name: 3d-web-builder
description: "Sistema completo para construir webs 3D inmersivas con React + Three.js + GSAP + Framer Motion + Tailwind. Usar cuando el usuario pida: crear web 3D, portfolio inmersivo, landing page animada, sitio con efectos de scroll, web con partículas, web interactiva, web con WebGL, componentes Three.js, animaciones GSAP, bento grid, hero con video, preloader animado, cursor personalizado, parallax, tilt cards. Incluye: arquitectura completa, patrones de componentes, design system, animaciones, 3D canvas, optimización rendimiento."
---

---
name: 3d-web-builder
description: "Sistema completo para construir webs 3D inmersivas con React + Three.js + GSAP + Framer Motion + Tailwind. Usar cuando el usuario pida: crear web 3D, portfolio inmersivo, landing page animada, sitio con efectos de scroll, web con partículas, web interactiva, web con WebGL, componentes Three.js, animaciones GSAP, bento grid, hero con video, preloader animado, cursor personalizado, parallax, tilt cards. Incluye: arquitectura completa, patrones de componentes, design system, animaciones, 3D canvas, optimización rendimiento."
---

# 3D Web Builder — Sistema Completo de Construcción de Webs 3D Inmersivas

## Cuándo Usar Esta Skill

Activar cuando el usuario solicite:
- Crear una web 3D, portfolio, landing page inmersiva
- Implementar efectos Three.js, WebGL, partículas, modelos 3D
- Animaciones GSAP ScrollTrigger, Framer Motion
- Layouts tipo bento grid, hero con video, secciones con clip-path
- Preloaders, cursores elásticos, parallax, tilt cards
- Cualquier web que combine 3D + animación + diseño premium

---

## Stack Tecnológico Obligatorio

| Capa | Tecnología | Versión | Rol |
|------|------------|---------|-----|
| Framework | React + TypeScript | 18+ | Componentes tipados |
| Build | Vite | 6+ | Dev server + bundling |
| 3D Engine | Three.js | r161+ | Renderizado WebGL |
| 3D React | @react-three/fiber + drei | 8+ / 9+ | React bindings para Three.js |
| Animación | GSAP + @gsap/react | 3.14+ | ScrollTrigger, timelines |
| Animación | Framer Motion | 11+ | Enter/exit, whileInView |
| Styling | Tailwind CSS | 3.4+ | Utilidades + tema custom |
| Utilities | clsx + tailwind-merge | Latest | Merge de clases via cn() |
| Icons | react-icons | 5+ | Iconos (Fa, Ti families) |
| Math | maath | 0.10+ | Distribuciones aleatorias para partículas |

### Inicialización del Proyecto

```bash
npm create vite@latest mi-proyecto -- --template react-ts
cd mi-proyecto
npm install @react-three/fiber @react-three/drei three gsap @gsap/react framer-motion maath react-icons react-use react-vertical-timeline-component clsx tailwind-merge
npm install -D @types/three tailwindcss autoprefixer postcss
```

---

## Arquitectura de Archivos

```
src/
├── components/
│   ├── canvas/           # Componentes Three.js / R3F
│   │   ├── Ball.tsx      # Icosaedro flotante con textura decal
│   │   ├── Stars.tsx     # Campo de estrellas animado
│   │   ├── Loader.tsx    # Loading indicator para Canvas
│   │   └── index.ts      # Barrel exports
│   ├── layout/           # Wrappers de app
│   │   ├── Navbar.tsx    # Nav flotante con auto-hide en scroll
│   │   ├── Footer.tsx    # Footer con social links
│   │   └── Preloader.tsx # Pantalla de carga con GSAP
│   ├── sections/         # Secciones de página
│   │   ├── Hero.tsx      # Hero con video/3D + clip-path GSAP
│   │   ├── About.tsx     # About con clip expanding animation
│   │   ├── Features.tsx  # Bento grid con tilt 3D
│   │   ├── Experience.tsx # Timeline vertical
│   │   ├── Tech.tsx      # Grid de esferas 3D con iconos
│   │   ├── Projects.tsx  # Cards con tilt + hover effects
│   │   ├── Story.tsx     # Imagen tilt + SVG filter mask
│   │   └── Contact.tsx   # Formulario + decoraciones clip-path
│   └── ui/               # Componentes UI reutilizables
│       ├── Button.tsx    # Botón con iconos left/right
│       ├── AnimatedTitle.tsx  # Título 3D reveal por palabras
│       ├── ElasticCursor.tsx  # Cursor blob con GSAP physics
│       └── RoundedCorners.tsx # SVG gooey filter
├── constants/
│   └── index.ts          # TODA la data del portfolio
├── hooks/                # Custom hooks
├── lib/
│   └── utils.ts          # cn() = clsx + twMerge
├── index.css             # Estilos globales + utilidades
├── App.tsx               # Composición raíz
└── main.tsx              # Entry point
```

---

## Patrón: Nueva Sección

Toda sección SIEMPRE sigue este esqueleto:

```tsx
import { motion } from "framer-motion";
import { useGSAP } from "@gsap/react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export const NombreSeccion = () => {
  useGSAP(() => {
    gsap.from(".mi-elemento", {
      opacity: 0, y: 50,
      scrollTrigger: {
        trigger: ".mi-elemento",
        start: "top 80%",
        toggleActions: "play none none reverse",
      },
    });
  });

  return (
    <section id="nombre-seccion" className="py-24 bg-primary">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <p className="font-general text-sm uppercase tracking-[0.3em] text-accent/60 mb-4">
            Subtítulo
          </p>
          <h2 className="font-display text-4xl md:text-5xl font-bold text-white">
            Título <span className="gradient-text">Destacado</span>
          </h2>
        </motion.div>

        {/* Contenido */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {/* Cards, content, etc. */}
        </div>
      </div>
    </section>
  );
};
```

---

## Patrón: Componente Canvas 3D

```tsx
import { Suspense } from "react";
import { Canvas } from "@react-three/fiber";
import { OrbitControls, Preload, Float, useTexture, Decal } from "@react-three/drei";

// Mesh interno (dentro del contexto Canvas)
const MiModelo = ({ textura }: { textura: string }) => {
  const [decal] = useTexture([textura]);
  return (
    <Float speed={1.75} rotationIntensity={1} floatIntensity={2}>
      <ambientLight intensity={0.25} />
      <directionalLight position={[0, 0, 0.05]} />
      <mesh castShadow receiveShadow scale={2.75}>
        <icosahedronGeometry args={[1, 1]} />
        <meshStandardMaterial color="#0f0f1a" polygonOffset polygonOffsetFactor={-5} flatShading />
        <Decal position={[0, 0, 1]} rotation={[2 * Math.PI, 0, 6.25]} scale={1} map={decal} />
      </mesh>
    </Float>
  );
};

// Wrapper Canvas (exportado)
const MiModeloCanvas = ({ icon }: { icon: string }) => (
  <Canvas frameloop="demand" dpr={[1, 2]} gl={{ preserveDrawingBuffer: true }}>
    <Suspense fallback={<CanvasLoader />}>
      <OrbitControls enablePan={false} enableZoom={false} />
      <MiModelo textura={icon} />
    </Suspense>
    <Preload all />
  </Canvas>
);
```

**Reglas Canvas:**
- SIEMPRE `frameloop="demand"` (no renderiza sin interacción)
- SIEMPRE `dpr={[1, 2]}` (cap DPR para rendimiento)
- SIEMPRE `<Suspense>` con fallback loader
- SIEMPRE `<Preload all />` al final
- En móvil (<640px): mostrar fallback flat, NO canvas 3D

---

## Patrón: Campo de Estrellas

```tsx
import { useRef, useState } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { Points, PointMaterial, Preload } from "@react-three/drei";
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
        <PointMaterial transparent color="#00f0ff" size={0.002} sizeAttenuation depthWrite={false} />
      </Points>
    </group>
  );
};
```

---

## Patrón: Hero con Video Transitions (GSAP)

```tsx
import { useGSAP } from "@gsap/react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/all";
gsap.registerPlugin(ScrollTrigger);

// Clip-path morphing en scroll
useGSAP(() => {
  gsap.set("#video-frame", {
    clipPath: "polygon(14% 0%, 72% 0%, 90% 90%, 0% 100%)",
    borderRadius: "0 0 40% 10%",
  });
  gsap.from("#video-frame", {
    clipPath: "polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%)",
    borderRadius: "0",
    ease: "power1.inOut",
    scrollTrigger: {
      trigger: "#video-frame",
      start: "center center",
      end: "bottom center",
      scrub: true,
    },
  });
});

// Video crossfade en click
useGSAP(() => {
  if (hasClicked) {
    gsap.set("#next-video", { visibility: "visible" });
    gsap.to("#next-video", {
      transformOrigin: "center center",
      scale: 1, width: "100%", height: "100%",
      duration: 1, ease: "power1.inOut",
      onStart: () => { nextVideoRef.current?.play(); },
    });
  }
}, { dependencies: [currentIndex], revertOnUpdate: true });
```

---

## Patrón: BentoTilt Card (Hover 3D)

```tsx
const BentoTilt = ({ children, className }: PropsWithChildren<{ className?: string }>) => {
  const [transformStyle, setTransformStyle] = useState("");
  const itemRef = useRef<HTMLDivElement>(null);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!itemRef.current) return;
    const { left, top, width, height } = itemRef.current.getBoundingClientRect();
    const tiltX = ((e.clientY - top) / height - 0.5) * 5;
    const tiltY = ((e.clientX - left) / width - 0.5) * -5;
    setTransformStyle(
      `perspective(700px) rotateX(${tiltX}deg) rotateY(${tiltY}deg) scale3d(0.98, 0.98, 0.98)`
    );
  };

  return (
    <div ref={itemRef} className={className}
      onMouseMove={handleMouseMove}
      onMouseLeave={() => setTransformStyle("")}
      style={{ transform: transformStyle }}>
      {children}
    </div>
  );
};
```

---

## Patrón: AnimatedTitle (Reveal 3D por Palabras)

```tsx
useEffect(() => {
  const ctx = gsap.context(() => {
    gsap.timeline({
      scrollTrigger: {
        trigger: containerRef.current,
        start: "100 bottom",
        end: "center bottom",
        toggleActions: "play none none reverse",
      },
    }).to(".animated-word", {
      opacity: 1,
      transform: "translate3d(0, 0, 0) rotateY(0deg) rotateX(0deg)",
      ease: "power2.inOut",
      stagger: 0.02,
    });
  }, containerRef);
  return () => ctx.revert();
}, []);
```

CSS requerido:
```css
.animated-word {
  font-weight: 800;
  opacity: 0;
  transform: translate3d(10px, 51px, -60px) rotateY(60deg) rotateX(-40deg);
  transform-origin: 50% 50% -150px !important;
  will-change: opacity, transform;
}
```

---

## Patrón: Cursor Elástico

```tsx
// GSAP quickSetter para rendimiento máximo
useLayoutEffect(() => {
  set.current.x = gsap.quickSetter(jellyRef.current, "x", "px");
  set.current.y = gsap.quickSetter(jellyRef.current, "y", "px");
  set.current.r = gsap.quickSetter(jellyRef.current, "rotate", "deg");
  set.current.sx = gsap.quickSetter(jellyRef.current, "scaleX");
  set.current.sy = gsap.quickSetter(jellyRef.current, "scaleY");
}, []);

// Loop en gsap.ticker (60fps)
const loop = useCallback(() => {
  const rotation = getAngle(vel.current.x, vel.current.y);
  const scale = getScale(vel.current.x, vel.current.y);
  set.current.x(pos.current.x);
  set.current.y(pos.current.y);
  set.current.w(CURSOR_SIZE + scale * 150);
  set.current.r(rotation);
  set.current.sx(1 + scale * 0.7);
  set.current.sy(1 - scale * 1.1);
}, []);

gsap.ticker.add(loop);
```

Estilo del cursor:
```css
.jelly-blob {
  border: 1.5px solid rgba(0, 240, 255, 0.4);
  background: rgba(0, 240, 255, 0.03);
  mix-blend-mode: difference;
  backdrop-filter: invert(80%);
}
```

---

## Patrón: Navbar Flotante con Auto-Hide

```tsx
const { y: currentScrollY } = useWindowScroll();

useEffect(() => {
  if (currentScrollY === 0) {
    setIsNavVisible(true);
    navRef.current?.classList.remove("floating-nav");
  } else if (currentScrollY > lastScrollY) {
    setIsNavVisible(false);          // scroll down → hide
    navRef.current?.classList.add("floating-nav");
  } else if (currentScrollY < lastScrollY) {
    setIsNavVisible(true);           // scroll up → show
    navRef.current?.classList.add("floating-nav");
  }
  setLastScrollY(currentScrollY);
}, [currentScrollY]);

useEffect(() => {
  gsap.to(navRef.current, {
    y: isNavVisible ? 0 : -100,
    opacity: isNavVisible ? 1 : 0,
    duration: 0.2,
  });
}, [isNavVisible]);
```

---

## Patrón: Preloader con Porcentaje Animado

```tsx
const [isLoading, setIsLoading] = useState(true);
const loadingRef = useRef({ value: 0 });

useEffect(() => {
  gsap.to(loadingRef.current, {
    value: 100,
    duration: 2.8,
    ease: "slow(0.7,0.7,false)",
    onUpdate: () => setLoadingPercent(loadingRef.current.value),
    onComplete: () => setIsLoading(false),
  });
}, []);

// Envolver en AnimatePresence para exit animation
<AnimatePresence mode="wait">
  {isLoading && <Loader />}
</AnimatePresence>
```

---

## Design System

### Colores (Tailwind Config)

```js
colors: {
  primary: "#0a0a0a",           // bg principal
  accent: {
    DEFAULT: "#00f0ff",          // cyan highlights
    violet: "#915EFF",           // secondary accent
    magenta: "#f272c8",          // tertiary accent
    lime: "#CDFF57",             // tags
    orange: "#FF6B35",           // warnings
  },
  dark: {
    100: "#100d25",              // deep surfaces
    200: "#1d1836",              // card backgrounds
    300: "#232631",              // lighter surfaces
  },
}
```

### Tipografía

| Font | Clase Tailwind | Uso |
|------|---------------|-----|
| Syne | `font-display` | Hero headings, bento titles |
| DM Sans | `font-body` | Cuerpo de texto |
| General Sans | `font-general` | Nav, labels, uppercase |
| JetBrains Mono | `font-mono` | Código, porcentajes, tags |

### Utilidades CSS Disponibles

```css
.flex-center        /* flex items-center justify-center */
.absolute-center    /* absolute + translate centering */
.glass-card         /* bg blur + border + backdrop-filter */
.gradient-text      /* cyan→violet→magenta text gradient */
.glow-line          /* horizontal gradient divider */
.data-grid-bg       /* subtle grid pattern background */
.hero-heading       /* massive display heading */
.nav-hover-btn      /* nav link with animated underline */
.bento-tilt_1       /* bento grid col-span-2 card */
.bento-tilt_2       /* bento grid col-span-1 card */
.mask-clip-path     /* full polygon clip-path */
```

---

## Reglas de Rendimiento

1. Canvas: `frameloop="demand"` + `dpr={[1, 2]}` SIEMPRE
2. Móvil (<640px): fallback flat sin Canvas, skip ElasticCursor
3. GSAP cleanup: SIEMPRE `gsap.context().revert()` en unmount
4. Videos: counter `onLoadedData` para preloading progresivo
5. Images: lazy load con `loading="lazy"`
6. Build: code-split por chunks (three, gsap, motion, vendor)
7. CSS: `will-change: transform` solo en elementos animados activos

---

## Vite Config Optimizado

```ts
export default defineConfig({
  plugins: [react()],
  resolve: { alias: { "@": path.resolve(__dirname, "./src") } },
  assetsInclude: ["**/*.gltf", "**/*.glb"],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          three: ["three", "@react-three/fiber", "@react-three/drei"],
          gsap: ["gsap", "@gsap/react"],
          motion: ["framer-motion"],
          vendor: ["react", "react-dom"],
        },
      },
    },
  },
});
```

---

## Checklist de Entrega

- [ ] TypeScript strict mode, 0 errores
- [ ] Mobile responsive (todas las secciones)
- [ ] Fallback móvil para Canvas 3D
- [ ] Preloader funcional
- [ ] Navbar auto-hide en scroll
- [ ] Todas las animaciones a 60fps
- [ ] Meta tags (title, description, OG)
- [ ] vercel.json o netlify.toml incluido
- [ ] Build production exitoso
- [ ] Code-split chunks < 500KB cada uno