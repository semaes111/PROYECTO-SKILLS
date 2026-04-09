---
name: awesome-design-md-catalogo
description: >
  Catálogo de 58 archivos DESIGN.md extraídos de sitios reales (Vercel, Stripe,
  Supabase, etc.) para que agentes IA generen UI consistente con esos estilos.
  This skill should be used when the user asks to "use Vercel's design",
  "build like Stripe", "replicate Linear style", "copy Notion design",
  "design like Apple", "Supabase-style UI", "dark mode like Spotify",
  "use a real design system", or needs to apply a specific brand's visual
  identity to a project using DESIGN.md references.
---

# awesome-design-md Catálogo

## Qué es awesome-design-md

**awesome-design-md** es una colección curada de 58 archivos DESIGN.md extraídos de sitios web reales (Vercel, Stripe, Supabase, Linear, Notion, Figma, y muchos más). Forma parte de [VoltAgent](https://github.com/voltagent/awesome-design-md) con 37K+ estrellas en GitHub bajo licencia MIT.

Cada DESIGN.md captura la identidad visual completa de un sitio real en un formato que agentes de IA entienden nativamente: colores, tipografía, componentes, espaciado, animaciones, y patrones de diseño específicos de cada marca.

## Cómo usar el catálogo

### Método A: CLI Install
```bash
npx getdesign@latest add [site]
```
Descarga el DESIGN.md del sitio especificado directamente a tu proyecto root.

### Método B: Referencias pre-descargadas
20 DESIGN.md están disponibles localmente en `design-md-references/`:
- `vercel-DESIGN.md`
- `supabase-DESIGN.md`
- `linear.app-DESIGN.md`
- `cursor-DESIGN.md`
- `expo-DESIGN.md`
- `framer-DESIGN.md`
- `notion-DESIGN.md`
- `figma-DESIGN.md`
- `cal-DESIGN.md`
- `resend-DESIGN.md`
- `mintlify-DESIGN.md`
- `posthog-DESIGN.md`
- `claude-DESIGN.md`
- `stripe-DESIGN.md`
- `apple-DESIGN.md`
- `airbnb-DESIGN.md`
- `spotify-DESIGN.md`
- `tesla-DESIGN.md`
- `nvidia-DESIGN.md`
- `spacex-DESIGN.md`

### Método C: Instrucción directa
Dile al agente: _"Lee design-md-references/[site]-DESIGN.md y construye una página que coincida con ese estilo"_

---

## Catálogo Completo (58 sitios)

### AI & Machine Learning (12)
| Sitio | CLI name | Estilo | Úsalo para |
|-------|----------|--------|-----------|
| Claude | claude | Minimalist + conversational | Chat interfaces, interfaces de IA |
| Cohere | cohere | Clean enterprise | Herramientas de NLP empresariales |
| ElevenLabs | elevenlabs | Modern + audio-focused | Apps de síntesis de voz |
| Minimax | minimax | Sleek Chinese design | Interfaces de LLM internacionales |
| Mistral.ai | mistral.ai | Minimalist + European | API platforms para modelos |
| Ollama | ollama | Developer-friendly | Local LLM interfaces |
| OpenCode.ai | opencode.ai | Bold + educational | Plataformas de código abierto |
| Replicate | replicate | Clean + functional | APIs de ML/generativas |
| Runway ML | runwayml | Creative + dark | Herramientas de creative AI |
| Together.ai | together.ai | Modern + distributed | Plataformas de IA colaborativas |
| VoltAgent | voltagent | Futuristic + agent-first | Agent orchestration UIs |
| X.ai (Grok) | x.ai | Bold + edgy | Interfaces de chat premium |

### Developer Tools & Platforms (14)
| Sitio | CLI name | Estilo | Úsalo para |
|-------|----------|--------|-----------|
| Cursor | cursor | Dark premium + minimalist | Code editors, IDEs |
| Expo | expo | Modern + mobile-centric | React Native platforms |
| Linear.app | linear.app | Dark mode masterpiece | Issue tracking, project management |
| Lovable | lovable | Clean + warm | AI design tools |
| Mintlify | mintlify | Documentation + elegant | Developer docs, API references |
| PostHog | posthog | Bold colorful | Analytics dashboards |
| Raycast | raycast | Minimal + fast | Command palettes, productivity tools |
| Resend | resend | Clean minimalist | Email platforms, API dashboards |
| Sentry | sentry | Dark + alerting | Error monitoring dashboards |
| Supabase | supabase | Dark + green accent | Backend platforms, databases |
| Superhuman | superhuman | Premium + email-focused | Communication tools |
| Vercel | vercel | Minimal + cutting-edge | Deployment, hosting dashboards |
| Warp | warp | Modern terminal aesthetic | Terminal apps, CLI tools |
| Zapier | zapier | Warm + friendly | Automation, workflow builders |

### Infrastructure & Cloud (6)
| Sitio | CLI name | Estilo | Úsalo para |
|-------|----------|--------|-----------|
| ClickHouse | clickhouse | Technical + database-focused | Data warehouses |
| Composio | composio | Integration-friendly | API integration platforms |
| HashiCorp | hashicorp | Enterprise + serious | Infrastructure tools |
| MongoDB | mongodb | Green accent + modern | NoSQL database platforms |
| Sanity | sanity | Creative + minimal | Headless CMS, content platforms |
| Stripe | stripe | Enterprise premium | Payments, fintech dashboards |

### Design & Productivity (10)
| Sitio | CLI name | Estilo | Úsalo para |
|-------|----------|--------|-----------|
| Airtable | airtable | Colorful + productive | Database UIs, no-code tools |
| Cal | cal | Minimalist + scheduling | Calendar, booking platforms |
| Clay | clay | Modern + professional | B2B platforms, data tools |
| Figma | figma | Bold + colorful | Design tools, creative platforms |
| Framer | framer | Creative + interactive | Design systems, interactive builders |
| Intercom | intercom | Warm + supportive | Customer support, messaging |
| Miro | miro | Colorful + collaborative | Whiteboarding, brainstorming tools |
| Notion | notion | Friendly + minimal | Documentation, knowledge bases |
| Pinterest | pinterest | Visual + inspiring | Social platforms, galleries |
| Webflow | webflow | Creative + purple accent | Visual builders, design platforms |

### Fintech & Crypto (4)
| Sitio | CLI name | Estilo | Úsalo para |
|-------|----------|--------|-----------|
| Coinbase | coinbase | Modern + financial | Crypto platforms, exchanges |
| Kraken | kraken | Dark + professional | Crypto trading, financial dashboards |
| Revolut | revolut | Bold + modern | FinTech apps, payments |
| Wise | wise | Clean + trustworthy | International payments, transfers |

### Enterprise & Consumer (7)
| Sitio | CLI name | Estilo | Úsalo para |
|-------|----------|--------|-----------|
| Airbnb | airbnb | Warm + friendly | Travel, marketplace platforms |
| Apple | apple | Minimalist + premium | Consumer products, luxury brands |
| IBM | ibm | Enterprise + serious | B2B platforms, corporate tools |
| NVIDIA | nvidia | Futuristic + bold | Tech products, gaming platforms |
| SpaceX | spacex | Futuristic + ambitious | Space-age, bold visuals |
| Spotify | spotify | Dark + music-focused | Music, entertainment, dark mode |
| Uber | uber | Modern + accessible | Transportation, gig economy |

### Car Brands (5)
| Sitio | CLI name | Estilo | Úsalo para |
|-------|----------|--------|-----------|
| BMW | bmw | Luxury + minimalist | Automotive, premium products |
| Ferrari | ferrari | Luxe + red accent | High-end, exclusive brands |
| Lamborghini | lamborghini | Bold + aggressive | Luxury cars, premium experiences |
| Renault | renault | Modern European | Automotive, clean design |
| Tesla | tesla | Futuristic + minimalist | Electric vehicles, futuristic tech |

---

## Referencias Pre-descargadas (20 sitios locales)

Estos DESIGN.md están disponibles inmediatamente en `design-md-references/`:

**Trending**: vercel, supabase, linear.app, cursor, expo, framer, notion, figma
**Enterprise**: stripe, apple, hashicorp
**Productivity**: cal, resend, mintlify, posthog
**AI/Modern**: claude, spacex, tesla, nvidia, spotify

---

## Referencia Rápida por Estilo Visual

| Quiero este estilo... | Usa este DESIGN.md |
|----------------------|-------------------|
| **Dark mode premium** | linear.app, cursor, supabase, spotify |
| **Clean minimalist** | vercel, cal, resend, notion, apple |
| **Bold & colorful** | figma, posthog, framer, airbnb, miro |
| **Enterprise serious** | stripe, hashicorp, ibm, apple, clay |
| **Futuristic** | spacex, tesla, nvidia, x.ai, voltagent |
| **Warm & friendly** | notion, airbnb, intercom, zapier |
| **Developer-first** | vercel, supabase, expo, cursor, resend |
| **Documentation** | mintlify, vercel, supabase |
| **Modern European** | linear.app, figma, notion, renault |
| **Luxury premium** | apple, stripe, airbnb, bmw, ferrari |

---

## Qué contiene cada DESIGN.md

Cada archivo DESIGN.md incluye estos 9 componentes:

1. **Color Palette** - Colores primarios, secundarios, neutrales, estados (hover, active, disabled) con valores hex/rgb
2. **Typography** - Fuentes, tamaños, weights, line heights, letter spacing para headings, body, labels
3. **Spacing System** - Escala de espaciado (8px, 16px, 24px, etc.) y reglas de uso
4. **Components** - Botones, inputs, cards, modals, navigation, badges con variantes
5. **Icons & Assets** - Guía de iconografía, estilos, tamaños recomendados
6. **Animations & Transitions** - Easing, duraciones, efectos de movimiento característicos
7. **Shadows & Elevation** - Sistema de profundidad visual
8. **Dark Mode** - Paleta alternativa para modo oscuro (si aplica)
9. **Usage Guidelines** - Patrones de composición, ejemplos de páginas reales

---

## Flujo Recomendado

1. **Elige un sitio** de referencia según el estilo deseado
2. **Descarga o referencia** el DESIGN.md (CLI o local)
3. **Lee el archivo** con el agente: _"Read this DESIGN.md and build a page matching this style"_
4. **Genera componentes** usando la paleta exacta, tipografía y espaciado
5. **Mantén consistencia** en animaciones y patrones de interacción

---

## Licencia & Créditos

Colección VoltAgent: MIT License | [GitHub](https://github.com/voltagent/awesome-design-md)

DESIGN.md es un formato abierto para especificaciones de diseño legibles por máquinas.
