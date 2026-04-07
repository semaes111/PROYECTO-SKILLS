---
name: realtime-chat-support
description: >
  Chat de soporte en vivo embebible en cualquier web con dashboard de agente, mensajería en tiempo
  real vía WebSockets y integraciones con Slack/email. Basado en Papercups (Elixir/Phoenix + React).
  Usar cuando el usuario mencione: chat en vivo, live chat, soporte al cliente por chat, widget de
  chat, Intercom alternativa, Crisp alternativa, atención al paciente online, chat embebido en web,
  mensajería en tiempo real con agentes, WebSockets chat.
tags:
  - chat
  - live-chat
  - customer-support
  - websockets
  - widget
  - real-time
  - intercom
  - messaging
repo: https://github.com/semaes111/realtime-customer-chat-support
upstream: https://github.com/papercups-io/papercups
license: MIT
stack:
  - Elixir
  - Phoenix
  - PostgreSQL
  - React
  - TypeScript
  - WebSockets
---

# SKILL: Chat de Soporte en Vivo — Widget + Dashboard (Papercups)

## Repo de referencia

- **Local:** https://github.com/semaes111/realtime-customer-chat-support
- **Upstream:** https://github.com/papercups-io/papercups (⭐ 6K+ | MIT)
- **Docs:** https://docs.papercups.io

## Stack técnico

| Capa | Tecnología |
|---|---|
| Backend | Elixir + Phoenix Framework |
| Realtime | Phoenix Channels (WebSockets) |
| Base de datos | PostgreSQL |
| Frontend dashboard | React + TypeScript |
| Widget embebible | React (script tag o npm package) |
| Deploy | Docker / Heroku / Self-hosted |

## Componentes del sistema

```
┌─────────────────────────┐     ┌──────────────────────┐
│   Web del paciente      │     │  Dashboard del agente│
│  (Centro NICA / Violeta)│     │  (panel interno)     │
│                         │     │                      │
│  ┌───────────────────┐  │     │  - Ver conversaciones│
│  │  Chat Widget      │◄─┼─WS─┤  - Responder mensajes│
│  │  (React component)│  │     │  - Asignar agentes   │
│  └───────────────────┘  │     │  - Ver historial     │
└─────────────────────────┘     └──────────────────────┘
            │                            │
            └────────────┬───────────────┘
                         │
              ┌──────────▼──────────┐
              │  Phoenix Backend    │
              │  (Elixir + WS)     │
              │                    │
              │  - Auth            │
              │  - Channels        │
              │  - API REST        │
              │  - Integraciones   │
              └────────┬───────────┘
                       │
              ┌────────▼───────────┐
              │   PostgreSQL       │
              │   (conversaciones, │
              │    usuarios,       │
              │    mensajes)       │
              └────────────────────┘
```

## Instalación del widget en cualquier web

### Opción 1: Script tag (más simple)
```html
<script>
  window.Papercups = {
    config: {
      accountId: "TU_ACCOUNT_ID",
      title: "¡Hola! ¿En qué podemos ayudarte?",
      subtitle: "Responde un agente de Centro NICA",
      primaryColor: "#1890ff",
      greeting: "Bienvenido a Centro NICA. ¿Tienes alguna duda sobre tu tratamiento?",
      newMessagePlaceholder: "Escribe tu mensaje...",
      baseUrl: "https://chat.nexthorizont.ai",
      requireEmailUpfront: true,
    },
  };
</script>
<script
  type="text/javascript"
  async
  defer
  src="https://chat.nexthorizont.ai/widget.js"
></script>
```

### Opción 2: React component
```bash
npm install @papercups-io/chat-widget
```

```tsx
import { ChatWidget } from '@papercups-io/chat-widget';

export default function Layout({ children }) {
  return (
    <>
      {children}
      <ChatWidget
        accountId="TU_ACCOUNT_ID"
        title="Centro NICA - Soporte"
        subtitle="Responderemos lo antes posible"
        primaryColor="#10b981"
        greeting="¡Hola! ¿En qué podemos ayudarte con tu plan nutricional?"
        newMessagePlaceholder="Escribe tu consulta..."
        baseUrl="https://chat.nexthorizont.ai"
        customer={{
          name: user?.name,
          email: user?.email,
          external_id: user?.id,
          metadata: {
            plan: "seguimiento_mensual",
            paciente_id: "PAC-001",
          },
        }}
      />
    </>
  );
}
```

