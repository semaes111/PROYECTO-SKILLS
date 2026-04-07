---
name: n8n-workflows
description: "Crear flujos de automatización n8n para integrar con aplicaciones desarrolladas con Claude Code y Antigravity. Usar cuando se necesite: webhooks, automatizaciones, sincronización de datos, notificaciones, integración con APIs REST, conexión Supabase, triggers de base de datos, pipelines de datos, o cualquier flujo de trabajo automatizado para apps Next.js/Supabase."
---

# n8n Workflows para Apps Claude/Antigravity

## Arquitectura de Integración

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TU APP (Next.js + Supabase)                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │ Route Handler│    │ Edge Function│    │   Supabase   │          │
│  │  /api/...    │    │  webhook     │    │   Realtime   │          │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘          │
│         │                   │                   │                   │
└─────────┼───────────────────┼───────────────────┼───────────────────┘
          │                   │                   │
          ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            n8n                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │   Webhook    │    │   HTTP       │    │   Supabase   │          │
│  │   Trigger    │    │   Request    │    │   Trigger    │          │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘          │
│         │                   │                   │                   │
│         ▼                   ▼                   ▼                   │
│  ┌─────────────────────────────────────────────────────┐           │
│  │              WORKFLOW (Nodos de procesamiento)       │           │
│  │  Transform → Filter → Aggregate → Action            │           │
│  └──────────────────────────┬──────────────────────────┘           │
│                             │                                       │
│         ┌───────────────────┼───────────────────┐                  │
│         ▼                   ▼                   ▼                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │    Email     │    │    Slack     │    │   Database   │          │
│  │  (Resend)    │    │ Notification │    │    Update    │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Conceptos Fundamentales de n8n

### Estructura de un Workflow

```json
{
  "name": "Mi Workflow",
  "nodes": [
    {
      "id": "trigger-node-id",
      "name": "Webhook Trigger",
      "type": "n8n-nodes-base.webhook",
      "position": [250, 300],
      "parameters": { },
      "typeVersion": 1
    },
    {
      "id": "action-node-id", 
      "name": "HTTP Request",
      "type": "n8n-nodes-base.httpRequest",
      "position": [500, 300],
      "parameters": { },
      "typeVersion": 1
    }
  ],
  "connections": {
    "Webhook Trigger": {
      "main": [
        [{ "node": "HTTP Request", "type": "main", "index": 0 }]
      ]
    }
  }
}
```

### Tipos de Nodos

| Categoría | Nodos Comunes | Uso |
|-----------|---------------|-----|
| **Triggers** | Webhook, Schedule, Supabase Trigger | Iniciar workflow |
| **Data** | HTTP Request, Supabase, PostgreSQL | Obtener/enviar datos |
| **Transform** | Set, Code, Function, Split In Batches | Procesar datos |
| **Logic** | IF, Switch, Merge, Filter | Control de flujo |
| **Actions** | Email, Slack, Discord, Telegram | Notificaciones |
| **Utils** | Wait, Date & Time, Crypto | Utilidades |

---

## Patrones de Integración con Apps Next.js/Supabase

### Patrón 1: Webhook desde tu App

Tu app envía eventos a n8n via webhook.

**En tu App (Route Handler):**

```typescript
// app/api/webhooks/n8n/route.ts
import { NextResponse } from 'next/server'

const N8N_WEBHOOK_URL = process.env.N8N_WEBHOOK_URL!

export async function POST(request: Request) {
  const body = await request.json()
  
  // Enviar a n8n
  const response = await fetch(N8N_WEBHOOK_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Webhook-Secret': process.env.N8N_WEBHOOK_SECRET!,
    },
    body: JSON.stringify({
      event: 'order.created',
      timestamp: new Date().toISOString(),
      data: body,
    }),
  })
  
  if (!response.ok) {
    console.error('n8n webhook failed:', await response.text())
  }
  
  return NextResponse.json({ received: true })
}
```

**Workflow n8n:**

