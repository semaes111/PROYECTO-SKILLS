---
name: design-md-generator
description: >
  Genera archivos DESIGN.md completos siguiendo el formato Google Stitch de
  9 secciones para que agentes IA produzcan UI pixel-perfect. This skill should
  be used when the user asks to "create a DESIGN.md", "generate design system",
  "document my visual design", "extract design tokens from a site",
  "create a style guide for AI agents", "design spec for my project",
  or needs a structured design system document that AI coding agents can read
  to generate consistent UI.
---

# DESIGN.md Generator Skill

## Qué es DESIGN.md

DESIGN.md es un documento de sistema de diseño en texto plano que sigue la especificación **Google Stitch**. Es un archivo Markdown que contiene toda la información visual, componentes, tokens y guías que un agente de IA necesita para generar UI consistente y pixel-perfect.

**Por qué Markdown?** Los LLMs leen Markdown mejor que JSON o YAML. Un DESIGN.md en la raíz del proyecto actúa como "brújula de diseño" para Claude Code, Cursor, Windsurf, Cline y otros agentes. En lugar de generaciones inconsistentes, el agente lee tu DESIGN.md y aplica los valores exactos (colores hex, espacios, tipografía, sombras) a cada componente.

**Referencia:** https://stitch.withgoogle.com/docs/design-md/overview/

---

## Template de 9 Secciones

La estructura estándar de DESIGN.md contiene exactamente 9 secciones:

### Sección 1: Visual Theme & Atmosphere

Escribe 2-3 párrafos describiendo la atmósfera visual, densidad, filosofía de diseño y características clave como lista de bullets.

**Placeholder:**
```
# 1. Visual Theme & Atmosphere

[2-3 párrafos describiendo mood, estilo, principios de diseño]

**Key Characteristics:**
- [Bullet 1]
- [Bullet 2]
- [Bullet 3]
- [Bullet 4]
```

### Sección 2: Color Palette & Roles

Tabla organizada con: Nombre semántico + código hex + rol funcional. Agrupa por: Brand, Neutral Scale, Interactive, Surface & Overlay, Shadows.

**Placeholder:**
```
# 2. Color Palette & Roles

## Brand Colors
| Color Name | Hex | Role |
|-----------|-----|------|
| primary   | #0F766E | Primary buttons, links, accent |
| secondary | #0D9488 | Secondary emphasis |

## Neutral Scale
| Color Name | Hex | Role |
|-----------|-----|------|
| neutral-50 | #F9FAFB | Lightest background |
| neutral-900| #111827 | Text on light |

## Interactive
| Color Name | Hex | Role |
|-----------|-----|------|
| success | #10B981 | Confirmation, positive states |
| warning | #F59E0B | Warnings, caution |
| error   | #EF4444 | Errors, destructive |

## Surface & Overlay
| Color Name | Hex | Role |
|-----------|-----|------|
| bg-primary | #FFFFFF | Primary background |
| bg-secondary | #F3F4F6 | Card, secondary background |

## Shadows
| Color Name | Hex | Role |
|-----------|-----|------|
| shadow-dark | rgba(0,0,0,0.25) | Deep shadows |
| shadow-light | rgba(0,0,0,0.08) | Soft shadows |
```

### Sección 3: Typography Rules

Familia tipográfica + fallbacks, tabla de jerarquía con: Role | Font | Size | Weight | Line Height | Letter Spacing | Notes.

**Placeholder:**
```
# 3. Typography Rules

**Primary Font Family:** Inter, Helvetica, sans-serif
**Fallback:** system-ui, sans-serif
**Monospace:** Fira Code, monospace

Typography supports clear visual hierarchy through intentional scale and weight variation. Consistency across headings and body text builds recognition.

## Typography Hierarchy
| Role | Font | Size | Weight | Line Height | Letter Spacing | Notes |
|------|------|------|--------|-------------|-----------------|-------|
| h1 | Inter | 48px | 700 (Bold) | 1.2 | -0.02em | Page titles |
| h2 | Inter | 32px | 600 (SemiBold) | 1.3 | -0.01em | Section headers |
| h3 | Inter | 24px | 600 (SemiBold) | 1.4 | 0em | Subsections |
| body | Inter | 16px | 400 (Regular) | 1.5 | 0em | Body text |
| small | Inter | 14px | 400 (Regular) | 1.5 | 0em | Secondary info |
| caption | Inter | 12px | 500 (Medium) | 1.4 | 0.01em | Captions, labels |
| mono | Fira Code | 14px | 400 (Regular) | 1.5 | 0em | Code, technical |
```

