---
name: selfhosted-paas-deploy
description: >
  PaaS self-hosted alternativa a Vercel/Heroku/Netlify. Deploy de apps Docker con push-to-deploy,
  SSL automático, 280+ servicios one-click, gestión multi-servidor. Basado en Coolify (Laravel).
  Usar cuando el usuario mencione: self-hosting, PaaS, deploy en servidor propio, alternativa a
  Vercel/Heroku self-hosted, Coolify, desplegar apps Docker, gestionar contenedores, SSL automático,
  push-to-deploy, one-click services, reducir costes cloud.
tags:
  - paas
  - self-hosted
  - docker
  - deploy
  - coolify
  - devops
  - ssl
  - traefik
  - ci-cd
  - infrastructure
repo: https://github.com/semaes111/selfhosted-paas-docker-deploy
upstream: https://github.com/coollabsio/coolify
license: Apache-2.0
stack:
  - Laravel
  - PHP
  - Livewire
  - Docker
  - Traefik
  - PostgreSQL
---

# SKILL: Self-Hosted PaaS — Deploy Docker Apps en Tu Servidor (Coolify)

## Repo de referencia

- **Local:** https://github.com/semaes111/selfhosted-paas-docker-deploy
- **Upstream:** https://github.com/coollabsio/coolify (⭐ 35K+ | Apache 2.0)
- **Docs:** https://coolify.io/docs
- **Web:** https://coolify.io

## Stack técnico

| Capa | Tecnología |
|---|---|
| Backend | Laravel (PHP 8.2+) |
| Frontend | Livewire + Alpine.js + Tailwind |
| Reverse proxy | Traefik v2 (auto-config) |
| Containerización | Docker + Docker Compose |
| DB interna | PostgreSQL |
| SSL | Let's Encrypt (automático) |
| CI/CD | Webhooks Git (push-to-deploy) |

## Qué resuelve

- **Deploy automatizado** desde GitHub/GitLab/Bitbucket (push-to-deploy)
- **Builds Docker** automáticos (Dockerfile, Nixpacks, Buildpacks)
- **SSL automático** vía Let's Encrypt para todos los servicios
- **280+ servicios one-click:** Supabase, n8n, WordPress, PostgreSQL, Redis, MongoDB, Plausible, Grafana, etc.
- **Gestión multi-servidor** desde un panel único
- **Monitorización:** CPU, RAM, disco, logs centralizados
- **Backups automáticos** de bases de datos (S3 compatible)
- **Previews por PR** (como Vercel previews pero en tu servidor)

## Instalación (un comando)

```bash
# En un VPS limpio (Ubuntu 22.04+ / Debian 12+)
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

# Acceder al panel
# → http://TU_IP:8000 (primera vez: crear cuenta admin)
```

### Requisitos mínimos
- 2 CPU cores
- 2GB RAM (4GB recomendado)
- 30GB+ disco
- Ubuntu 22.04+ / Debian 12+ / CentOS / RHEL / SLES

## Flujo de deploy de una app

### 1. Conectar repositorio Git
```
Panel Coolify → New Resource → Application
  → Source: GitHub (conectar vía OAuth o deploy key)
  → Repo: semaes111/mi-app-nextjs
  → Branch: main
  → Build: Nixpacks (auto-detecta Next.js)
  → Domain: app.nexthorizont.ai
  → Deploy ✓
```

### 2. Variables de entorno
```
Panel → Application → Environment Variables
  DATABASE_URL=postgresql://...
  NEXT_PUBLIC_SUPABASE_URL=https://...
  SUPABASE_SERVICE_KEY=...
```

### 3. Push-to-deploy
```bash
# Cada push a main despliega automáticamente
git push origin main
# → Coolify detecta webhook → build → deploy → SSL → live
```

## Servicios one-click relevantes

| Servicio | Descripción | Puerto default |
|---|---|---|
| PostgreSQL | Base de datos relacional | 5432 |
| Redis | Cache/queue | 6379 |
| n8n | Workflow automation | 5678 |
| Supabase | Backend-as-a-Service completo | 3000 |
| Plausible | Analytics web privacy-friendly | 8000 |
| Grafana | Dashboards de monitorización | 3000 |
| Uptime Kuma | Monitor de uptime | 3001 |
| MinIO | Object storage S3-compatible | 9000 |
| Gitea | Git server self-hosted | 3000 |
| Ghost | Blog/CMS | 2368 |

## Comparativa con Dokploy (stack actual)

| Feature | Dokploy (actual) | Coolify |
|---|---|---|
| UI | Moderna, React | Moderna, Livewire |
| Reverse proxy | Traefik | Traefik |
| Build system | Nixpacks + Dockerfile | Nixpacks + Dockerfile + Buildpacks |
| One-click services | ~50 | 280+ |
| Multi-servidor | Sí | Sí |
| Preview deployments | Limitado | Completo (por PR) |
| Backups DB | Manual | Automáticos (S3) |
| Monitorización | Básica | Avanzada (métricas + logs) |
| Comunidad | Creciente | Muy activa (35K+ stars) |
| Webhooks Git | Sí | Sí |
| Docker Compose | Sí | Sí (deploy stack completo) |

## Arquitectura de red

```
Internet
  │
  ├── DNS (*.nexthorizont.ai → VPS IP)
  │
  └── VPS (31.97.69.100)
       │
       └── Traefik (reverse proxy + SSL)
            │
            ├── app.nexthorizont.ai     → Container Next.js (puerto 3000)
            ├── n8n.nexthorizont.ai     → Container n8n (puerto 5678)
            ├── api.nexthorizont.ai     → Container API (puerto 8080)
            ├── pb.nexthorizont.ai      → Container PocketBase (puerto 8090)
            └── monitor.nexthorizont.ai → Container Uptime Kuma (puerto 3001)
```

## Deploy via Docker Compose (avanzado)

```yaml
# docker-compose.coolify.yml
version: '3.8'
services:
  coolify:
    image: ghcr.io/coollabsio/coolify:latest
    ports:
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - coolify-data:/data
    environment:
      - APP_KEY=base64:GENERAR_KEY
    restart: unless-stopped

volumes:
  coolify-data:
```

## Casos de uso para NextHorizont

### Migración desde Dokploy
- Evaluar Coolify como reemplazo de Dokploy en el VPS Hostinger
- Ventaja: más servicios one-click, backups automáticos, preview deploys
- Riesgo: migración de configuración existente (containers, volumes, env vars)

### Multi-proyecto
- Deploy de todas las apps NextHorizont desde un solo panel
- Cada proyecto (Centro NICA, Violeta, Bosques) con su subdominio
- Variables de entorno centralizadas y versionadas

### Staging/Preview
- Preview automático por cada PR antes de merge a producción
- QA de features sin afectar producción

### Monitorización centralizada
- Dashboard único con estado de todos los servicios
- Alertas de caída, uso de recursos, logs de error

## Consideraciones de coexistencia con Dokploy

Si no quieres migrar completamente:
```bash
# Opción: Coolify en un segundo VPS o en otro puerto
# Coolify en puerto 9000, Dokploy mantiene 8000
# Traefik de Coolify en puertos 80/443 (si se migra el proxy)
# O mantener nginx actual y solo usar Coolify como builder
```

⚠️ **No instalar Coolify y Dokploy en el mismo servidor sin planificar puertos y proxy** — ambos intentan controlar Traefik/puertos 80/443.
