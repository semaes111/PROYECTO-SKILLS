---
name: link-shortener-analytics
description: >
  Acortar URLs con dominio custom, generar QR codes dinámicos, analytics de clics en tiempo real,
  conversion tracking y programas de afiliados. Basado en Dub.co (Next.js + Tinybird + Upstash).
  Usar cuando el usuario mencione: acortar URLs, short links, link shortener, QR codes, analytics
  de clics, tracking de enlaces, conversion tracking, affiliate programs, custom domains para links,
  campaña de marketing con enlaces, bitly, rebrandly.
tags:
  - link-shortener
  - qr-codes
  - analytics
  - conversion-tracking
  - marketing
  - short-links
  - affiliate
repo: https://github.com/semaes111/link-shortener-analytics-platform
upstream: https://github.com/dubinc/dub
license: AGPL-3.0 (Open Core)
stack:
  - Next.js
  - Tailwind
  - Prisma
  - MySQL
  - Tinybird (ClickHouse)
  - Upstash Redis
  - Vercel
---

# SKILL: Link Shortener + Analytics + QR Codes

## Repo de referencia

- **Local:** https://github.com/semaes111/link-shortener-analytics-platform
- **Upstream:** https://github.com/dubinc/dub (⭐ 23K+ | AGPLv3 Open Core)
- **Docs:** https://dub.co/docs
- **API Reference:** https://dub.co/docs/api-reference/introduction

## Stack técnico

| Capa | Tecnología |
|---|---|
| Framework | Next.js (App Router) |
| UI | Tailwind CSS + componentes propios (`@dub/ui`) |
| ORM/DB relacional | Prisma + MySQL (PlanetScale) |
| Analytics time-series | Tinybird (ClickHouse managed) |
| Cache + Redirects | Upstash Redis |
| Background jobs | QStash (Upstash) |
| Deploy | Vercel |
| Monorepo | Turborepo + pnpm workspaces |

## Estructura del monorepo

```
apps/
  web/              → App principal (app.dub.co) + infraestructura de redirects
packages/
  cli/              → CLI para acortar URLs desde terminal
  email/            → Templates de email + función de envío
  embeds/           → Widget embebible de dashboard de referidos
  prisma/           → Schema de base de datos + migraciones
  stripe-app/       → Integración con Stripe
  tailwind-config/  → Config compartida de Tailwind
  tinybird/         → Datasources + pipes de ClickHouse (analytics)
  tsconfig/         → TypeScript config compartido
  ui/               → Librería de componentes React (@dub/ui)
  utils/            → Utilidades compartidas (@dub/utils)
```

## Arquitectura de analytics (patrón clave)

El patrón más valioso de este repo es la separación de concerns para analytics:

1. **Ingesta:** Cada clic en un short link genera un evento JSON enviado por HTTP al Events API de Tinybird
2. **Almacenamiento:** Tinybird (ClickHouse) almacena los eventos time-series con latencia write-to-read de ~2 segundos
3. **Consulta:** Pipes de Tinybird exponen endpoints REST parametrizados para queries analíticas (por dispositivo, geo, referrer, etc.)
4. **Visualización:** El frontend consume estos endpoints y renderiza dashboards con filtros en tiempo real

**Ventaja:** No se sobrecarga la DB relacional (MySQL) con queries analíticas. Cada capa hace lo suyo.

## API — Operaciones principales

### Autenticación
```bash
# Header requerido en todas las requests
Authorization: Bearer dub_xxxxxxxxxxxx
```

### Crear short link
```typescript
import { Dub } from "dub";

const dub = new Dub({ token: "DUB_API_KEY" });

const { shortLink } = await dub.links.create({
  url: "https://centronicaejido.com/consulta",
  domain: "links.nexthorizont.ai",  // dominio custom
  key: "consulta",                   // slug personalizado
  externalId: "paciente_123",        // ID externo para tracking
});
// → https://links.nexthorizont.ai/consulta
```

### Upsert link (crear o actualizar si existe)
```typescript
const { shortLink } = await dub.links.upsert({
  url: "https://centronicaejido.com/dieta-semana-4",
  domain: "links.nexthorizont.ai",
  key: "dieta-s4",
});
```

### Obtener analytics
```bash
curl -X GET "https://api.dub.co/analytics?domain=links.nexthorizont.ai&key=consulta&interval=30d" \
  -H "Authorization: Bearer dub_xxx"
```

### Listar links con paginación
```bash
curl -X GET "https://api.dub.co/links?page=1&pageSize=50&sort=clicks&order=desc" \
  -H "Authorization: Bearer dub_xxx"
```

## SDKs disponibles

| Lenguaje | Package | Instalación |
|---|---|---|
| TypeScript | `dub` | `npm install dub` |
| Python | `dub` | `pip install dub` |
| Go | `github.com/dubinc/dub-go` | `go get` |
| Ruby | `dub-ruby` | `gem install` |
| Dart/Flutter | `dub` | `pub.dev` |

## Casos de uso para NextHorizont

### Centro NICA
- Links cortos para compartir dietas por WhatsApp: `nica.link/dieta-juan`
- QR en consulta física que redirige a formulario de seguimiento
- Analytics de apertura por paciente (via externalId)
- Tracking de campañas de @noadelgazo (TikTok → landing → conversión)

### Bosques Biodiversos
- Links trackeables para inversores: `bosques.link/dossier-biochar`
- QR codes en documentación física de proyectos forestales
- Medir engagement de cada inversor con los materiales enviados

### Clínica Violeta
- Links para campañas de estética: `violeta.link/promo-verano`
- QR en tarjetas de visita que miden escaneos

## Adaptación a stack Supabase

Para replicar este patrón sin PlanetScale + Tinybird:

```
PlanetScale (MySQL)  →  Supabase (PostgreSQL)
Prisma ORM           →  Drizzle o Supabase client directo
Tinybird (ClickHouse)→  Opción A: Supabase + pg_partman (particiones por fecha)
                        Opción B: TimescaleDB extension en Supabase
                        Opción C: ClickHouse self-hosted en VPS
Upstash Redis        →  Mantener (o Supabase Realtime para cache ligero)
QStash               →  Trigger.dev (ver skill background-jobs) o pg_cron
```

## Self-hosting

```bash
git clone https://github.com/semaes111/link-shortener-analytics-platform.git
cd link-shortener-analytics-platform
pnpm i
pnpm -r --filter "./packages/**" build
cp apps/web/.env.example apps/web/.env
# Configurar: DATABASE_URL, TINYBIRD_API_URL, UPSTASH_REDIS_*, QSTASH_*
pnpm dev
```

## Rate limits (API SaaS)

| Plan | Requests/segundo |
|---|---|
| Free | 10 |
| Pro | 50 |
| Business | 200 |
| Enterprise | Custom |

## Referencia rápida de endpoints

| Método | Endpoint | Descripción |
|---|---|---|
| POST | `/links` | Crear link |
| PUT | `/links/upsert` | Crear o actualizar |
| GET | `/links` | Listar links |
| GET | `/links/{linkId}` | Obtener link |
| PATCH | `/links/{linkId}` | Actualizar link |
| DELETE | `/links/{linkId}` | Eliminar link |
| GET | `/analytics` | Obtener analytics |
| GET | `/qr` | Generar QR code |
| GET | `/domains` | Listar dominios |
