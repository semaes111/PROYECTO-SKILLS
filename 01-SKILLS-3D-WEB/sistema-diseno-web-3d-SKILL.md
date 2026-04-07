---
name: 3d-web-design-system
description: "Design system completo para webs 3D inmersivas con tema oscuro premium. Usar cuando se necesite: paleta de colores cyberpunk/dark, tipografía para webs premium, utilidades CSS (glass-card, gradient-text, clip-paths, glow effects), Tailwind config custom, responsive breakpoints, patrones de layout (bento grid, hero fullscreen, timeline), customización de scrollbar, loading animations. Incluye: tailwind.config.js completo, index.css con 30+ utilidades, font pairing, y guía de implementación."
---

---
name: 3d-web-design-system
description: "Design system completo para webs 3D inmersivas con tema oscuro premium. Usar cuando se necesite: paleta de colores cyberpunk/dark, tipografía para webs premium, utilidades CSS (glass-card, gradient-text, clip-paths, glow effects), Tailwind config custom, responsive breakpoints, patrones de layout (bento grid, hero fullscreen, timeline), customización de scrollbar, loading animations. Incluye: tailwind.config.js completo, index.css con 30+ utilidades, font pairing, y guía de implementación."
---

# 3D Web Design System — Tema Oscuro Premium para Webs Inmersivas

## Cuándo Usar

Activar cuando el usuario necesite:
- Diseño de web con tema oscuro/cyberpunk/premium
- Configuración de Tailwind CSS para proyecto 3D
- Paleta de colores cyan-violet-magenta
- Tipografías para headings impactantes
- Utilidades CSS: glass cards, gradientes, clip-paths, glows
- Layout patterns: bento grid, hero fullscreen, timeline

---

## Tailwind Config Completo

```js
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#0a0a0a",
        secondary: "#aaa6c3",
        tertiary: "#151030",
        accent: {
          DEFAULT: "#00f0ff",
          violet: "#915EFF",
          magenta: "#f272c8",
          lime: "#CDFF57",
          orange: "#FF6B35",
        },
        dark: { 100: "#100d25", 200: "#1d1836", 300: "#232631" },
        blue: { 50: "#dfdff0", 75: "#dfdff2", 100: "#f0f2fa", 200: "#101010", 300: "#4fb7dd" },
        violet: { 300: "#5724ff", 50: "#b4b4cc" },
      },
      fontFamily: {
        display: ["Syne", "sans-serif"],
        body: ["DM Sans", "sans-serif"],
        general: ["General Sans", "sans-serif"],
        mono: ["JetBrains Mono", "monospace"],
      },
      screens: { xs: "450px" },
      backgroundImage: {
        "mesh-gradient": "radial-gradient(at 40% 20%, hsla(280,100%,70%,0.15) 0px, transparent 50%), radial-gradient(at 80% 0%, hsla(189,100%,56%,0.1) 0px, transparent 50%)",
      },
      animation: {
        "spin-slow": "spin 8s linear infinite",
        "pulse-glow": "pulse-glow 2s ease-in-out infinite",
        float: "float 6s ease-in-out infinite",
      },
      keyframes: {
        "pulse-glow": { "0%, 100%": { opacity: 1 }, "50%": { opacity: 0.5 } },
        float: { "0%, 100%": { transform: "translateY(0px)" }, "50%": { transform: "translateY(-20px)" } },
      },
    },
  },
  plugins: [],
};
```

---

## Google Fonts (index.html)

```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;0,9..40,700&display=swap" rel="stylesheet" />
<link href="https://fonts.cdnfonts.com/css/general-sans" rel="stylesheet" />
```

---

## Utilidades CSS Completas (index.css)

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* === SCROLLBAR === */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: #0a0a0a; }
::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #00f0ff, #915eff);
  border-radius: 10px;
}

