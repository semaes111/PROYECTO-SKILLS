---
name: persistent-memory-7layer
description: >
  Sistema de memoria persistente de 7 capas (MEMU) para agentes de IA.
  Implementa L1 working memory (Redis 1h), L2 short-term (Redis 24h),
  L3 episodic (Supabase), L4 semantic (pgvector embeddings), L5 procedural
  (protocolos/SOPs), L6 long-term facts (Supabase), L7 meta-memory (calibracion).
  Incluye consolidacion nocturna automatica L2->L3->L6, busqueda semantica
  por similitud coseno, inyeccion de calendario, y watcher transversal.
  Basado en NEMOCLAW-AGENT (TypeScript + Express + Supabase + Redis + Qdrant).
  Usar cuando el usuario mencione: memoria persistente, agente con memoria,
  recordar entre sesiones, sistema de memoria, 7 capas, MEMU, consolidacion
  de memoria, busqueda semantica de conversaciones, contexto persistente,
  knowledge base para agente, RAG para agente, embeddings de conversaciones.
metadata:
  version: "1.0.0"
  source_repo: "https://github.com/semaes111/NEMOCLAW-AGENT"
  category: agent-infrastructure
triggers:
  - "memoria persistente"
  - "agente con memoria"
  - "sistema de memoria"
  - "7 capas"
  - "MEMU"
  - "recordar entre sesiones"
---

# MEMU: Sistema de Memoria Persistente de 7 Capas

## Arquitectura General

MEMU (Memory Management Unit) es un orquestador de memoria para agentes de IA que implementa 7 capas con diferentes backends, TTLs y propositos. El principio de diseno es que **la memoria del agente debe funcionar como la memoria humana**: working memory volatil para la tarea actual, memoria episodica para conversaciones pasadas, memoria semantica para busqueda por significado, y memoria a largo plazo para hechos consolidados.

```
                    ┌─────────────────────────────────────────┐
                    │            MEMU API (:5000)              │
                    │         Express + TypeScript              │
                    └─────────┬───────────────┬───────────────┘
                              │               │
                    ┌─────────▼─────┐  ┌──────▼──────────────┐
                    │  Redis (:6379) │  │  Supabase (pgvector) │
                    │  L1 + L2       │  │  L3 + L4 + L5 + L6  │
                    │  (volatil)     │  │  + L7 (persistente)  │
                    └───────────────┘  └──────────────────────┘
```

## Las 7 Capas

| Capa | Nombre | Backend | TTL | Proposito |
|------|--------|---------|-----|-----------|
| L1 | Working Memory | Redis | 1h | Contexto de sesion activa (tarea actual, archivos abiertos) |
| L2 | Short-Term | Redis | 24h | Interacciones recientes del dia (max 200 entradas) |
| L3 | Episodic | Supabase | Permanente | Historial completo de conversaciones por sesion |
| L4 | Semantic | Supabase pgvector | Permanente | Embeddings para busqueda por similitud coseno |
| L5 | Procedural | Supabase | Permanente | Protocolos/SOPs con triggers y pasos ejecutables |
| L6 | Long-Term Facts | Supabase | Configurable | Hechos clave extraidos: preferencias, entidades, conocimiento |
| L7 | Meta-Memory | Supabase | Permanente | Configuracion y metricas del sistema de memoria |

## Flujo de Datos Tipico

```
Usuario envia mensaje
    │
    ▼
POST /api/context (buildAgentContext)
    ├── L1: leer working memory de la sesion
    ├── L2: ultimas 10 interacciones del agente
    ├── L3: historial de la sesion actual (20 msgs)
    ├── L4: busqueda semantica con la query actual (top 5)
    ├── L5: protocolos activos por trigger
    ├── L6: todos los hechos del agente
    └── L7: configuracion meta
    │
    ▼
Agente procesa con contexto completo
    │
    ▼
POST /api/episodes (guardar respuesta)
    ├── L3: guardar episodio en Supabase
    ├── L2: push a Redis para acceso rapido
    └── L4: si content > 100 chars, indexar embedding
```

## Consolidacion Nocturna (n8n workflow, 02:00)