### Sección 4: Component Stylings

Botones (primary/secondary/ghost con bg, text, padding, radius, shadow, hover, focus), Cards, Inputs, Navigation. Incluir estados: default, hover, focus, disabled, active.

**Placeholder:**
```
# 4. Component Stylings

## Buttons

### Primary Button
- **Background:** #0F766E
- **Text Color:** #FFFFFF
- **Padding:** 12px 24px (16px 32px on desktop)
- **Border Radius:** 6px
- **Font Weight:** 600
- **Shadow (default):** 0 1px 2px rgba(0,0,0,0.08)
- **Hover State:** bg #0D6D67, shadow 0 4px 8px rgba(0,0,0,0.15)
- **Focus State:** outline 2px solid #0D9488, outline-offset 2px
- **Disabled State:** bg #D1D5DB, cursor not-allowed, opacity 0.6

### Secondary Button
- **Background:** transparent
- **Border:** 1px solid #0F766E
- **Text Color:** #0F766E
- **Padding:** 12px 24px
- **Border Radius:** 6px
- **Hover State:** bg #F0FDFA
- **Focus State:** outline 2px solid #0D9488
- **Disabled State:** border #D1D5DB, text #9CA3AF

### Ghost Button
- **Background:** transparent
- **Text Color:** #0F766E
- **Padding:** 12px 16px
- **Border Radius:** 4px
- **Hover State:** bg #F9FAFB
- **Focus State:** outline 2px solid #0D9488

## Cards
- **Background:** #FFFFFF
- **Border:** 1px solid #E5E7EB
- **Border Radius:** 8px
- **Shadow:** 0 1px 3px rgba(0,0,0,0.1)
- **Padding:** 24px
- **Hover State:** shadow 0 4px 12px rgba(0,0,0,0.12), border #D1D5DB

## Inputs
- **Background:** #FFFFFF
- **Border:** 1px solid #D1D5DB
- **Border Radius:** 6px
- **Padding:** 12px 16px
- **Font Size:** 16px
- **Focus Ring:** 2px solid #0D9488, outline-offset 2px
- **Placeholder Color:** #9CA3AF
- **Disabled State:** bg #F3F4F6, border #E5E7EB

## Navigation
- **Sticky:** position sticky, top 0
- **Backdrop Filter:** blur(10px)
- **Background:** rgba(255,255,255,0.9)
- **Link Style:** color #0F766E, text-decoration none
- **Link Hover:** color #0D6D67, border-bottom 2px solid #0D9488
- **Link Active:** border-bottom 2px solid #0F766E
```

### Sección 5: Layout Principles

Escala de espacios, sistema de grid, max-content-width, filosofía de whitespace, escala de border-radius.

**Placeholder:**
```
# 5. Layout Principles

## Spacing Scale
Use this modular scale for all margin, padding, and gap values:
- xs: 4px
- sm: 8px
- md: 12px
- base: 16px
- lg: 24px
- xl: 32px
- 2xl: 48px
- 3xl: 64px
- 4xl: 96px

## Grid System
- **Base Unit:** 8px
- **Columns:** 12-column responsive grid
- **Gutter:** 24px (desktop), 16px (tablet), 8px (mobile)
- **Max Content Width:** 1280px
- **Container Padding:** 24px (desktop), 16px (tablet), 12px (mobile)

## Whitespace Philosophy
Breathing room defines clarity. Ample whitespace creates focus and reduces cognitive load. Never crowd components; let them breathe.

## Border Radius Scale
- xs: 2px (subtle)
- sm: 4px (soft corners)
- md: 6px (default, most components)
- lg: 8px (cards, larger elements)
- full: 9999px (pills, fully rounded)
```