/* === HERO HEADING === */
.hero-heading {
  @apply text-5xl font-black uppercase sm:text-7xl md:text-9xl lg:text-[12rem];
  font-family: "Syne", sans-serif;
  letter-spacing: -0.02em; line-height: 0.85;
}
.hero-heading b {
  background: linear-gradient(135deg, #00f0ff 0%, #915eff 50%, #f272c8 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* === GRADIENT TEXT === */
.gradient-text {
  background: linear-gradient(135deg, #00f0ff 0%, #915eff 50%, #f272c8 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* === GLASS CARD === */
.glass-card {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.06);
  backdrop-filter: blur(24px);
  border-radius: 16px;
}

/* === GLOW LINE (divider) === */
.glow-line {
  height: 1px;
  background: linear-gradient(90deg, transparent 0%, #00f0ff 20%, #915eff 50%, #f272c8 80%, transparent 100%);
  opacity: 0.6;
}

/* === DATA GRID BG === */
.data-grid-bg {
  background-image:
    linear-gradient(rgba(0, 240, 255, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 240, 255, 0.03) 1px, transparent 1px);
  background-size: 60px 60px;
}

/* === LAYOUT UTILITIES === */
.flex-center { @apply flex items-center justify-center; }
.absolute-center { @apply absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2; }

/* === BENTO GRID === */
.bento-tilt_1 {
  @apply relative col-span-2 overflow-hidden rounded-xl transition-transform duration-300 ease-out;
  border: 1px solid rgba(255, 255, 255, 0.08);
}
.bento-tilt_2 {
  @apply relative col-span-1 row-span-1 overflow-hidden rounded-xl transition-transform duration-300 ease-out;
  border: 1px solid rgba(255, 255, 255, 0.08);
}
.bento-title {
  @apply text-4xl font-black uppercase md:text-6xl;
  font-family: "Syne", sans-serif;
}
.bento-title b { /* same gradient-text pattern */ }

/* === NAVBAR === */
.floating-nav { @apply rounded-lg border border-white/10 bg-black/80 backdrop-blur-xl; }
.nav-hover-btn {
  @apply relative ms-10 cursor-pointer text-xs uppercase transition;
  font-family: "General Sans", sans-serif;
}
.nav-hover-btn::after {
  content: "";
  @apply absolute -bottom-0.5 left-0 h-[2px] w-full origin-bottom-right scale-x-0 transition-transform duration-300;
  background: linear-gradient(90deg, #00f0ff, #915eff);
}
.nav-hover-btn:hover::after { @apply origin-bottom-left scale-x-100; }
.nav-hover-btn:hover { color: #00f0ff; }

/* === CLIP PATHS === */
.mask-clip-path { clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%); }
.sword-man-clip-path { clip-path: polygon(16% 0, 89% 15%, 75% 100%, 0 97%); }
.contact-clip-path-1 { clip-path: polygon(25% 0%, 74% 0, 69% 64%, 34% 73%); }
.contact-clip-path-2 { clip-path: polygon(29% 15%, 85% 30%, 50% 100%, 10% 64%); }

/* === STORY IMAGE === */
.story-img-container { @apply relative h-[90vh] w-full md:h-dvh; filter: url("#flt_tag"); }
.story-img-mask {
  @apply absolute top-0 left-0 size-full overflow-hidden md:top-[-10%] md:left-[20%] md:size-4/5;
  clip-path: polygon(4% 0, 83% 21%, 100% 73%, 0% 100%);
}

/* === VERTICAL TIMELINE === */
.vertical-timeline-element-content {
  background: rgba(29, 24, 54, 0.9) !important;
  border: 1px solid rgba(255, 255, 255, 0.06) !important;
  backdrop-filter: blur(12px);
  border-radius: 16px !important;
}
.vertical-timeline::before {
  background: linear-gradient(180deg, #00f0ff 0%, #915eff 50%, #f272c8 100%) !important;
  width: 2px !important;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .hero-heading { font-size: 3rem; line-height: 0.9; }
  .bento-title { font-size: 1.5rem; }
}
```

---

## Section Header Pattern

Cada sección usa este header consistente:

```tsx
<p className="font-general text-sm uppercase tracking-[0.3em] text-accent/60 mb-4">
  Subtítulo en mayúsculas
</p>
<h2 className="font-display text-4xl md:text-5xl font-bold text-white">
  Título con <span className="gradient-text">palabra destacada</span>
</h2>
<p className="text-white/30 mt-4 max-w-md mx-auto">
  Descripción en texto suave
</p>
```

## Card Pattern

```tsx
<div className="glass-card p-6 group hover:border-accent/20 transition-all duration-500">
  <h3 className="font-display font-bold text-white text-lg group-hover:text-accent transition-colors">
    Título
  </h3>
  <p className="text-white/40 text-sm leading-relaxed">Descripción</p>
  <div className="mt-4 h-px w-0 group-hover:w-full bg-gradient-to-r from-accent to-accent-violet transition-all duration-700" />
</div>
```

## Tag Pattern

```tsx
<span className="text-accent text-xs font-mono px-3 py-1 rounded-full bg-white/5 border border-white/5">
  #nombre-tag
</span>
```

## SVG Gooey Filter (RoundedCorners)

```tsx
<svg className="invisible absolute size-0" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="flt_tag">
      <feGaussianBlur in="SourceGraphic" stdDeviation="8" result="blur" />
      <feColorMatrix in="blur" mode="matrix"
        values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 19 -9" result="flt_tag" />
      <feComposite in="SourceGraphic" in2="flt_tag" operator="atop" />
    </filter>
  </defs>
</svg>
```

---

## Paleta de Opacidades Recomendadas

| Uso | Opacidad | Ejemplo |
|-----|----------|---------|
| Texto principal | 100% | `text-white` |
| Texto secundario | 50% | `text-white/50` |
| Texto terciario | 30-40% | `text-white/30` |
| Borders | 6-10% | `border-white/6` |
| Backgrounds hover | 5% | `bg-white/5` |
| Accent subtle | 60% | `text-accent/60` |
| Overlays | 80-90% | `bg-primary/80` |