## API REST — Operaciones principales

### Listar conversaciones
```bash
curl https://chat.nexthorizont.ai/api/conversations \
  -H "Authorization: Bearer API_KEY"
```

### Enviar mensaje programáticamente
```bash
curl -X POST https://chat.nexthorizont.ai/api/messages \
  -H "Authorization: Bearer API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "conv_xxx",
    "body": "Tu próxima cita es el lunes a las 10:00",
    "type": "reply"
  }'
```

### Crear/actualizar cliente
```bash
curl -X POST https://chat.nexthorizont.ai/api/customers \
  -H "Authorization: Bearer API_KEY" \
  -d '{
    "name": "María López",
    "email": "maria@email.com",
    "external_id": "PAC-042",
    "metadata": {"peso_actual": 82, "objetivo": "70kg"}
  }'
```

## Integraciones nativas

| Servicio | Tipo | Descripción |
|---|---|---|
| Slack | Bidireccional | Recibir y responder chats desde Slack |
| Mattermost | Bidireccional | Alternativa self-hosted a Slack |
| Email | Saliente | Notificar por email cuando hay mensaje nuevo |
| Webhooks | Saliente | Enviar eventos a n8n/Zapier |
| API REST | Completa | CRUD de conversaciones, mensajes, clientes |

### Integración con n8n (webhook)
```
Papercups Webhook → n8n.nexthorizont.ai/webhook/nuevo-chat
  → Clasificar urgencia del mensaje
  → Si urgente: notificar Telegram @sergio
  → Si consulta dieta: respuesta automática con enlace
  → Registrar en Supabase tabla `interacciones_paciente`
```

## Deploy self-hosted con Docker

```yaml
# docker-compose.yml
version: '3'
services:
  papercups:
    image: papercups/papercups:latest
    ports:
      - "4000:4000"
    environment:
      DATABASE_URL: "postgresql://postgres:password@db:5432/papercups"
      SECRET_KEY_BASE: "GENERAR_CON_mix_phx.gen.secret"
      BACKEND_URL: "https://chat.nexthorizont.ai"
      MIX_ENV: "prod"
      REQUIRE_DB_SSL: "false"
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: papercups
      POSTGRES_PASSWORD: password
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

```bash
# Deploy en VPS Hostinger
docker compose up -d
# Configurar nginx/Traefik: chat.nexthorizont.ai → localhost:4000
```

## Casos de uso para NextHorizont

### Centro NICA
- Chat en vivo en centronicaejido.com para consultas de nuevos pacientes
- Widget personalizado con campos de paciente (peso, objetivo)
- Respuestas rápidas predefinidas para preguntas frecuentes sobre dietas
- Historial de conversaciones vinculado al expediente del paciente

### Clínica Violeta
- Widget en web-violeta.vercel.app para consultas sobre tratamientos estéticos
- Horario de atención visible en el widget
- Derivar automáticamente a WhatsApp fuera de horario

### NextHorizont AI
- Chat de soporte técnico para clientes de productos de IA
- Integrado con Telegram bot para que Sergio responda desde cualquier sitio

## Alternativa: Widget frontend + Supabase Realtime

Si no quieres desplegar Elixir, puedes extraer solo el concepto del widget y construir el backend con tu stack:

```typescript
// Supabase Realtime como backend de chat
const channel = supabase.channel('chat:paciente_123');

channel.on('broadcast', { event: 'message' }, (payload) => {
  // Nuevo mensaje del agente
  addMessage(payload.message);
});

// Enviar mensaje del paciente
channel.send({
  type: 'broadcast',
  event: 'message',
  payload: { body: 'Tengo dudas sobre mi dieta', from: 'paciente' },
});
```

Esta alternativa es más simple pero pierde: dashboard de agente, asignación, historial organizado, integraciones Slack.
