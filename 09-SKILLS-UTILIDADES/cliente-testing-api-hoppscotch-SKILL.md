---
name: api-testing-client
description: >
  Cliente API open-source para testear REST, GraphQL, WebSocket, SSE, MQTT y Socket.IO desde el
  navegador. Colecciones, entornos, generación de código, CLI para CI/CD. Basado en Hoppscotch
  (Vue.js + Nuxt). Usar cuando el usuario mencione: testear API, probar endpoint, API client,
  Postman alternativa, Insomnia alternativa, Hoppscotch, testear REST, GraphQL, WebSocket,
  debug de webhook, colecciones de API, generar código desde request, HTTP client.
tags:
  - api-testing
  - rest
  - graphql
  - websocket
  - postman
  - http-client
  - developer-tools
  - debugging
  - webhooks
repo: https://github.com/semaes111/api-testing-rest-graphql-websocket
upstream: https://github.com/hoppscotch/hoppscotch
license: MIT
stack:
  - Vue.js 3
  - Nuxt 3
  - Tailwind
  - Prisma
  - PostgreSQL
  - Tauri
---

# SKILL: API Testing y Desarrollo — REST, GraphQL, WebSocket (Hoppscotch)

## Repo de referencia

- **Local:** https://github.com/semaes111/api-testing-rest-graphql-websocket
- **Upstream:** https://github.com/hoppscotch/hoppscotch (⭐ 78K+ | MIT)
- **Docs:** https://docs.hoppscotch.io
- **SaaS:** https://hoppscotch.io

## Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend | Vue.js 3 + Nuxt 3 |
| UI | Tailwind CSS |
| Backend (self-hosted) | Node.js + Prisma + PostgreSQL |
| Auth (self-hosted) | Email + OAuth2 (Google, GitHub, Microsoft) |
| Realtime testing | WebSocket, SSE, MQTT, Socket.IO nativos |
| Desktop app | Tauri (Rust wrapper) |

## Protocolos soportados

| Protocolo | Funcionalidad |
|---|---|
| REST | GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS — con body, headers, params, auth |
| GraphQL | Queries, mutations, subscriptions — con explorador de schema |
| WebSocket | Conectar, enviar/recibir mensajes, ver frames |
| SSE | Server-Sent Events — escuchar streams |
| MQTT | Publish/subscribe a topics |
| Socket.IO | Conectar a servidores Socket.IO |

## Funcionalidades clave

- **Colecciones:** Organizar requests en carpetas y compartir con el equipo
- **Entornos:** Variables por entorno (dev, staging, prod) — `{{BASE_URL}}`, `{{API_KEY}}`
- **Pre-request scripts:** JavaScript que se ejecuta antes de cada request
- **Tests:** Assertions post-request para validar respuestas
- **Historial:** Todas las requests guardadas con timestamp
- **Code generation:** Generar código en cURL, JavaScript, Python, Go, PHP, etc.
- **Importar:** Colecciones de Postman, OpenAPI/Swagger, cURL commands
- **CLI:** `hopp-cli` para ejecutar colecciones desde terminal/CI

## Deploy self-hosted

### Docker Compose (recomendado)
```yaml
# docker-compose.yml
version: '3'
services:
  hoppscotch:
    image: hoppscotch/hoppscotch:latest
    ports:
      - "3000:3000"   # App principal
      - "3100:3100"   # Admin panel
      - "3170:3170"   # Backend API
    environment:
      DATABASE_URL: "postgresql://postgres:password@db:5432/hoppscotch"
      TOKEN_SALT_COMPLEXITY: 10
      MAGIC_LINK_TOKEN_VALIDITY: 3
      REFRESH_TOKEN_VALIDITY: "604800000"
      ACCESS_TOKEN_VALIDITY: "86400000"
      SESSION_SECRET: "GENERAR_SECRET_LARGO"
      REDIRECT_URL: "https://api-tools.nexthorizont.ai"
      WHITELISTED_ORIGINS: "https://api-tools.nexthorizont.ai"
      MAILER_SMTP_URL: "smtps://user:pass@smtp.email.com"
      MAILER_ADDRESS_FROM: "tools@nexthorizont.ai"
      # Auth providers
      GOOGLE_CLIENT_ID: "..."
      GOOGLE_CLIENT_SECRET: "..."
      GITHUB_CLIENT_ID: "..."
      GITHUB_CLIENT_SECRET: "..."
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: hoppscotch
      POSTGRES_PASSWORD: password
    volumes:
      - hoppdata:/var/lib/postgresql/data

volumes:
  hoppdata:
```

