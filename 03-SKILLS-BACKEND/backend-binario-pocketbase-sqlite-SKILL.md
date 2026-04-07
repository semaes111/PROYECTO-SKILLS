---
name: single-file-backend-baas
description: >
  Backend completo en un solo binario (~15MB): DB SQLite, auth, file storage, admin panel y API REST
  auto-generada. Basado en PocketBase (Go). Usar cuando el usuario mencione: backend rápido, MVP backend,
  BaaS, PocketBase, backend sin configuración, SQLite backend, API auto-generada, auth + storage + DB en uno,
  prototipo rápido, backend portátil, backend embebido, alternativa ligera a Firebase/Supabase.
tags:
  - backend
  - baas
  - pocketbase
  - sqlite
  - mvp
  - prototyping
  - self-hosted
  - auth
  - storage
  - api-rest
repo: https://github.com/semaes111/single-file-backend-baas
upstream: https://github.com/pocketbase/pocketbase
license: MIT
stack:
  - Go
  - SQLite
  - Embedded Admin UI
---

# SKILL: Backend-as-a-Service en un solo binario (PocketBase)

## Repo de referencia

- **Local:** https://github.com/semaes111/single-file-backend-baas
- **Upstream:** https://github.com/pocketbase/pocketbase (⭐ 37K+ | MIT)
- **Docs:** https://pocketbase.io/docs
- **Demo:** https://pocketbase.io

## Stack técnico

| Capa | Tecnología |
|---|---|
| Lenguaje | Go |
| Base de datos | SQLite (embebida) |
| API | REST auto-generada desde schema |
| Realtime | SSE (Server-Sent Events) |
| Auth | Email/password + OAuth2 (Google, GitHub, Facebook, etc.) |
| Storage | File system local con thumbnails automáticos |
| Admin | Panel web embebido (SPA) |
| Binario | ~15MB, zero dependencies |

## Qué incluye (todo en un archivo)

```
pocketbase (binario único)
  ├── REST API auto-generada (CRUD completo)
  ├── Realtime subscriptions (SSE)
  ├── Auth system (email + OAuth2 + API keys)
  ├── File storage (local + S3 compatible)
  ├── Admin panel (UI web completa)
  ├── Schema builder visual
  ├── Logs viewer
  ├── Hooks system (JS o Go)
  └── Backup/restore integrado
```

## Inicio rápido

### Opción 1: Binario directo
```bash
# Descargar última release
wget https://github.com/pocketbase/pocketbase/releases/latest/download/pocketbase_0.X.X_linux_amd64.zip
unzip pocketbase_*.zip
./pocketbase serve
# → Admin UI: http://127.0.0.1:8090/_/
# → API:      http://127.0.0.1:8090/api/
```

### Opción 2: Docker
```bash
docker run -d \
  --name pocketbase \
  -p 8090:8090 \
  -v pb_data:/pb/pb_data \
  ghcr.io/pocketbase/pocketbase:latest
```

### Opción 3: Go embed (como librería)
```go
package main

import (
    "github.com/pocketbase/pocketbase"
    "github.com/pocketbase/pocketbase/core"
)

func main() {
    app := pocketbase.New()

    app.OnRecordCreate("pacientes").BindFunc(func(e *core.RecordEvent) error {
        // Hook personalizado al crear un paciente
        e.Record.Set("estado", "activo")
        return e.Next()
    })

    app.Start()
}
```

## API auto-generada — Ejemplos

Una vez creas una colección `pacientes` en el Admin UI:

### Listar registros
```bash
curl http://localhost:8090/api/collections/pacientes/records?page=1&perPage=50
```

### Crear registro
```bash
curl -X POST http://localhost:8090/api/collections/pacientes/records \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"nombre":"Juan","peso":95.5,"objetivo":"perder 15kg"}'
```

### Filtrar registros
```bash
# Sintaxis de filtros tipo SQL
curl "http://localhost:8090/api/collections/pacientes/records?filter=(peso>90%26%26estado='activo')"
```

### Realtime subscriptions
```javascript
import PocketBase from 'pocketbase';

const pb = new PocketBase('http://localhost:8090');

// Escuchar cambios en tiempo real
pb.collection('pacientes').subscribe('*', function (e) {
    console.log(e.action); // create, update, delete
    console.log(e.record);
});
```

### Auth
```javascript
// Registro
const user = await pb.collection('users').create({
    email: 'paciente@email.com',
    password: '12345678',
    passwordConfirm: '12345678',
    name: 'Juan García',
});

// Login
const auth = await pb.collection('users').authWithPassword(
    'paciente@email.com',
    '12345678'
);
console.log(auth.token);

// OAuth2
await pb.collection('users').authWithOAuth2({ provider: 'google' });
```

### File upload
```javascript
const formData = new FormData();
formData.append('nombre', 'Juan');
formData.append('foto', fileInput.files[0]); // imagen del paciente

const record = await pb.collection('pacientes').create(formData);
// → Thumbnail automático disponible en record.foto
```

## SDKs oficiales

| Lenguaje | Package |
|---|---|
| JavaScript/TS | `pocketbase` (npm) |
| Dart/Flutter | `pocketbase` (pub.dev) |

## Cuándo usar PocketBase vs Supabase

| Criterio | PocketBase | Supabase |
|---|---|---|
| Complejidad setup | Cero (1 binario) | Media (servicios múltiples) |
| Escalabilidad | Baja-media (SQLite) | Alta (PostgreSQL) |
| Realtime | SSE | WebSockets |
| Funciones server | JS/Go hooks | Edge Functions (Deno) |
| RLS | Reglas por colección (UI) | Políticas SQL (código) |
| Coste | Gratis (self-hosted) | Free tier limitado |
| Multi-tenant | No nativo | Sí (schemas) |
| **Ideal para** | MVPs, POCs, apps pequeñas | Producción, apps medianas-grandes |

## Casos de uso para NextHorizont

### Prototipos rápidos
- Backend para demos de clientes de NextHorizont AI en minutos
- POC de nuevas ideas sin tocar la infra Supabase principal

### Proyectos satélite
- Backend para la app de ciclos esotéricos (BaZi/numerología) — no necesita PostgreSQL
- Microservicio independiente para gestionar documentos de Bosques Biodiversos

### Desarrollo local
- Backend de staging para probar frontends antes de conectar Supabase
- Mock server con datos reales para desarrollo offline

### Deploy en VPS
```bash
# En Hostinger VPS (31.97.69.100) via Dokploy
docker run -d \
  --name pocketbase-dev \
  --restart unless-stopped \
  -p 8090:8090 \
  -v /opt/pocketbase/data:/pb/pb_data \
  ghcr.io/pocketbase/pocketbase:latest

# Reverse proxy con nginx
# server_name pb.nexthorizont.ai → localhost:8090
```

## Extensibilidad con hooks JS

```javascript
// pb_hooks/main.pb.js — se ejecuta automáticamente

onRecordCreate((e) => {
    // Enviar notificación cuando se crea un paciente
    const record = e.record;
    $http.send({
        url: "https://n8n.nexthorizont.ai/webhook/nuevo-paciente",
        method: "POST",
        body: JSON.stringify({
            nombre: record.get("nombre"),
            email: record.get("email"),
        }),
    });
    return e.next();
}, "pacientes");
```

## Backup y migración

```bash
# Backup manual
cp pb_data/data.db backup_$(date +%Y%m%d).db

# Backup programático
curl -X POST http://localhost:8090/api/backups \
  -H "Authorization: Bearer ADMIN_TOKEN"

# Migración a PostgreSQL (si crece)
# Exportar datos → importar en Supabase
```
