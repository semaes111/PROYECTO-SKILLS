---
name: gsap-scroll-animations
description: "Patrones avanzados de animación GSAP + Framer Motion para webs inmersivas. Usar cuando el usuario pida: animaciones de scroll, ScrollTrigger, parallax, reveal, clip-path animations, video transitions, text animations, stagger, timeline, pin sections, scrub, tilt effects, hover 3D, cursor tracking, preloader animation, floating navbar. Incluye: 15+ recetas de animación copy-paste con código TypeScript completo."
---

---
name: gsap-scroll-animations
description: "Patrones avanzados de animación GSAP + Framer Motion para webs inmersivas. Usar cuando el usuario pida: animaciones de scroll, ScrollTrigger, parallax, reveal, clip-path animations, video transitions, text animations, stagger, timeline, pin sections, scrub, tilt effects, hover 3D, cursor tracking, preloader animation, floating navbar. Incluye: 15+ recetas de animación copy-paste con código TypeScript completo."
---

# GSAP Scroll Animations — Recetario de Animaciones Inmersivas

## Cuándo Usar

Activar cuando el usuario pida cualquier tipo de animación web:
- Scroll-triggered animations, parallax, reveal on scroll
- Clip-path morphing, video transitions, hero animations
- Text reveal word-by-word, staggered entrances
- Pin sections, scrub animations, horizontal scroll
- 3D tilt on hover, cursor tracking, elastic cursor
- Preloaders, loading bars, counters animados
- Navbar hide/show, floating elements

## Dependencias Requeridas

```bash
npm install gsap @gsap/react framer-motion react-use
```

**Imports estándar en CADA componente animado:**
```tsx
import { useGSAP } from "@gsap/react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
gsap.registerPlugin(ScrollTrigger);
```

---

## Receta 1: Clip-Path Morphing en Scroll

Transforma un polígono irregular a pantalla completa al hacer scroll.

```tsx
useGSAP(() => {
  gsap.set("#target", {
    clipPath: "polygon(14% 0%, 72% 0%, 90% 90%, 0% 100%)",
    borderRadius: "0 0 40% 10%",
  });
  gsap.from("#target", {
    clipPath: "polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%)",
    borderRadius: "0",
    ease: "power1.inOut",
    scrollTrigger: {
      trigger: "#target",
      start: "center center",
      end: "bottom center",
      scrub: true,
    },
  });
});
```

## Receta 2: Expanding Image (About Section)

Imagen pequeña que se expande a fullscreen al hacer scroll.

```tsx
useGSAP(() => {
  gsap.timeline({
    scrollTrigger: {
      trigger: "#clip",
      start: "center center",
      end: "+=800 center",
      scrub: 0.5,
      pin: true,
      pinSpacing: true,
    },
  }).to(".mask-clip-path", {
    width: "100vw",
    height: "100vh",
    borderRadius: 0,
  });
});
```

CSS requerido:
```css
.about-image {
  position: absolute;
  top: 0; left: 50%;
  z-index: 20;
  height: 60vh; width: 24rem;
  transform: translateX(-50%);
  transform-origin: center;
  overflow: hidden;
  border-radius: 1.5rem;
}
```

## Receta 3: Title Reveal 3D (Palabra por Palabra)

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

CSS obligatorio:
```css
.animated-word {
  opacity: 0;
  transform: translate3d(10px, 51px, -60px) rotateY(60deg) rotateX(-40deg);
  transform-origin: 50% 50% -150px !important;
  will-change: opacity, transform;
}
```

## Receta 4: Video Crossfade en Click

```tsx
useGSAP(() => {
  if (hasClicked) {
    gsap.set("#next-video", { visibility: "visible" });
    gsap.to("#next-video", {
      transformOrigin: "center center",
      scale: 1, width: "100%", height: "100%",
      duration: 1, ease: "power1.inOut",
      onStart: () => { nextVideoRef.current?.play(); },
    });
    gsap.from("#current-video", {
      transformOrigin: "center center",
      scale: 0, duration: 1.5, ease: "power1.inOut",
    });
  }
}, { dependencies: [currentIndex], revertOnUpdate: true });
```

## Receta 5: Staggered Fade-In con Framer Motion

```tsx
const fadeInVariant = {
  hidden: { opacity: 0, y: 40 },
  visible: (i: number) => ({
    opacity: 1, y: 0,
    transition: { delay: i * 0.15, duration: 0.6, ease: [0.16, 1, 0.3, 1] },
  }),
};

// Uso en JSX:
<motion.div
  custom={index}
  variants={fadeInVariant}
  initial="hidden"
  whileInView="visible"
  viewport={{ once: true, amount: 0.3 }}
/>
```

## Receta 6: Card 3D Tilt (Mouse Follow con GSAP)