```json
{
  "name": "App Webhook Handler",
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "httpMethod": "POST",
        "path": "app-events",
        "authentication": "headerAuth",
        "options": {}
      },
      "position": [250, 300]
    },
    {
      "name": "Validate Secret",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "string": [{
            "value1": "={{ $json.headers['x-webhook-secret'] }}",
            "value2": "={{$env.WEBHOOK_SECRET}}",
            "operation": "equals"
          }]
        }
      },
      "position": [450, 300]
    },
    {
      "name": "Route by Event",
      "type": "n8n-nodes-base.switch",
      "parameters": {
        "dataType": "string",
        "value1": "={{ $json.body.event }}",
        "rules": {
          "rules": [
            { "value2": "order.created", "output": 0 },
            { "value2": "user.registered", "output": 1 },
            { "value2": "payment.completed", "output": 2 }
          ]
        }
      },
      "position": [650, 300]
    }
  ]
}
```

### Patrón 2: n8n llama a tu API

n8n obtiene datos de tu app periódicamente o bajo demanda.

**Workflow n8n:**

```json
{
  "name": "Fetch App Data",
  "nodes": [
    {
      "name": "Schedule",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": {
          "interval": [{ "field": "hours", "hoursInterval": 1 }]
        }
      },
      "position": [250, 300]
    },
    {
      "name": "Get Projects",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "GET",
        "url": "https://tu-app.vercel.app/api/projects",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            { "name": "Authorization", "value": "Bearer {{$env.API_KEY}}" }
          ]
        },
        "options": {
          "response": { "response": { "responseFormat": "json" } }
        }
      },
      "position": [450, 300]
    },
    {
      "name": "Filter Active",
      "type": "n8n-nodes-base.filter",
      "parameters": {
        "conditions": {
          "string": [{
            "value1": "={{ $json.status }}",
            "value2": "active",
            "operation": "equals"
          }]
        }
      },
      "position": [650, 300]
    }
  ]
}
```

### Patrón 3: Supabase Database Trigger

n8n reacciona a cambios en tu base de datos Supabase.

**Configurar en Supabase (Database Webhook):**

```sql
-- Crear función para notificar a n8n
CREATE OR REPLACE FUNCTION notify_n8n()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  payload JSONB;
BEGIN
  payload := jsonb_build_object(
    'table', TG_TABLE_NAME,
    'operation', TG_OP,
    'old', CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    'new', CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
    'timestamp', NOW()
  );
  
  -- Usar pg_net para HTTP async (extensión de Supabase)
  PERFORM net.http_post(
    url := 'https://tu-n8n.com/webhook/supabase-changes',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'X-Supabase-Secret', current_setting('app.n8n_secret')
    ),
    body := payload
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Aplicar a tabla
CREATE TRIGGER on_order_change
  AFTER INSERT OR UPDATE OR DELETE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION notify_n8n();
```

**Workflow n8n:**

```json
{
  "name": "Supabase Changes Handler",
  "nodes": [
    {
      "name": "Supabase Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "httpMethod": "POST",
        "path": "supabase-changes",
        "options": {}
      },
      "position": [250, 300]
    },
    {
      "name": "Route by Table",
      "type": "n8n-nodes-base.switch",
      "parameters": {
        "dataType": "string",
        "value1": "={{ $json.body.table }}",
        "rules": {
          "rules": [
            { "value2": "orders", "output": 0 },
            { "value2": "users", "output": 1 },
            { "value2": "products", "output": 2 }
          ]
        }
      },
      "position": [450, 300]
    },
    {
      "name": "Process Order",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "const { operation, new: newData, old: oldData } = $input.item.json.body;\n\nif (operation === 'INSERT') {\n  return { action: 'new_order', order: newData };\n} else if (operation === 'UPDATE') {\n  return { action: 'order_updated', order: newData, previous: oldData };\n}\n\nreturn { action: 'unknown' };"
      },
      "position": [650, 200]
    }
  ]
}
```

### Patrón 4: Edge Function como Middleware

Edge Function de Supabase procesa y envía a n8n.

**Edge Function:**

```typescript
// supabase/functions/n8n-bridge/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const N8N_WEBHOOK = Deno.env.get('N8N_WEBHOOK_URL')!
const WEBHOOK_SECRET = Deno.env.get('N8N_WEBHOOK_SECRET')!

serve(async (req) => {
  try {
    const body = await req.json()
    
    // Enriquecer datos antes de enviar
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // Obtener datos relacionados
    const { data: user } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', body.user_id)
      .single()
    
    // Enviar a n8n con datos enriquecidos
    const response = await fetch(N8N_WEBHOOK, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Webhook-Secret': WEBHOOK_SECRET,
      },
      body: JSON.stringify({
        ...body,
        user,
        processed_at: new Date().toISOString(),
      }),
    })
    
    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    )
  }
})
```

