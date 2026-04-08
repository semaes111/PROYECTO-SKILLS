---
name: css-scroll-driven-animations
description: >
  CSS Scroll-Driven Animations — animaciones nativas vinculadas al scroll
  sin JavaScript, off main thread, hardware-accelerated. animation-timeline,
  scroll(), view(), animation-range. Chrome 115+, Safari 18+.
  Usar cuando: scroll animation CSS, animation-timeline, CSS nativo scroll,
  parallax CSS, reveal CSS, progress bar scroll, view timeline.
triggers:
  - "CSS scroll animation"
  - "animation-timeline"
  - "scroll-driven CSS"
  - "parallax sin JavaScript"
  - "view() CSS"
type: reference
---

# CSS Scroll-Driven Animations — Nativas y Hardware-Accelerated

## Que Es

CSS Scroll-Driven Animations permiten vincular cualquier animacion CSS
al progreso del scroll — SIN JavaScript, ejecutandose off main thread,
hardware-accelerated. Es el estandar 2025 para efectos de scroll.

**Soporte**: Chrome 115+, Edge 115+, Safari 18+, Firefox (con flag)

## Dos Tipos de Timeline

### 1. Scroll Progress Timeline — `scroll()`
Vincula animacion al progreso del scroll del contenedor.

```css
@keyframes fade-in {
  from { opacity: 0; transform: translateY(50px); }
  to   { opacity: 1; transform: translateY(0); }
}

.element {
  animation: fade-in linear;
  animation-timeline: scroll();  /* Vincula al scroll del nearest scroller */
}
```

### 2. View Progress Timeline — `view()`
Vincula animacion a la visibilidad del elemento en el viewport.

```css
.card {
  animation: reveal linear both;
  animation-timeline: view();    /* Se anima segun entra/sale del viewport */
  animation-range: entry 0% entry 100%;  /* Solo durante la entrada */
}

@keyframes reveal {
  from { opacity: 0; transform: scale(0.8); }
  to   { opacity: 1; transform: scale(1); }
}
```

## Sintaxis scroll()

```css
animation-timeline: scroll();                    /* Nearest scroller, block axis */
animation-timeline: scroll(root);                /* Viewport (root scroller) */
animation-timeline: scroll(nearest);             /* Nearest scroll ancestor */
animation-timeline: scroll(self);                /* El propio elemento */
animation-timeline: scroll(root block);          /* Root, eje vertical */
animation-timeline: scroll(root inline);         /* Root, eje horizontal */
```

## Sintaxis view()

```css
animation-timeline: view();                      /* Block axis */
animation-timeline: view(inline);                /* Inline axis */
animation-timeline: view(block 20% 10%);         /* Con inset */
```

## animation-range — Controlar Cuando Animar

```css
/* Rangos nombrados para view() */
animation-range: entry;          /* Mientras entra en viewport */
animation-range: exit;           /* Mientras sale del viewport */
animation-range: contain;        /* Mientras esta completamente visible */
animation-range: cover;          /* Desde que empieza a entrar hasta que sale */

/* Con porcentajes */
animation-range: entry 0% entry 100%;     /* Toda la entrada */
animation-range: entry 25% cover 50%;     /* 25% de entrada hasta 50% de cover */
animation-range: contain 0% contain 100%; /* Solo mientras completamente visible */

/* Con valores absolutos */
animation-range: entry 0px entry 200px;
```

## Ejemplos Practicos

### Progress Bar de Lectura

```css
.progress-bar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 4px;
  background: #3b82f6;
  transform-origin: left;
  animation: grow-progress linear;
  animation-timeline: scroll(root);
}

@keyframes grow-progress {
  from { transform: scaleX(0); }
  to   { transform: scaleX(1); }
}
```

### Parallax sin JavaScript

```css
.parallax-bg {
  animation: parallax linear;
  animation-timeline: scroll();
}

@keyframes parallax {
  from { transform: translateY(0); }
  to   { transform: translateY(-30%); }
}
```

### Reveal on Scroll

```css
.reveal {
  animation: slide-up linear both;
  animation-timeline: view();
  animation-range: entry 10% entry 90%;
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(80px);
    filter: blur(4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0);
  }
}
```

### Staggered Cards

```css
.card:nth-child(1) { animation-range: entry 0% entry 80%; }
.card:nth-child(2) { animation-range: entry 10% entry 90%; }
.card:nth-child(3) { animation-range: entry 20% entry 100%; }
```

### Shrink Header on Scroll

```css
.header {
  animation: shrink-header linear;
  animation-timeline: scroll(root);
  animation-range: 0px 200px;
}

@keyframes shrink-header {
  from { height: 100px; font-size: 2rem; }
  to   { height: 60px; font-size: 1.2rem; }
}
```

### Horizontal Scroll Indicator

```css
.horizontal-container {
  overflow-x: auto;
}

.scroll-indicator {
  animation: scroll-indicator linear;
  animation-timeline: scroll(nearest inline);
}

@keyframes scroll-indicator {
  from { transform: scaleX(0); }
  to   { transform: scaleX(1); }
}
```

## Named Scroll Timelines

```css
.scroller {
  overflow-y: auto;
  scroll-timeline-name: --my-scroller;
  scroll-timeline-axis: block;
}

.child-element {
  animation: animate linear;
  animation-timeline: --my-scroller;
}
```

## Deteccion y Fallback

```css
/* Deteccion con @supports */
@supports (animation-timeline: scroll()) {
  .element {
    animation: fade-in linear;
    animation-timeline: scroll();
  }
}

/* Fallback para navegadores sin soporte */
@supports not (animation-timeline: scroll()) {
  .element {
    opacity: 1;  /* Sin animacion, visible por defecto */
  }
}
```

```javascript
// Deteccion en JavaScript
const supportsScrollTimeline = CSS.supports('animation-timeline', 'scroll()')

if (!supportsScrollTimeline) {
  // Fallback con IntersectionObserver o GSAP ScrollTrigger
  import('gsap/ScrollTrigger').then(({ ScrollTrigger }) => {
    // ... fallback
  })
}
```

## Combinacion con CSS Transitions

```css
/* Las scroll-driven animations funcionan con CUALQUIER propiedad animable */
.hero-text {
  animation: hero-entrance linear both;
  animation-timeline: scroll(root);
  animation-range: 0vh 50vh;
}

@keyframes hero-entrance {
  0%   { opacity: 1; transform: translateY(0) scale(1); clip-path: inset(0); }
  100% { opacity: 0; transform: translateY(-100px) scale(0.8); clip-path: inset(0 20%); }
}
```

## Performance

- **Off main thread**: las animaciones corren en el compositor, no bloquean JS
- **Hardware-accelerated**: transform y opacity son las mas eficientes
- **0 JavaScript**: cero overhead de event listeners o requestAnimationFrame
- **60fps garantizados** para propiedades compositor-friendly

## Propiedades Compositor-Friendly (Mas Rapidas)

- `transform` (translate, scale, rotate)
- `opacity`
- `filter` (blur, brightness, etc.)
- `clip-path`
- `background-position` (en algunos navegadores)

## Cuando Usar CSS vs GSAP+Lenis

| Caso | CSS Scroll-Driven | GSAP + Lenis |
|------|-------------------|--------------|
| Progress bar simple | CSS | Overkill |
| Parallax basico | CSS | Overkill |
| Reveal on scroll | CSS | Overkill |
| Timeline compleja con callbacks | No | GSAP |
| Animacion con logica condicional | No | GSAP |
| Soporte IE/Firefox antiguo | No | GSAP |
| Performance maxima | CSS (off thread) | Buena (main thread) |