```
POST /api/consolidate
    │
    ├── 1. Flush L2 → L3 (Redis → Supabase)
    │      Solo items con content.length > 50
    │
    ├── 2. Resumir L3 → L6 (episodios → hechos)
    │      Importancia minima: 0.6
    │
    ├── 3. Indexar nuevos hechos en L4 (embeddings)
    │
    ├── 4. Actualizar stats en L7
    │
    └── 5. Podar episodios L3 > 30 dias
```

## Stack Tecnico

| Componente | Tecnologia | Puerto |
|-----------|-----------|--------|
| MEMU API | Express + TypeScript | 5000 |
| Redis | Redis 7 Alpine | 6379 |
| Supabase | PostgreSQL 15 + pgvector | Variable |
| Qdrant | Vector DB (opcional) | 6333 |
| Embeddings | NVIDIA llama-3.2-nv-embedqa-1b-v2 (1024 dims) | API externa |
| Watcher | Node.js monitor transversal | 4000 |
| n8n | Workflow engine (consolidacion, briefing, alertas) | 5678 |

## Implementacion Paso a Paso

### Paso 1: Schema de Base de Datos

Ejecutar la migracion completa. Ver `references/memu-schema.sql` para el SQL completo.

Tablas creadas:
- `memu_episodes` — L3: historial con session_id, agent_id, role, content, tokens
- `memu_semantic` — L4: embeddings VECTOR(1024) con indice HNSW (m=16, ef=64)
- `memu_protocols` — L5: SOPs con trigger_event, trigger_cron, steps JSONB
- `memu_facts` — L6: key/value con category, confidence, expires_at
- `memu_meta` — L7: config y stats del sistema como JSONB
- `agent_calendar_events` — agenda con protocolo asociado
- `agent_tasks` — cola de tareas con prioridad y estado
- `watcher_events` — logs del monitor con severidad

Funciones SQL:
- `memu_search_semantic()` — busqueda coseno con threshold y filtro por agent_id
- `notify_n8n_on_episode()` — trigger que notifica a n8n via pg_net cuando content > 200 chars

### Paso 2: API de Memoria (MEMU)

Ver `references/memu-api.ts` para el codigo completo del servidor Express.

Endpoints principales:

| Metodo | Endpoint | Descripcion |
|--------|----------|-------------|
| POST | /api/context | **El mas importante.** Construye contexto completo de 7 capas para una query |
| POST | /api/episodes | Guardar episodio (L3) + push L2 + index L4 si > 100 chars |
| POST | /api/facts | Guardar hecho (L6) + indexar en L4 |
| GET | /api/facts | Listar hechos por agent_id y category opcional |
| POST | /api/search | Busqueda semantica en L4 |
| POST | /api/working-memory | Set key/value en L1 (Redis, TTL 1h) |
| GET | /api/protocols/:slug | Obtener protocolo L5 por slug |
| POST | /api/consolidate | Consolidacion L2→L3, stats L7 |
| POST | /api/calendar/inject | Inyectar eventos de calendario en L1 |
| GET | /health | Health check de Redis + Supabase + Qdrant |

### Paso 3: Docker Compose

```yaml
services:
  memu-api:
    build: ./memu
    ports: ["5000:5000"]
    environment:
      SUPABASE_URL: ${SUPABASE_URL}
      SUPABASE_SERVICE_KEY: ${SUPABASE_SERVICE_KEY}
      REDIS_URL: redis://redis:6379
      REDIS_PASSWORD: ${REDIS_PASSWORD}
      NVIDIA_API_KEY: ${NVIDIA_API_KEY}
      MEMU_API_KEY: ${MEMU_API_KEY}
    depends_on: [redis]

  redis:
    image: redis:7-alpine
    command: >
      redis-server
        --appendonly yes
        --maxmemory 512mb
        --maxmemory-policy allkeys-lru
        --requirepass ${REDIS_PASSWORD}
    ports: ["6379:6379"]
    volumes: ["redis_data:/data"]
```

### Paso 4: Protocolos Seed (L5)

Los protocolos se cargan como seed en la migracion SQL. Ejemplos incluidos:

1. **morning-briefing** — trigger `schedule:daily:08:00` — Resumen de agenda + tareas + contexto
2. **meeting-prep** — trigger `calendar:meeting:30min_before` — Prep automatico con memoria semantica
3. **nightly-consolidation** — trigger `schedule:daily:02:00` — Flush L2→L3, resume L3→L6, embed L4
4. **critical-alert** — trigger `watcher:critical` — Auto-restart + notify Telegram