---

## Nodos Esenciales para Apps

### HTTP Request (Llamar a tu API)

```json
{
  "name": "Call App API",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://tu-app.vercel.app/api/resource",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        { "name": "Authorization", "value": "Bearer {{ $env.APP_API_KEY }}" },
        { "name": "Content-Type", "value": "application/json" }
      ]
    },
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        { "name": "id", "value": "={{ $json.id }}" },
        { "name": "status", "value": "processed" }
      ]
    },
    "options": {
      "response": { "response": { "responseFormat": "json" } },
      "timeout": 30000
    }
  }
}
```

### Supabase Node (Operaciones directas)

```json
{
  "name": "Supabase Insert",
  "type": "n8n-nodes-base.supabase",
  "parameters": {
    "operation": "insert",
    "tableId": "audit_logs",
    "fieldsUi": {
      "fieldValues": [
        { "fieldName": "action", "fieldValue": "={{ $json.action }}" },
        { "fieldName": "user_id", "fieldValue": "={{ $json.user_id }}" },
        { "fieldName": "metadata", "fieldValue": "={{ JSON.stringify($json) }}" }
      ]
    }
  },
  "credentials": {
    "supabaseApi": { "id": "xxx", "name": "Supabase Account" }
  }
}
```

### Code Node (Transformaciones complejas)

```json
{
  "name": "Transform Data",
  "type": "n8n-nodes-base.code",
  "parameters": {
    "mode": "runOnceForAllItems",
    "jsCode": "// Acceso a todos los items\nconst items = $input.all();\n\n// Agrupar por categoría\nconst grouped = items.reduce((acc, item) => {\n  const category = item.json.category || 'other';\n  if (!acc[category]) acc[category] = [];\n  acc[category].push(item.json);\n  return acc;\n}, {});\n\n// Calcular totales\nconst summary = Object.entries(grouped).map(([category, items]) => ({\n  category,\n  count: items.length,\n  total: items.reduce((sum, i) => sum + (i.amount || 0), 0)\n}));\n\nreturn summary.map(s => ({ json: s }));"
  }
}
```

### Conditional Logic (IF Node)

```json
{
  "name": "Check Status",
  "type": "n8n-nodes-base.if",
  "parameters": {
    "conditions": {
      "options": { "caseSensitive": true, "leftValue": "" },
      "combinator": "and",
      "conditions": [
        {
          "leftValue": "={{ $json.status }}",
          "rightValue": "completed",
          "operator": { "type": "string", "operation": "equals" }
        },
        {
          "leftValue": "={{ $json.amount }}",
          "rightValue": 100,
          "operator": { "type": "number", "operation": "gt" }
        }
      ]
    }
  }
}
```

---

## Notificaciones

### Email con Resend

```json
{
  "name": "Send Email",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://api.resend.com/emails",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "headerParameters": {
      "parameters": [
        { "name": "Authorization", "value": "Bearer {{ $env.RESEND_API_KEY }}" }
      ]
    },
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={\n  \"from\": \"app@tudominio.com\",\n  \"to\": \"{{ $json.email }}\",\n  \"subject\": \"{{ $json.subject }}\",\n  \"html\": \"<h1>{{ $json.title }}</h1><p>{{ $json.message }}</p>\"\n}"
  }
}
```

### Slack Notification

```json
{
  "name": "Slack Alert",
  "type": "n8n-nodes-base.slack",
  "parameters": {
    "operation": "post",
    "channel": "#alerts",
    "text": "🚨 *{{ $json.event }}*\n\nDetalles:\n• Usuario: {{ $json.user_email }}\n• Acción: {{ $json.action }}\n• Timestamp: {{ $json.timestamp }}",
    "otherOptions": {
      "includeLinkToWorkflow": true
    }
  },
  "credentials": {
    "slackApi": { "id": "xxx", "name": "Slack Bot" }
  }
}
```

### Discord Webhook

