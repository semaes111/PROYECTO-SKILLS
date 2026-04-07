---
name: 3d-portfolio-generator
description: "Generador completo de portfolios y webs 3D desde una descripción. Usar cuando el usuario diga: crea un portfolio, genera una web para [negocio], haz una landing page 3D, construye un sitio web inmersivo, clona el template 3DWEB para [cliente], adapta el portfolio para [industria]. Incluye: workflow paso a paso para adaptar el template 3DWEB-NIVEL-DIOS, personalización de contenido/colores/fuentes, estructura de constants/index.ts, checklist de entrega, y comandos de deploy."
---

---
name: 3d-portfolio-generator
description: "Generador completo de portfolios y webs 3D desde una descripción. Usar cuando el usuario diga: crea un portfolio, genera una web para [negocio], haz una landing page 3D, construye un sitio web inmersivo, clona el template 3DWEB para [cliente], adapta el portfolio para [industria]. Incluye: workflow paso a paso para adaptar el template 3DWEB-NIVEL-DIOS, personalización de contenido/colores/fuentes, estructura de constants/index.ts, checklist de entrega, y comandos de deploy."
---

# 3D Portfolio Generator — De Descripción a Web Deployada

## Cuándo Usar

Activar cuando el usuario solicite:
- Crear un portfolio web desde cero
- Generar una web 3D para un negocio/cliente
- Adaptar un template 3D para una industria específica
- Landing page inmersiva con efectos 3D
- Cualquier "hazme una web" que requiera diseño premium

---

## Workflow: 12 Pasos para Generar un Sitio Completo

### Paso 1: Recopilar Información

Antes de generar código, obtener del usuario:

```
NOMBRE:        [nombre del proyecto/empresa]
INDUSTRIA:     [tech, restaurante, arquitectura, gaming, música, moda, etc.]
COLOR_PRIMARY: [hex del color principal de marca]
COLOR_ACCENT:  [hex del color de acento]
FONT_DISPLAY:  [Google Font para headings, o usar Syne por defecto]
SECCIONES:     [qué secciones incluir: hero, about, services, projects, etc.]
CONTENIDO:     [textos, servicios, experiencia, proyectos, etc.]
DEPLOY:        [vercel, netlify, VPS, o solo código]
```

### Paso 2: Scaffold del Proyecto

```bash
npm create vite@latest NOMBRE -- --template react-ts
cd NOMBRE
npm install @react-three/fiber @react-three/drei three gsap @gsap/react \
  framer-motion maath react-icons react-use react-vertical-timeline-component \
  clsx tailwind-merge
npm install -D @types/three tailwindcss autoprefixer postcss
npx tailwindcss init -p
```

### Paso 3: Estructura de Archivos

Crear exactamente esta estructura:

```
src/
├── components/
│   ├── canvas/Stars.tsx
│   ├── canvas/Ball.tsx
│   ├── canvas/Loader.tsx
│   ├── canvas/index.ts
│   ├── layout/Navbar.tsx
│   ├── layout/Footer.tsx
│   ├── layout/Preloader.tsx
│   ├── sections/Hero.tsx
│   ├── sections/About.tsx
│   ├── sections/Features.tsx
│   ├── sections/Experience.tsx
│   ├── sections/Tech.tsx
│   ├── sections/Projects.tsx
│   ├── sections/Contact.tsx
│   └── ui/Button.tsx
│   └── ui/AnimatedTitle.tsx
│   └── ui/ElasticCursor.tsx
│   └── ui/RoundedCorners.tsx
├── constants/index.ts
├── lib/utils.ts
├── index.css
├── App.tsx
└── main.tsx
```

### Paso 4: Configurar tailwind.config.js

Adaptar colores del design system al brand del cliente:

```js
colors: {
  primary: "[COLOR_BG del cliente, default #0a0a0a]",
  accent: {
    DEFAULT: "[COLOR_ACCENT del cliente, default #00f0ff]",
    violet: "[COLOR_SECONDARY, default #915EFF]",
    magenta: "[COLOR_TERTIARY, default #f272c8]",
  },
},
fontFamily: {
  display: ["[FONT_DISPLAY]", "sans-serif"],
  body: ["DM Sans", "sans-serif"],
  general: ["General Sans", "sans-serif"],
  mono: ["JetBrains Mono", "monospace"],
},
```

### Paso 5: Actualizar constants/index.ts

Este es el archivo MÁS IMPORTANTE. Toda la data del sitio vive aquí:

```ts
// NAV_ITEMS — adaptar al proyecto
export const NAV_ITEMS = [
  { label: "Home", href: "#hero" },
  { label: "Sobre Nosotros", href: "#about" },
  // ... secciones del cliente
] as const;

// SERVICES — adaptar a la industria
export const SERVICES = [
  {
    title: "[Servicio 1 del cliente]",
    icon: "[emoji relevante]",
    description: "[Descripción del servicio]",
  },
  // ... más servicios
] as const;

// EXPERIENCES — historial del cliente/profesional
export const EXPERIENCES = [
  {
    title: "[Puesto]",
    company: "[Empresa]",
    icon: "[emoji]",
    iconBg: "#0a0a0a",
    date: "[Período]",
    points: ["[Logro 1]", "[Logro 2]", "[Logro 3]"],
  },
] as const;

// TECHNOLOGIES — stack del cliente
export const TECHNOLOGIES = [
  { name: "[Tech]", icon: "[URL icono devicon]" },
] as const;

// PROJECTS — portfolio del cliente
export const PROJECTS = [
  {
    name: "[Nombre proyecto]",
    description: "[Descripción]",
    tags: [
      { name: "[tag]", color: "text-accent" },
    ],
    image: "[URL imagen]",
    sourceCode: "[URL repo]",
    liveDemo: "[URL demo]",
  },
] as const;
```

### Paso 6: Actualizar index.html

```html
<title>[NOMBRE] — [Tagline]</title>
<meta name="description" content="[Descripción para SEO]" />
<meta property="og:title" content="[NOMBRE]" />
<meta property="og:description" content="[Descripción]" />
<meta property="og:image" content="[URL preview image]" />
```

### Paso 7: Actualizar Hero

Cambiar textos del hero en `Hero.tsx`:
- Heading principal
- Subtítulo
- Texto del CTA button
- Videos de fondo (o reemplazar por Canvas 3D si no hay videos)

### Paso 8: Actualizar About

- Texto descriptivo
- Service cards (desde constants)
- Imagen del clip expanding

### Paso 9: Actualizar Features (Bento Grid)

- Títulos de cada bento card
- Descripciones
- Videos de fondo (o gradientes si no hay videos)

### Paso 10: Actualizar Experience + Tech + Projects

- Timeline desde constants
- Tech balls desde constants
- Project cards desde constants

### Paso 11: Actualizar Contact + Footer

- Labels del formulario
- Social links
- Copyright text
- EmailJS config (si aplica)

### Paso 12: Build + Deploy

```bash
npm run build  # Verificar 0 errores

# Vercel:
npx vercel --prod

# Netlify:
# Push a GitHub → auto-deploy

# VPS:
scp -r dist/* root@IP:/var/www/NOMBRE/
```

---

## Templates por Industria

### Tech/SaaS
- Colores: `primary: #0a0a0a`, `accent: #00f0ff`
- Font display: Syne o Space Grotesk
- Hero: Video de código/dashboard + Stars canvas
- Features: Bento grid con screenshots de producto

### Restaurante
- Colores: `primary: #0a0a0a`, `accent: #C9A962` (dorado)
- Font display: Playfair Display
- Hero: Video de cocina o ambiente
- Secciones: Menú, Chef, Galería, Reservas

### Arquitectura/Diseño
- Colores: `primary: #1a1a1a`, `accent: #E8E0D5` (crema)
- Font display: Cormorant Garamond
- Hero: Video de renders 3D
- Secciones: Proyectos gallery, Proceso, Equipo

### Gaming/Esports
- Colores: `primary: #0a0a0a`, `accent: #ff4655` (rojo)
- Font display: Orbitron
- Hero: Video gameplay + particle effects
- Features: Bento grid con trailers de juegos

### Música/Arte
- Colores: `primary: #0a0a0a`, `accent: #ff6b9d` (rosa)
- Font display: Bebas Neue
- Hero: Audio visualizer canvas
- Secciones: Releases, Tour, Gallery, Bio

---

## Checklist de Entrega Final

```
[ ] TypeScript: 0 errores (npx tsc --noEmit)
[ ] Build: exitoso (npm run build)
[ ] Mobile: todas las secciones responsive
[ ] 3D fallback: canvas desactivado en móvil
[ ] Preloader: funciona y desaparece
[ ] Navbar: auto-hide on scroll funciona
[ ] Animations: todas a 60fps
[ ] Contact: formulario funcional
[ ] Meta tags: title, description, OG actualizados
[ ] Favicon: actualizado con logo del cliente
[ ] Deploy config: vercel.json o netlify.toml
[ ] Sin textos placeholder: buscar "Lorem", "Nexus", "example"
[ ] Performance: Lighthouse >80 en todas las métricas
[ ] Git: commit limpio, .gitignore correcto
```

---

## Referencia: Repo Base

Repositorio completo: `github.com/semaes111/3DWEB-NIVEL-DIOS`

Si Claude Code tiene GitHub MCP configurado, puede leer cualquier archivo del repo en tiempo real:
```
"Lee el Hero.tsx de semaes111/3DWEB-NIVEL-DIOS y adáptalo para este proyecto"
```