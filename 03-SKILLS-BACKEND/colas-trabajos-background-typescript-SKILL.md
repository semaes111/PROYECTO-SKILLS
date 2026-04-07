---
name: background-jobs-queues
description: >
  Background jobs de larga duración en TypeScript puro con retries automáticos, colas con
  concurrencia controlada, cron scheduling, observabilidad completa y elastic scaling. Basado
  en Trigger.dev (TypeScript + Prisma + PostgreSQL). Usar cuando el usuario mencione: background
  jobs, tareas en segundo plano, colas de trabajo, workers, job queue, BullMQ, procesamiento
  asíncrono, tareas largas, cron jobs robustos, retries automáticos, workflows de IA en background,
  pipelines de datos, procesamiento por lotes, elastic scaling.
tags:
  - background-jobs
  - queues
  - workers
  - cron
  - typescript
  - batch-processing
  - ai-workflows
  - pipelines
  - scheduling
  - observability
repo: https://github.com/semaes111/background-jobs-typescript-queues
upstream: https://github.com/triggerdotdev/trigger.dev
license: Apache-2.0
stack:
  - TypeScript
  - Next.js
  - Prisma
  - PostgreSQL
  - Docker
---

# SKILL: Background Jobs y Colas en TypeScript (Trigger.dev)

## Repo de referencia

- **Local:** https://github.com/semaes111/background-jobs-typescript-queues
- **Upstream:** https://github.com/triggerdotdev/trigger.dev (⭐ 14K+ | Apache 2.0)
- **Docs:** https://trigger.dev/docs
- **Web:** https://trigger.dev

## Stack técnico

| Capa | Tecnología |
|---|---|
| Lenguaje | TypeScript (100%) |
| Framework | Next.js compatible (App Router + Pages) |
| ORM/DB | Prisma + PostgreSQL |
| Queue | PostgreSQL-based (no necesita Redis externo) |
| Runtime | Node.js workers aislados |
| Observabilidad | Dashboard web con logs, traces, estado de runs |
| Deploy | Cloud (managed) o Self-hosted (Docker) |

## Concepto clave: Task + Trigger

```typescript
// trigger/send-diet-plan.ts
import { task } from "@trigger.dev/sdk/v3";

export const sendDietPlan = task({
  id: "send-diet-plan",
  // Sin timeout (puede correr horas si es necesario)
  run: async (payload: { pacienteId: string; semana: number }) => {
    // 1. Obtener datos del paciente de Supabase
    const paciente = await supabase
      .from("pacientes")
      .select("*")
      .eq("id", payload.pacienteId)
      .single();

    // 2. Generar plan con IA (puede tardar 30-60s)
    const plan = await generateDietPlan(paciente.data, payload.semana);

    // 3. Generar PDF
    const pdf = await generatePDF(plan);

    // 4. Enviar por WhatsApp
    await sendWhatsApp(paciente.data.telefono, pdf);

    // 5. Registrar en DB
    await supabase.from("planes_enviados").insert({
      paciente_id: payload.pacienteId,
      semana: payload.semana,
      enviado_at: new Date(),
    });

    return { success: true, pacienteId: payload.pacienteId };
  },
});
```

## Invocar tasks

### Desde un Route Handler (Next.js)
```typescript
// app/api/enviar-dieta/route.ts
import { tasks } from "@trigger.dev/sdk/v3";
import type { sendDietPlan } from "@/trigger/send-diet-plan";

export async function POST(req: Request) {
  const { pacienteId, semana } = await req.json();

  // Dispara el job y retorna inmediatamente
  const handle = await tasks.trigger<typeof sendDietPlan>("send-diet-plan", {
    pacienteId,
    semana,
  });

  return Response.json({ jobId: handle.id, status: "queued" });
}
```