### Sección 6: Depth & Elevation

Tabla con: Level | Treatment | Use. Incluir párrafo sobre filosofía de sombras. Niveles: Flat (0), Ambient (1), Standard (2), Elevated (3), Deep (4), Ring (focus).

**Placeholder:**
```
# 6. Depth & Elevation

Shadows communicate hierarchy and depth. Each level serves a specific purpose: subtle elevation for interactive elements, deeper shadows for modal dialogs.

## Shadow Levels
| Level | Treatment | Use |
|-------|-----------|-----|
| 0 (Flat) | No shadow | Flat design, minimal elevation |
| 1 (Ambient) | 0 1px 2px rgba(0,0,0,0.08) | Subtle hover, slight lift |
| 2 (Standard) | 0 4px 8px rgba(0,0,0,0.12) | Cards, buttons hover |
| 3 (Elevated) | 0 8px 16px rgba(0,0,0,0.15) | Dropdowns, popovers |
| 4 (Deep) | 0 16px 32px rgba(0,0,0,0.2) | Modals, sidebars |
| Ring (Focus) | 0 0 0 2px #FFFFFF, 0 0 0 4px #0D9488 | Focus states |
```

### Sección 7: Do's and Don'ts

Listas de bullets con guardrails de diseño. Mínimo 8 Do's y 8 Don'ts.

**Placeholder:**
```
# 7. Do's and Don'ts

## Do's
- Use semantic colors consistently (error always = #EF4444)
- Maintain 16px minimum body text size
- Ensure hover states provide visual feedback on all interactive elements
- Use the spacing scale (4, 8, 12, 16, 24, 32, 48, 64, 96px)
- Apply proper focus rings (2px outline with 2px offset)
- Keep cards within the 8px radius scale
- Test contrast ratios (WCAG AA minimum)
- Use system fonts for performance (Inter is preferred)

## Don'ts
- Don't mix font families; stick to Inter + Fira Code
- Don't use arbitrary hex codes outside the color palette
- Don't apply shadows beyond the 4 defined levels
- Don't create custom spacing values; use the scale
- Don't disable focus rings without providing alternative focus indicators
- Don't use text smaller than 12px (captions only)
- Don't apply decorative shadows to cards (they have shadows)
- Don't forget responsive padding on mobile (reduce by 50%)
```

### Sección 8: Responsive Behavior

Tabla de breakpoints (Mobile <640, Tablet 640-1024, Desktop 1024-1280, Large >1280), touch targets, estrategia de collapsing, comportamiento de imágenes.

**Placeholder:**
```
# 8. Responsive Behavior

## Breakpoints
| Device | Range | Container Padding | Gutter |
|--------|-------|-------------------|--------|
| Mobile | < 640px | 12px | 8px |
| Tablet | 640px – 1024px | 16px | 16px |
| Desktop | 1024px – 1280px | 24px | 24px |
| Large | > 1280px | 24px | 24px |

## Touch Targets
- **Minimum Height:** 48px (touch devices)
- **Minimum Width:** 48px
- **Spacing Between Targets:** 8px minimum

## Collapsing Strategy
- Hide secondary navigation on mobile; show hamburger menu
- Stack cards vertically below 640px
- Reduce font sizes by 1–2 steps on mobile (h1: 48px → 32px)
- Collapse multi-column layouts to single column

## Image Behavior
- **Max Width:** 100% of container
- **Height:** auto (preserve aspect ratio)
- **Mobile:** Full-width images scale with container
- **Lazy Loading:** Use native lazy="lazy" attribute
```

### Sección 9: Agent Prompt Guide

Referencia rápida de colores (key-value pairs), 3-5 prompts de ejemplo para componentes con valores CSS EXACTOS, guía de iteración (5 reglas numeradas).