```tsx
const handleMouseMove = (e: React.MouseEvent) => {
  if (!cardRef.current) return;
  const rect = cardRef.current.getBoundingClientRect();
  const rotateX = ((e.clientY - rect.top) / rect.height - 0.5) * -8;
  const rotateY = ((e.clientX - rect.left) / rect.width - 0.5) * 8;
  gsap.to(cardRef.current, {
    rotateX, rotateY,
    transformPerspective: 600,
    duration: 0.3, ease: "power1.inOut",
  });
};

const handleMouseLeave = () => {
  gsap.to(cardRef.current, {
    rotateX: 0, rotateY: 0,
    duration: 0.5, ease: "power2.out",
  });
};
```

## Receta 7: Navbar Auto-Hide en Scroll

```tsx
const { y: currentScrollY } = useWindowScroll(); // react-use

useEffect(() => {
  if (currentScrollY === 0) {
    setIsNavVisible(true);
    navRef.current?.classList.remove("floating-nav");
  } else if (currentScrollY > lastScrollY) {
    setIsNavVisible(false);
    navRef.current?.classList.add("floating-nav");
  } else {
    setIsNavVisible(true);
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

## Receta 8: Preloader con Contador GSAP

```tsx
const loadingRef = useRef({ value: 0 });
const [percent, setPercent] = useState(0);

useEffect(() => {
  gsap.to(loadingRef.current, {
    value: 100,
    duration: 2.8,
    ease: "slow(0.7,0.7,false)",
    onUpdate: () => setPercent(Math.round(loadingRef.current.value)),
    onComplete: () => setIsLoading(false),
  });
}, []);
```

## Receta 9: Cursor Elástico (GSAP Ticker)

```tsx
// quickSetter para rendimiento máximo (evita re-renders React)
set.x = gsap.quickSetter(jellyRef.current, "x", "px");
set.y = gsap.quickSetter(jellyRef.current, "y", "px");
set.r = gsap.quickSetter(jellyRef.current, "rotate", "deg");

// Loop en ticker (fuera de React render cycle)
gsap.ticker.add(() => {
  const scale = Math.min(Math.sqrt(vel.x**2 + vel.y**2) / 1200, 0.18);
  const angle = Math.atan2(vel.y, vel.x) * 180 / Math.PI;
  set.x(pos.x); set.y(pos.y);
  set.r(angle);
  set.sx(1 + scale * 0.7);
  set.sy(1 - scale * 1.1);
});
```

## Receta 10: BentoTilt Perspective

```tsx
const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
  const { left, top, width, height } = ref.current!.getBoundingClientRect();
  const tiltX = ((e.clientY - top) / height - 0.5) * 5;
  const tiltY = ((e.clientX - left) / width - 0.5) * -5;
  setTransformStyle(
    `perspective(700px) rotateX(${tiltX}deg) rotateY(${tiltY}deg) scale3d(0.98, 0.98, 0.98)`
  );
};
```

## Receta 11: Story Image Tilt (Mouse Track)

```tsx
const handleMouseMove = (e: React.MouseEvent<HTMLImageElement>) => {
  const rect = frameRef.current!.getBoundingClientRect();
  const rotateX = ((e.clientY - rect.top - rect.height/2) / (rect.height/2)) * -10;
  const rotateY = ((e.clientX - rect.left - rect.width/2) / (rect.width/2)) * 10;
  gsap.to(frameRef.current, {
    rotateX, rotateY,
    transformPerspective: 500,
    duration: 0.3, ease: "power1.inOut",
  });
};
```

## Receta 12: Indicador de Audio Animado

```css
.indicator-line {
  height: 4px; width: 1px;
  border-radius: 9999px;
  background: white;
  transition: all 0.2s ease-in-out;
}
.indicator-line.active {
  animation: indicator-line 0.5s ease infinite;
  animation-delay: calc(var(--animation-order) * 0.1s);
}
@keyframes indicator-line {
  0%   { height: 4px; transform: translateY(0); }
  50%  { height: 16px; transform: translateY(-4px); }
  100% { height: 4px; transform: translateY(0); }
}
```

---

## Reglas de Oro GSAP

1. **Registrar plugins**: `gsap.registerPlugin(ScrollTrigger)` ANTES de usar
2. **Cleanup SIEMPRE**: Usar `useGSAP` (limpia auto) o `gsap.context().revert()`
3. **quickSetter para loops**: No usar `.to()` en ticker, usar quickSetter
4. **scrollTrigger toggleActions**: `"play none none reverse"` para reversible
5. **scrub**: `scrub: true` para 1:1 con scroll, `scrub: 0.5` para suave
6. **pin**: `pin: true` congela el elemento mientras dura la animación
7. **stagger**: Preferir `stagger: 0.02` (rápido) a `0.1` (lento demás)
8. **ease**: `"power1.inOut"` para suave, `"power2.out"` para bounce, `"slow(0.7,0.7,false)"` para preloaders
9. **Performance**: Animar SOLO `transform` y `opacity` cuando sea posible
10. **revertOnUpdate**: `{ dependencies: [dep], revertOnUpdate: true }` para re-ejecutar