### Desde cualquier parte del código
```typescript
import { tasks } from "@trigger.dev/sdk/v3";

// Trigger individual
await tasks.trigger("send-diet-plan", { pacienteId: "PAC-001", semana: 4 });

// Trigger en lote (batch) — procesar 480 pacientes
await tasks.batchTrigger("send-diet-plan",
  pacientes.map(p => ({
    payload: { pacienteId: p.id, semana: currentWeek },
  }))
);
```

## Funcionalidades avanzadas

### Retries automáticos con backoff
```typescript
export const procesarPago = task({
  id: "procesar-pago",
  retry: {
    maxAttempts: 5,
    factor: 2,           // exponential backoff
    minTimeoutInMs: 1000, // 1s, 2s, 4s, 8s, 16s
    maxTimeoutInMs: 30000,
  },
  run: async (payload: { stripeSessionId: string }) => {
    // Si falla, reintenta automáticamente
    const session = await stripe.checkout.sessions.retrieve(payload.stripeSessionId);
    await activarSuscripcion(session);
  },
});
```

### Cron jobs (scheduled tasks)
```typescript
import { schedules } from "@trigger.dev/sdk/v3";

// Ejecutar todos los lunes a las 8:00 AM
export const reporteSemanal = schedules.task({
  id: "reporte-semanal-pacientes",
  cron: "0 8 * * 1", // Lunes 8:00
  run: async () => {
    const stats = await calcularEstadisticasSemanales();
    await enviarReporteTelegram(stats);
    await enviarEmailResumen(stats);
  },
});
```

### Subtasks y composición
```typescript
export const onboardingPaciente = task({
  id: "onboarding-paciente",
  run: async (payload: { pacienteId: string }) => {
    // Ejecutar subtasks en secuencia
    const perfil = await crearPerfilTask.triggerAndWait({
      pacienteId: payload.pacienteId,
    });

    const dieta = await generarDietaInicialTask.triggerAndWait({
      pacienteId: payload.pacienteId,
      perfil: perfil.output,
    });

    await enviarBienvenidaWhatsAppTask.trigger({
      pacienteId: payload.pacienteId,
      dietaUrl: dieta.output.url,
    });

    return { onboarded: true };
  },
});
```

### Concurrencia controlada
```typescript
export const llamadaLLM = task({
  id: "llamada-llm",
  queue: {
    concurrencyLimit: 5, // Máximo 5 llamadas simultáneas a la API de Claude
  },
  run: async (payload: { prompt: string }) => {
    const response = await anthropic.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4096,
      messages: [{ role: "user", content: payload.prompt }],
    });
    return response.content[0].text;
  },
});
```

### Esperar eventos externos (wait)
```typescript
export const esperarPagoStripe = task({
  id: "esperar-pago-stripe",
  run: async (payload: { checkoutSessionId: string }) => {
    // Crear sesión de Stripe...

    // Esperar hasta que Stripe confirme el pago (webhook)
    const result = await wait.forEvent("stripe.checkout.completed", {
      filter: { checkoutSessionId: payload.checkoutSessionId },
      timeout: "24h", // Timeout de 24 horas
    });

    // Continuar después del pago
    await activarSuscripcion(result.data);
  },
});
```

## Setup en proyecto Next.js existente

### 1. Instalar
```bash
npx trigger.dev@latest init
# Seleccionar: Next.js App Router
# Se crea: trigger/ directorio + trigger.config.ts
```

### 2. Configurar
```typescript
// trigger.config.ts
import { defineConfig } from "@trigger.dev/sdk/v3";

export default defineConfig({
  project: "proj_nexthorizont",
  runtime: "node",
  logLevel: "log",
  retries: {
    enabledInDev: true,
    default: {
      maxAttempts: 3,
      factor: 2,
      minTimeoutInMs: 1000,
    },
  },
  dirs: ["./trigger"],
});
```

### 3. Variables de entorno
```env
TRIGGER_SECRET_KEY=tr_dev_xxxxx    # Dev
TRIGGER_SECRET_KEY=tr_prod_xxxxx   # Prod
```

