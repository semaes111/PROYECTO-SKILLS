---
name: 21st-dev-registry-componentes
description: >
  Registry comunitario 21st.dev de componentes React/Tailwind/shadcn-ui con
  +2000 componentes listos para instalar via CLI. This skill should be used
  when the user asks to "add a hero section", "install a pricing component",
  "find a button component", "use 21st.dev", "shadcn community registry",
  "browse UI components", "AI chat component", "landing page sections",
  "testimonials component", "CTA section", or needs pre-built React UI
  components with Tailwind CSS for Next.js projects.
---

# 21st.dev — Registry Comunitario de Componentes React

## Qué es

[21st.dev](https://21st.dev) es el mayor registry comunitario open-source de componentes React
basado en el ecosistema **shadcn/ui**. Funciona como un "npm para design engineers":
cualquier desarrollador puede publicar, descubrir e instalar componentes.

- **+2000 componentes** publicados por la comunidad
- **5.2K stars** en GitHub ([serafimcloud/21st](https://github.com/serafimcloud/21st))
- **1.4M desarrolladores**, 200K MAU
- **Licencia MIT** — el código es tuyo, no es un paquete npm

**Stack del registry:** Next.js 14 + Supabase + Cloudflare R2 + Tailwind CSS + Radix UI

---

## Instalación de componentes

### Método 1: URL directa (recomendado)

```bash
npx shadcn@latest add "https://21st.dev/r/[usuario]/[componente]"
```

**Ejemplos reales:**

```bash
# Hero sections
npx shadcn@latest add "https://21st.dev/r/xubohuah/flickering-grid-hero"
npx shadcn@latest add "https://21st.dev/r/easemize/hero-with-video"
npx shadcn@latest add "https://21st.dev/r/uniquesonu/animated-hero-section-ui"
npx shadcn@latest add "https://21st.dev/r/meschacirung/hero-section-5"

# Pricing sections
npx shadcn@latest add "https://21st.dev/r/brijr/pricing-section"
npx shadcn@latest add "https://21st.dev/r/bankk/pricing-card"
npx shadcn@latest add "https://21st.dev/r/vaib215/squishy-pricing"

# Buttons
npx shadcn@latest add "https://21st.dev/r/originui/button"
npx shadcn@latest add "https://21st.dev/r/easemize/material-design-3-button"
npx shadcn@latest add "https://21st.dev/r/easemize/hover-glow-button"

# AI Chat components
npx shadcn@latest add "https://21st.dev/r/easemize/ai-prompt-box"
npx shadcn@latest add "https://21st.dev/r/kokonutd/v0-ai-chat"
npx shadcn@latest add "https://21st.dev/r/jatin-yadav05/animated-ai-chat"
npx shadcn@latest add "https://21st.dev/r/kokonutd/animated-ai-input"
```

### Método 2: Namespace en components.json (multi-registry)

Configurar en `components.json` del proyecto:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "registries": {
    "@21st": "https://21st.dev/r/{name}.json",
    "@magic": "https://magicui.design/r/{name}.json"
  }
}
```

Luego instalar con namespace:

```bash
npx shadcn@latest add @21st/hero-section
npx shadcn@latest add @magic/animated-beam
```

### Método 3: Desde archivo JSON local

```bash
npx shadcn@latest add ./registry/items/mi-componente.json
```

---

## Catálogo de componentes por categoría

### Volumen por categoría (abril 2026)

| Categoría | Cantidad aprox. | Uso principal |
|-----------|----------------|---------------|
| **Heroes** | 284 | Landing pages, headers con animación |
| **Buttons** | 250 | CTAs, acciones, efectos hover/glow |
| **AI Chat** | 30+ | Prompt boxes, chat interfaces, agent UI |
| **Pricing** | 49 | Planes, comparadores, pricing cards |
| **Testimonials** | 40+ | Social proof, reviews, carousels |
| **Features** | 60+ | Feature grids, bento, comparativas |
| **CTAs** | 35+ | Call-to-action sections, banners |
| **Cards** | 80+ | Product cards, profile cards, stat cards |
| **Text/Typography** | 25+ | Animated text, gradients, typewriters |
| **Shaders** | 15+ | WebGL backgrounds, efectos visuales |
| **Navigation** | 30+ | Navbars, sidebars, breadcrumbs |
| **Forms/Inputs** | 45+ | OTP inputs, search bars, selects |
| **Modals/Dialogs** | 20+ | Sheets, drawers, command palettes |
| **Agent Templates** | 10+ | Full agent UIs, plan viewers, toolbars |

### Top 10 componentes más populares (por bookmarks)

| # | Componente | Creador | Bookmarks | Categoría |
|---|-----------|---------|-----------|-----------|
| 1 | ai-prompt-box | easemize | 275 | AI Chat |
| 2 | v0-ai-chat | kokonutd | 265 | AI Chat |
| 3 | animated-ai-chat | jatin-yadav05 | 236 | AI Chat |
| 4 | agent-plan | isaiahbjork | 215 | Agent UI |
| 5 | chatgpt-prompt-input | easemize | 141 | AI Chat |
| 6 | ai-gen | aliimam | 101 | AI Chat |
| 7 | animated-ai-input | kokonutd | 96 | AI Chat |
| 8 | message-dock | isaiahbjork | 85 | Agent UI |
| 9 | hero-with-video | easemize | ~80 | Hero |
| 10 | flickering-grid-hero | xubohuah | ~75 | Hero |

---

## Dependencias comunes

Los componentes de 21st.dev típicamente usan estas dependencias (el CLI las instala automáticamente):

```json
{
  "dependencies": {
    "@radix-ui/react-*": "Primitivas accesibles (dialog, dropdown, tooltip, etc.)",
    "class-variance-authority": "Variants para componentes (cva)",
    "clsx": "Merge de classNames condicional",
    "tailwind-merge": "Merge inteligente de clases Tailwind",
    "lucide-react": "Iconos SVG",
    "framer-motion": "Animaciones declarativas (muchos heroes/pricing)",
    "input-otp": "Input OTP (componentes de verificación)",
    "cmdk": "Command palette (⌘K)"
  }
}
```

**Requisitos del proyecto destino:**

```bash
# Mínimo necesario
npx create-next-app@latest mi-app --typescript --tailwind --eslint
cd mi-app
npx shadcn@latest init
```

---

## Registries alternativos compatibles

El ecosistema shadcn soporta múltiples registries que usan el mismo CLI:

| Registry | URL base | Enfoque | Stars |
|----------|----------|---------|-------|
| **shadcn/ui** (oficial) | `ui.shadcn.com` | Base components | 82K+ |
| **21st.dev** | `21st.dev/r/` | Comunidad + AI | 5.2K |
| **Magic UI** | `magicui.design/r/` | Animated components | 12K+ |
| **Aceternity UI** | `ui.aceternity.com` | Premium animated | 8K+ |
| **Origin UI** | `originui.com` | Beautiful defaults | 3K+ |
| **shadcn.io** | `shadcn.io` | AI-native clone | ~2K |
| **Shadcn Studio** | `shadcnstudio.com` | Templates/Blocks | ~1K |

Configuración multi-registry completa:

```json
{
  "registries": {
    "@21st": "https://21st.dev/r/{name}.json",
    "@magic": "https://magicui.design/r/{name}.json",
    "@origin": "https://originui.com/r/{name}.json"
  }
}
```

---

## Crear tu propio registry (publicar componentes)

### Estructura de archivos

```
mi-registry/
├── registry.json              # Manifiesto del registry
├── registry/
│   └── new-york/
│       └── mi-componente/
│           └── mi-componente.tsx
├── public/
│   └── r/                     # Output del build (JSON servible)
│       └── mi-componente.json
└── package.json
```

### registry.json

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry.json",
  "name": "mi-registry",
  "homepage": "https://mi-dominio.com",
  "items": [
    {
      "name": "mi-componente",
      "type": "registry:block",
      "title": "Mi Componente",
      "description": "Descripción del componente.",
      "dependencies": ["framer-motion"],
      "files": [
        {
          "path": "registry/new-york/mi-componente/mi-componente.tsx",
          "type": "registry:component"
        }
      ]
    }
  ]
}
```

### Build y publicación

```bash
# Añadir script
# package.json: "scripts": { "registry:build": "shadcn build" }

pnpm registry:build
# Output → public/r/mi-componente.json

# Cualquier hosting estático sirve (Vercel, Cloudflare Pages, GitHub Pages)
```

### Template oficial de shadcn

```bash
git clone https://github.com/shadcn-ui/registry-template
cd registry-template
pnpm install
pnpm dev
# → http://localhost:3000/r/hello-world.json
```

---

## Patrones de uso recomendados

### 1. Landing page rápida (5 componentes)

```bash
npx shadcn@latest add "https://21st.dev/r/easemize/hero-with-video"
npx shadcn@latest add "https://21st.dev/r/shadcnblockscom/shadcnblocks-com-hero45"
npx shadcn@latest add "https://21st.dev/r/brijr/pricing-section"
npx shadcn@latest add "https://21st.dev/r/originui/button"
npx shadcn@latest add "https://21st.dev/r/easemize/ai-prompt-box"
```

### 2. Dashboard con AI chat

```bash
npx shadcn@latest add "https://21st.dev/r/kokonutd/v0-ai-chat"
npx shadcn@latest add "https://21st.dev/r/isaiahbjork/agent-plan"
npx shadcn@latest add "https://21st.dev/r/kokonutd/animated-ai-input"
npx shadcn@latest add "https://21st.dev/r/isaiahbjork/message-dock"
```

### 3. SaaS pricing page

```bash
npx shadcn@latest add "https://21st.dev/r/bankk/pricing-card"
npx shadcn@latest add "https://21st.dev/r/vaib215/squishy-pricing"
npx shadcn@latest add "https://21st.dev/r/efferd/single-pricing-card"
```

---

## Notas técnicas

1. **El código es tuyo**: A diferencia de npm packages, `npx shadcn add` copia el código fuente
   a tu proyecto en `components/ui/`. Puedes modificarlo libremente.

2. **No hay lock-in**: Si 21st.dev desaparece mañana, tu código sigue funcionando
   porque es local. No hay imports remotos en runtime.

3. **Cada componente incluye**: TypeScript tipado, Tailwind CSS, demos separados del
   componente, y lista explícita de dependencias npm.

4. **Compatibilidad**: React 18/19 + Next.js 13/14/15 + Tailwind CSS 3/4.

5. **Rate limits**: El registry público no tiene rate limits para `npx shadcn add`.
   El MCP server Magic (generación por IA) sí tiene límites mensuales en beta.

6. **Explorar antes de instalar**: Visita `https://21st.dev/community/components/s/[categoría]`
   para previews en vivo antes de instalar.
   - Heroes: `https://21st.dev/community/components/s/hero`
   - Buttons: `https://21st.dev/community/components/s/button`
   - Pricing: `https://21st.dev/community/components/s/pricing-section`
   - AI Chat: `https://21st.dev/community/components/s/ai-chat`