**Placeholder:**
```
# 9. Agent Prompt Guide

## Quick Color Reference
- **Primary:** #0F766E
- **Secondary:** #0D9488
- **Success:** #10B981
- **Warning:** #F59E0B
- **Error:** #EF4444
- **White:** #FFFFFF
- **Neutral-100:** #F3F4F6
- **Neutral-900:** #111827

## Component Prompt Examples

### Example 1: Hero Button
"Create a primary button with background #0F766E, white text, 16px padding horizontal/12px vertical, 6px border-radius, 600 weight, 0 1px 2px shadow. On hover: bg #0D6D67, shadow 0 4px 8px. On focus: 2px outline #0D9488 with 2px offset."

### Example 2: Card Component
"Build a card with white background (#FFFFFF), 1px border #E5E7EB, 8px border-radius, 24px padding, 0 1px 3px shadow. On hover: shadow 0 4px 12px, border #D1D5DB. Use Inter 16px for body text."

### Example 3: Navigation Bar
"Sticky nav with rgba(255,255,255,0.9) background, backdrop-filter blur(10px), 24px padding. Links are #0F766E, no decoration. Hover: #0D6D67 with bottom border 2px. Active links: bottom border 2px #0F766E."

### Example 4: Input Field
"Text input 16px Inter, white bg, 1px #D1D5DB border, 6px radius, 12px vertical / 16px horizontal padding. Placeholder #9CA3AF. Focus: 2px #0D9488 outline with 2px offset."

### Example 5: Badge
"Small badge: 12px Inter Medium, 4px padding, 9999px border-radius, neutral-100 background, neutral-900 text. Use for labels and status indicators."

## Iteration Guide
1. Always check the color palette before using hex codes; use semantic names (primary, error, success)
2. Apply shadows only from the 4 defined levels; never create custom shadows
3. Test responsive behavior at 640px, 1024px, and 1280px breakpoints
4. Ensure all interactive elements have focus rings (2px outline with 2px offset)
5. Maintain spacing consistency using the 4/8/12/16/24/32/48/64/96px scale
```

---

## Cómo Extraer Design de Sitios Existentes

Sigue este proceso paso a paso para documentar un design system de un sitio web:

### Paso 1: Colores Base
Abre DevTools (F12), inspecciona `<body>` y `<html>`. Busca:
- Background color
- Text color principal
- Variables CSS en `:root` (--color-primary, --bg, etc.)

Guarda los valores hex.

### Paso 2: Tipografía
Inspecciona `<h1>`, `<h2>`, `<p>`:
- font-family
- font-size
- font-weight
- letter-spacing
- color

### Paso 3: Botones
Inspecciona un botón `<button>`:
- background-color
- color (text)
- padding
- border-radius
- box-shadow
- Hover state (usa `:hover` en DevTools)
- Focus state

### Paso 4: Cards
Inspecciona un `.card` o componente contenedor:
- border
- border-radius
- box-shadow
- padding
- background-color
- Hover effects

### Paso 5: Variables CSS
Abre DevTools → Console y ejecuta:
```javascript
getComputedStyle(document.documentElement)
```
Busca `--` variables para tokens de diseño.

### Paso 6: Espacios
Inspecciona padding/margin en:
- Container principal
- Gaps entre componentes
- Padding dentro de cards/botones

### Paso 7: Breakpoints
Abre DevTools → Device Toolbar. Cambia viewport width y observa dónde el layout cambia. Nota los valores en media queries del CSS.

---

## Colección de Referencias

20+ archivos DESIGN.md reales están disponibles en `design-md-references/`:
- vercel
- supabase
- linear.app
- cursor
- expo
- framer
- notion
- figma
- cal
- resend
- mintlify
- posthog
- claude
- stripe
- apple
- airbnb
- spotify
- tesla
- nvidia
- spacex

**Descargar más referencias:**
```bash
npx getdesign@latest add [site-name]
```

---

## Integración con Agentes IA

### Cómo usar DESIGN.md

1. **Coloca el archivo en la raíz del proyecto:**
   ```
   project/
   ├── DESIGN.md
   ├── src/
   └── ...
   ```