```bash
docker compose up -d
# → App: https://api-tools.nexthorizont.ai
# → Admin: https://api-tools.nexthorizont.ai:3100
```

## Uso práctico — Colecciones para NextHorizont

### Colección: Supabase APIs
```json
{
  "name": "Supabase - Centro NICA",
  "folders": [
    {
      "name": "Pacientes",
      "requests": [
        {
          "name": "Listar pacientes activos",
          "method": "GET",
          "endpoint": "{{SUPABASE_URL}}/rest/v1/pacientes?estado=eq.activo&select=*",
          "headers": [
            { "key": "apikey", "value": "{{SUPABASE_ANON_KEY}}" },
            { "key": "Authorization", "value": "Bearer {{SUPABASE_ANON_KEY}}" }
          ]
        },
        {
          "name": "Crear paciente",
          "method": "POST",
          "endpoint": "{{SUPABASE_URL}}/rest/v1/pacientes",
          "body": {
            "nombre": "Test Paciente",
            "peso": 90,
            "objetivo": "perder 15kg"
          }
        }
      ]
    }
  ]
}
```

### Colección: n8n Webhooks
```
📁 n8n Workflows
  ├── POST {{N8N_URL}}/webhook/nuevo-paciente
  ├── POST {{N8N_URL}}/webhook/alma-report
  ├── POST {{N8N_URL}}/webhook/skyclaud-trigger
  └── GET  {{N8N_URL}}/webhook/health-check
```

### Colección: Evolution API (WhatsApp)
```
📁 Evolution API
  ├── POST {{EVOLUTION_URL}}/message/sendText
  ├── GET  {{EVOLUTION_URL}}/instance/connectionState
  ├── POST {{EVOLUTION_URL}}/instance/create
  └── POST {{EVOLUTION_URL}}/message/sendMedia
```

### Entornos
```json
{
  "dev": {
    "SUPABASE_URL": "http://localhost:54321",
    "SUPABASE_ANON_KEY": "eyJ...",
    "N8N_URL": "http://localhost:5678",
    "EVOLUTION_URL": "http://localhost:8080"
  },
  "prod": {
    "SUPABASE_URL": "https://bpazmmbjjducdmxgfoum.supabase.co",
    "SUPABASE_ANON_KEY": "eyJ...",
    "N8N_URL": "https://n8n.nexthorizont.ai",
    "EVOLUTION_URL": "https://evolution.nexthorizont.ai"
  }
}
```

## CLI para CI/CD

```bash
# Instalar CLI
npm install -g @hoppscotch/cli

# Ejecutar colección completa (smoke test de APIs)
hopp test -e prod.json coleccion-supabase.json

# En GitHub Actions o pipeline
- name: API Smoke Tests
  run: hopp test -e environments/prod.json collections/critical-apis.json
```

## Generación de código

Desde cualquier request puedes generar código en:
- cURL
- JavaScript (fetch, axios, jQuery)
- Python (requests, http.client)
- Go (net/http)
- PHP (cURL, Guzzle)
- Ruby (net/http)
- Java (OkHttp, Unirest)
- C# (HttpClient, RestSharp)
- Kotlin, Swift, Rust, Dart...

## Casos de uso para NextHorizont

### Desarrollo diario
- Testear endpoints de Supabase antes de conectar el frontend
- Debug de webhooks de Stripe, n8n, Evolution API
- Verificar respuestas de Edge Functions

### QA y testing
- Colecciones de smoke tests para ejecutar antes de cada deploy
- Validar que todos los webhooks de n8n responden correctamente
- Test de carga básico con requests repetidas

### Documentación viva
- Las colecciones sirven como documentación de las APIs del proyecto
- Compartir colecciones con colaboradores o clientes
- Exportar como OpenAPI spec para generar docs automáticas

### Alternativa rápida (sin self-host)
- Usar directamente https://hoppscotch.io sin instalar nada
- Los datos se guardan localmente en el navegador
- Para equipo: self-host para compartir colecciones y entornos