### 4. Dev server
```bash
npx trigger.dev@latest dev
# → Dashboard: http://localhost:3040
# → Workers escuchando jobs
```

## Self-hosting con Docker

```yaml
# docker-compose.trigger.yml
version: '3.8'
services:
  trigger:
    image: ghcr.io/triggerdotdev/trigger.dev:latest
    ports:
      - "3030:3000"
    environment:
      DATABASE_URL: "postgresql://postgres:password@db:5432/trigger"
      DIRECT_URL: "postgresql://postgres:password@db:5432/trigger"
      SESSION_SECRET: "GENERAR_SECRET"
      ENCRYPTION_KEY: "GENERAR_KEY_32_CHARS"
      MAGIC_LINK_SECRET: "GENERAR_SECRET"
      LOGIN_ORIGIN: "https://jobs.nexthorizont.ai"
      APP_ORIGIN: "https://jobs.nexthorizont.ai"
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: trigger
      POSTGRES_PASSWORD: password
    volumes:
      - trigger_data:/var/lib/postgresql/data

volumes:
  trigger_data:
```

## Comparativa: Trigger.dev vs alternativas

| Feature | Trigger.dev | BullMQ | QStash | pg_cron | n8n |
|---|---|---|---|---|---|
| Lenguaje | TypeScript | TypeScript | HTTP | SQL | No-code |
| Sin timeout | ✅ | ✅ | ❌ (15min) | ❌ | Depende |
| Retries | ✅ auto | ✅ manual | ✅ auto | ❌ | ✅ |
| Dashboard UI | ✅ completo | ❌ (Bull Board) | ✅ básico | ❌ | ✅ |
| Cron scheduling | ✅ | ✅ | ✅ | ✅ | ✅ |
| Observabilidad | ✅ traces | ❌ | ❌ | ❌ | ✅ logs |
| Requiere Redis | ❌ (PostgreSQL) | ✅ | ❌ | ❌ | ❌ |
| AI workflows | ✅ optimizado | Genérico | Genérico | ❌ | ✅ |
| **Ideal para** | Jobs complejos TS | Jobs simples | Serverless | Cron básico | Integraciones no-code |

## Casos de uso para NextHorizont

### Centro NICA — Pipeline de pacientes
```
Nuevo paciente (webhook)
  → [Job] Crear perfil + calcular IMC
  → [Job] Generar dieta personalizada con IA
  → [Job] Crear PDF del plan
  → [Job] Enviar por WhatsApp
  → [Job] Programar seguimiento semanal (cron)
```

### Procesamiento masivo mensual
```
[Cron: día 1 de cada mes]
  → [Batch] 480 pacientes × generar informe mensual
  → Concurrencia: 10 simultáneos (no saturar API de IA)
  → Retries: 3 intentos por paciente
  → Al terminar: enviar resumen a Telegram @sergio
```

### Bosques Biodiversos — Generación de informes
```
[Trigger: nuevo dato satelital]
  → [Job] Descargar imágenes Sentinel-2
  → [Job] Calcular NDVI con Python (subprocess)
  → [Job] Generar informe PDF
  → [Job] Enviar a inversores por email
```

### Sincronización de datos
```
[Cron: cada 6 horas]
  → [Job] Sync Supabase ↔ Evolution API (contactos WhatsApp)
  → [Job] Sync Stripe ↔ Supabase (suscripciones activas)
  → [Job] Cleanup de archivos temporales en Storage
```

## Complementariedad con n8n

| n8n | Trigger.dev |
|---|---|
| Integraciones no-code rápidas | Lógica compleja en TypeScript |
| Webhooks simples | Jobs de larga duración |
| Conectar APIs sin código | Procesamiento de datos pesado |
| Ideal para Sergio (visual) | Ideal para developers |
| **Usar para:** Alma report, notificaciones | **Usar para:** batch processing, AI pipelines, PDFs |