2. **Instrúye al agente:**
   > "Build me a landing page using the design system in DESIGN.md. Use the primary color for buttons and apply the card component styling from section 4."

3. **Compatible con:**
   - Claude Code
   - Cursor
   - Windsurf
   - Cline
   - Google Stitch
   - Vercel V0

---

## Ejemplo: DESIGN.md Completo Mínimo

```markdown
# DESIGN.md — TechStartup SaaS

## 1. Visual Theme & Atmosphere

Modern dark-mode SaaS with emerald accents. Clean, minimal interface emphasizing clarity. 
High contrast supports readability and reduces eye strain for extended screen time. 
Smooth interactions and precise spacing create a premium feel.

**Key Characteristics:**
- Dark backgrounds (neutral-900 on black)
- Emerald accent (#10B981) for primary actions
- Generous whitespace
- Smooth micro-interactions
- High contrast text (white on dark)

## 2. Color Palette & Roles

| Color Name | Hex | Role |
|-----------|-----|------|
| primary | #10B981 | Primary buttons, links |
| bg-dark | #0F172A | Main background |
| bg-card | #1E293B | Card background |
| text-light | #E2E8F0 | Body text |
| text-muted | #94A3B8 | Secondary text |
| error | #EF4444 | Errors |

## 3. Typography Rules

**Font:** Inter, Helvetica, sans-serif

| Role | Font | Size | Weight | Line Height |
|------|------|------|--------|-------------|
| h1 | Inter | 48px | 700 | 1.2 |
| h2 | Inter | 32px | 600 | 1.3 |
| body | Inter | 16px | 400 | 1.5 |
| small | Inter | 14px | 400 | 1.5 |

## 4. Component Stylings

**Primary Button:** bg #10B981, white text, 12px/24px padding, 6px radius, 0 1px 2px shadow. Hover: bg #059669, shadow 0 4px 8px.

**Card:** bg #1E293B, 1px border #334155, 8px radius, 24px padding, 0 1px 3px shadow.

**Input:** bg #0F172A, 1px border #334155, 6px radius, 12px/16px padding, white text, placeholder #64748B.

## 5. Layout Principles

**Spacing Scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96px

**Grid:** 12 columns, 24px gutter

**Max Width:** 1280px

## 6. Depth & Elevation

| Level | Shadow |
|-------|--------|
| 1 | 0 1px 2px rgba(0,0,0,0.3) |
| 2 | 0 4px 8px rgba(0,0,0,0.4) |
| 3 | 0 8px 16px rgba(0,0,0,0.5) |

## 7. Do's and Don'ts

**Do's:** Use emerald for CTAs. Maintain 16px body size. Apply focus rings.

**Don'ts:** Don't use colors outside palette. Don't skip focus states. Don't reduce touch targets below 48px.

## 8. Responsive Behavior

| Breakpoint | < 640px | 640–1024px | > 1024px |
|------------|---------|------------|----------|
| Padding | 12px | 16px | 24px |
| Layout | Stack | 2 columns | 3 columns |

## 9. Agent Prompt Guide

**Colors:** primary #10B981, bg #0F172A, card #1E293B, text #E2E8F0

**Button Prompt:** "Create a button: bg #10B981, white text, 16px Inter 600, 12px/24px padding, 6px radius, 0 1px 2px shadow. Hover: bg #059669, shadow 0 4px 8px. Focus: 2px #10B981 outline."

**Use the design system above for all UI generation.**
```

---

## Resumen Rápido

**Cuándo crear un DESIGN.md:**
- Cuando necesitas que un agente genere UI consistente
- Para documentar un design system existente
- Para diseño de productos y startups
- Para extraer y preservar estilo visual de aplicaciones

**Lo que obtienes:**
- UI pixel-perfect generada por IA
- Componentes consistentes
- Design tokens centralizados
- Documentación legible por máquinas

**Siguiente paso:** Coloca tu DESIGN.md en la raíz, instruye el agente, y déjalo construir.