```json
{
  "name": "Discord Notification",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "={{ $env.DISCORD_WEBHOOK_URL }}",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={\n  \"embeds\": [{\n    \"title\": \"{{ $json.title }}\",\n    \"description\": \"{{ $json.description }}\",\n    \"color\": 5814783,\n    \"fields\": [\n      { \"name\": \"Status\", \"value\": \"{{ $json.status }}\", \"inline\": true },\n      { \"name\": \"ID\", \"value\": \"{{ $json.id }}\", \"inline\": true }\n    ],\n    \"timestamp\": \"{{ $now.toISO() }}\"\n  }]\n}"
  }
}
```

---

## Seguridad

### Validar Webhooks

```json
{
  "name": "Validate Webhook",
  "type": "n8n-nodes-base.code",
  "parameters": {
    "jsCode": "const crypto = require('crypto');\n\nconst secret = $env.WEBHOOK_SECRET;\nconst signature = $input.item.json.headers['x-signature'];\nconst payload = JSON.stringify($input.item.json.body);\n\nconst expectedSignature = crypto\n  .createHmac('sha256', secret)\n  .update(payload)\n  .digest('hex');\n\nif (signature !== `sha256=${expectedSignature}`) {\n  throw new Error('Invalid webhook signature');\n}\n\nreturn $input.item;"
  }
}
```

### Rate Limiting en Workflow

```json
{
  "name": "Rate Limit Check",
  "type": "n8n-nodes-base.code",
  "parameters": {
    "jsCode": "// Usar variable de workflow para tracking\nconst key = $input.item.json.user_id;\nconst now = Date.now();\nconst windowMs = 60000; // 1 minuto\nconst maxRequests = 10;\n\n// Obtener estado actual (en producción usar Redis)\nconst state = $getWorkflowStaticData('global');\nif (!state.rateLimits) state.rateLimits = {};\n\nconst userLimits = state.rateLimits[key] || { count: 0, windowStart: now };\n\n// Reset si pasó la ventana\nif (now - userLimits.windowStart > windowMs) {\n  userLimits.count = 0;\n  userLimits.windowStart = now;\n}\n\nuserLimits.count++;\nstate.rateLimits[key] = userLimits;\n\nif (userLimits.count > maxRequests) {\n  throw new Error('Rate limit exceeded');\n}\n\nreturn $input.item;"
  }
}
```

---

## Variables de Entorno

Configurar en n8n Settings → Variables:

```
APP_API_URL=https://tu-app.vercel.app/api
APP_API_KEY=sk_live_xxx
WEBHOOK_SECRET=whsec_xxx
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
RESEND_API_KEY=re_xxx
SLACK_WEBHOOK=https://hooks.slack.com/xxx
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/xxx
```

---

## Debugging

### Log Node para Debug

```json
{
  "name": "Debug Log",
  "type": "n8n-nodes-base.code",
  "parameters": {
    "jsCode": "console.log('=== DEBUG ===');\nconsole.log('Input:', JSON.stringify($input.item.json, null, 2));\nconsole.log('Env:', $env.APP_API_URL);\nconsole.log('=============');\n\nreturn $input.item;"
  }
}
```

### Error Handling

```json
{
  "name": "Error Handler",
  "type": "n8n-nodes-base.errorTrigger",
  "parameters": {},
  "position": [250, 500]
}
```

Conectar a notificación de error:

```json
{
  "name": "Alert on Error",
  "type": "n8n-nodes-base.slack",
  "parameters": {
    "operation": "post",
    "channel": "#errors",
    "text": "❌ *Workflow Error*\n\nWorkflow: {{ $workflow.name }}\nNode: {{ $json.node.name }}\nError: {{ $json.error.message }}\n\n```{{ $json.error.stack }}```"
  }
}
```

---

## Checklist de Integración

- [ ] Variables de entorno configuradas en n8n
- [ ] Webhook secrets compartidos entre app y n8n
- [ ] HTTPS en todos los endpoints
- [ ] Validación de firma en webhooks
- [ ] Error handling con notificaciones
- [ ] Logs habilitados para debugging
- [ ] Rate limiting implementado
- [ ] Timeouts configurados en HTTP requests
- [ ] Retry logic para operaciones críticas