### Paso 5: Workflows n8n

4 workflows JSON listos para importar:

1. **Google Calendar → MEMU** — Cron cada hora, sincroniza eventos via `/api/calendar/inject`
2. **Morning Briefing** — Cron 08:00, genera briefing con datos de MEMU, envia a agente
3. **Nightly Consolidation** — Cron 02:00, llama `/api/consolidate`
4. **Watcher Alerts** — Webhook desde PostgreSQL trigger, envia alertas a Telegram

## Patrones Clave

### buildAgentContext() — El Corazon de MEMU

```typescript
async function buildAgentContext(agentId, sessionId, currentQuery) {
  // Ejecutar las 7 capas en PARALELO para minima latencia
  const [sessionHistory, recentInteractions, semanticMatches,
         relevantFacts, workingMemory, metaConfig] = await Promise.all([
    l3GetSession(sessionId, 20),       // L3: historial
    l2Get(agentId, 10),                // L2: recientes
    l4Search(agentId, currentQuery, 5),// L4: semantico
    l6GetFacts(agentId),               // L6: hechos
    l1GetAll(sessionId),               // L1: working
    l7GetMeta(agentId, 'config'),      // L7: config
  ])
  const activeProtocols = await l5GetByTrigger(agentId, 'context:' + agentId) // L5
  return { session_history, recent_interactions, semantic_matches,
           relevant_facts, active_protocols, working_memory, meta_config }
}
```

### Doble Indexacion (L3+L4)

Cuando se guarda un episodio, se indexa en DOS capas simultaneamente:
- L3 (Supabase): para consulta por session_id (historial lineal)
- L4 (pgvector): para busqueda semantica (embeddings)

```typescript
// En POST /api/episodes
await l3Save(session_id, agent_id, role, content, metadata)      // L3
await l2Push(agent_id, { content: `[${role}] ${content}` })       // L2
if (role === 'assistant' && content.length > 100) {
  await l4Index(agent_id, content, 'episode', episodeId, [], {})  // L4
}
```

### Redis Key Patterns

```
l1:{sessionId}:{key}     → Working memory (TTL 1h)
l2:{agentId}:interactions → Short-term list (TTL 24h, max 200)
```

## Variables de Entorno Requeridas

```bash
# Supabase
SUPABASE_URL=http://supabase-kong:8000
SUPABASE_SERVICE_KEY=eyJhbGciOi...

# Redis
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=<generado>

# Embeddings
NVIDIA_API_KEY=nvapi-...
EMBEDDING_MODEL=nvidia/llama-3.2-nv-embedqa-1b-v2

# MEMU
MEMU_API_KEY=<generado>
PORT=5000
REDIS_L1_TTL_SECONDS=3600
REDIS_L2_TTL_SECONDS=86400
```

## Nota sobre Sistemas Complementarios

Este skill documenta MEMU (TypeScript + Express), el sistema de memoria de 7 capas para NEMOCLAW-AGENT. Es **independiente** del sistema de memoria de 3 capas de CLAUDE-BRAIN (Python + FastAPI, documentado en `docker-agent-orchestration`). Ambos usan pgvector pero con dimensiones diferentes:

- **MEMU**: NVIDIA llama-3.2-nv-embedqa-1b-v2 → VECTOR(**1024**) dims
- **CLAUDE-BRAIN**: nomic-embed-text-v1.5 → VECTOR(**768**) dims

NO son intercambiables. Elige uno segun tu stack (TypeScript vs Python).

## Nota sobre Workflows n8n

Los 4 workflows n8n mencionados (Calendar sync, Morning Briefing, Nightly Consolidation, Watcher Alerts) se configuran manualmente en n8n usando los endpoints de esta API. No se incluyen JSONs pre-construidos — deben crearse como HTTP Request nodes apuntando a los endpoints `/api/consolidate`, `/api/calendar/inject`, `/api/context`, etc.

## Archivos de Referencia

- `references/memu-api.ts` — Codigo completo del servidor MEMU (611 lineas)
- `references/memu-schema.sql` — Schema SQL completo con todas las tablas, indices, funciones y seeds (366 lineas)
