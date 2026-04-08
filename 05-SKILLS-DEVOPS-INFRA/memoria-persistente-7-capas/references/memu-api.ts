// ============================================================
// MEMU API — 7-Layer Memory Orchestrator
// NextHorizont AI · NemoClaw Stack
// ============================================================

import express, { Request, Response, NextFunction } from 'express'
import { createClient, SupabaseClient } from '@supabase/supabase-js'
import Redis from 'ioredis'
import { QdrantClient } from '@qdrant/js-client-rest'

// ── Types ────────────────────────────────────────────────────

interface MemoryEntry {
  content: string
  metadata?: Record<string, unknown>
  tags?: string[]
}

interface SemanticSearchResult {
  id: string
  content: string
  source_type: string
  similarity: number
  metadata: Record<string, unknown>
}

interface HealthStatus {
  status: 'ok' | 'degraded' | 'down'
  layers: Record<string, 'ok' | 'down'>
  uptime: number
  timestamp: string
}

// ── Config ───────────────────────────────────────────────────

const PORT = parseInt(process.env.PORT ?? '5000')
const MEMU_API_KEY = process.env.MEMU_API_KEY!
const REDIS_L1_TTL = parseInt(process.env.REDIS_L1_TTL_SECONDS ?? '3600')
const REDIS_L2_TTL = parseInt(process.env.REDIS_L2_TTL_SECONDS ?? '86400')
const SEMANTIC_THRESHOLD = 0.72

// ── Clients ──────────────────────────────────────────────────

const supabase: SupabaseClient = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
)

const redis = new Redis(process.env.REDIS_URL ?? 'redis://redis:6379', {
  password: process.env.REDIS_PASSWORD,
  lazyConnect: true,
  retryStrategy: (times) => Math.min(times * 100, 3000),
})

const qdrant = new QdrantClient({ url: process.env.QDRANT_URL ?? 'http://qdrant:6333' })

// ── Embedding helper ─────────────────────────────────────────

async function getEmbedding(text: string): Promise<number[]> {
  const response = await fetch(
    'https://integrate.api.nvidia.com/v1/embeddings',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${process.env.NVIDIA_API_KEY}`,
      },
      body: JSON.stringify({
        model: process.env.EMBEDDING_MODEL ?? 'nvidia/llama-3.2-nv-embedqa-1b-v2',
        input: text,
        input_type: 'query',
      }),
    }
  )
  if (!response.ok) throw new Error(`Embedding API error: ${response.status}`)
  const data = await response.json() as { data: Array<{ embedding: number[] }> }
  return data.data[0]!.embedding
}

// ── MEMU Layer Operations ────────────────────────────────────

/**
 * L1: Working Memory — Redis ephemeral, TTL 1h
 * Contexto de sesión activa en memoria RAM
 */
async function l1Set(sessionId: string, key: string, value: string): Promise<void> {
  const redisKey = `l1:${sessionId}:${key}`
  await redis.setex(redisKey, REDIS_L1_TTL, value)
}

async function l1Get(sessionId: string, key: string): Promise<string | null> {
  return redis.get(`l1:${sessionId}:${key}`)
}

async function l1GetAll(sessionId: string): Promise<Record<string, string>> {
  const keys = await redis.keys(`l1:${sessionId}:*`)
  if (!keys.length) return {}
  const values = await redis.mget(...keys)
  return Object.fromEntries(
    keys.map((k, i) => [k.replace(`l1:${sessionId}:`, ''), values[i] ?? ''])
  )
}

/**
 * L2: Short-Term Memory — Redis, TTL 24h
 * Interacciones recientes del día
 */
async function l2Push(agentId: string, entry: MemoryEntry): Promise<void> {
  const key = `l2:${agentId}:interactions`
  const serialized = JSON.stringify({ ...entry, timestamp: Date.now() })
  await redis.lpush(key, serialized)
  await redis.expire(key, REDIS_L2_TTL)
  await redis.ltrim(key, 0, 199) // máximo 200 entradas
}

async function l2Get(agentId: string, limit = 20): Promise<MemoryEntry[]> {
  const key = `l2:${agentId}:interactions`
  const items = await redis.lrange(key, 0, limit - 1)
  return items.map((item) => JSON.parse(item) as MemoryEntry)
}

async function l2Flush(agentId: string): Promise<MemoryEntry[]> {
  const items = await l2Get(agentId, 200)
  await redis.del(`l2:${agentId}:interactions`)
  return items
}

/**
 * L3: Episodic Memory — Supabase, historial persistente
 */
async function l3Save(
  sessionId: string,
  agentId: string,
  role: 'user' | 'assistant' | 'system' | 'tool',
  content: string,
  metadata: Record<string, unknown> = {}
): Promise<string> {
  const { data, error } = await supabase
    .from('memu_episodes')
    .insert({ session_id: sessionId, agent_id: agentId, role, content, metadata })
    .select('id')
    .single()

  if (error) throw new Error(`L3 save error: ${error.message}`)
  return data!.id as string
}

async function l3GetSession(sessionId: string, limit = 50): Promise<Array<{
  id: string; role: string; content: string; created_at: string
}>> {
  const { data, error } = await supabase
    .from('memu_episodes')
    .select('id, role, content, created_at')
    .eq('session_id', sessionId)
    .order('created_at', { ascending: true })
    .limit(limit)

  if (error) throw new Error(`L3 query error: ${error.message}`)
  return data ?? []
}

/**
 * L4: Semantic Memory — Supabase pgvector + Qdrant
 * Búsqueda por similitud coseno sobre embeddings
 */
async function l4Index(
  agentId: string,
  content: string,
  sourceType: string,
  sourceId?: string,
  tags: string[] = [],
  metadata: Record<string, unknown> = {}
): Promise<void> {
  const embedding = await getEmbedding(content)

  const { error } = await supabase
    .from('memu_semantic')
    .insert({
      agent_id: agentId,
      content,
      embedding,
      source_type: sourceType,
      source_id: sourceId,
      tags,
      metadata,
    })

  if (error) throw new Error(`L4 index error: ${error.message}`)
}

async function l4Search(
  agentId: string,
  query: string,
  topK = 5
): Promise<SemanticSearchResult[]> {
  const embedding = await getEmbedding(query)

  const { data, error } = await supabase.rpc('memu_search_semantic', {
    query_embedding: embedding,
    match_threshold: SEMANTIC_THRESHOLD,
    match_count: topK,
    p_agent_id: agentId,
  })

  if (error) throw new Error(`L4 search error: ${error.message}`)
  return (data ?? []) as SemanticSearchResult[]
}

/**
 * L5: Procedural Memory — Supabase protocols/SOPs
 */
async function l5GetProtocol(agentId: string, slug: string): Promise<Record<string, unknown> | null> {
  const { data, error } = await supabase
    .from('memu_protocols')
    .select('*')
    .eq('agent_id', agentId)
    .eq('slug', slug)
    .eq('is_active', true)
    .single()

  if (error) return null
  return data
}

async function l5GetByTrigger(agentId: string, triggerEvent: string): Promise<Array<Record<string, unknown>>> {
  const { data, error } = await supabase
    .from('memu_protocols')
    .select('*')
    .eq('agent_id', agentId)
    .eq('trigger_event', triggerEvent)
    .eq('is_active', true)
    .order('priority', { ascending: true })

  if (error) throw new Error(`L5 query error: ${error.message}`)
  return data ?? []
}

/**
 * L6: Long-Term Memory — Supabase facts permanentes
 */
async function l6SetFact(
  agentId: string,
  key: string,
  value: string,
  category: string,
  metadata: Record<string, unknown> = {}
): Promise<void> {
  const { error } = await supabase
    .from('memu_facts')
    .upsert(
      { agent_id: agentId, key, value, category, metadata, updated_at: new Date().toISOString() },
      { onConflict: 'agent_id,key' }
    )

  if (error) throw new Error(`L6 upsert error: ${error.message}`)
}

async function l6GetFacts(
  agentId: string,
  category?: string
): Promise<Array<{ key: string; value: string; category: string }>> {
  let query = supabase
    .from('memu_facts')
    .select('key, value, category')
    .eq('agent_id', agentId)
    .or('expires_at.is.null,expires_at.gt.' + new Date().toISOString())

  if (category) query = query.eq('category', category)

  const { data, error } = await query
  if (error) throw new Error(`L6 query error: ${error.message}`)
  return data ?? []
}

/**
 * L7: Meta-Memory — Calibración y estado del sistema
 */
async function l7GetMeta(agentId: string, key: string): Promise<Record<string, unknown>> {
  const { data, error } = await supabase
    .from('memu_meta')
    .select('value')
    .eq('agent_id', agentId)
    .eq('key', key)
    .single()

  if (error) return {}
  return (data?.value as Record<string, unknown>) ?? {}
}

async function l7UpdateMeta(
  agentId: string,
  key: string,
  value: Record<string, unknown>
): Promise<void> {
  const { error } = await supabase
    .from('memu_meta')
    .upsert(
      { agent_id: agentId, key, value, updated_at: new Date().toISOString() },
      { onConflict: 'agent_id,key' }
    )

  if (error) throw new Error(`L7 update error: ${error.message}`)
}

// ── Context Builder — el corazón de MEMU ────────────────────

/**
 * Construye el contexto completo para el agente combinando
 * las 7 capas de memoria relevantes para una query dada
 */
async function buildAgentContext(
  agentId: string,
  sessionId: string,
  currentQuery: string
): Promise<{
  session_history: Array<{ role: string; content: string }>
  recent_interactions: MemoryEntry[]
  semantic_matches: SemanticSearchResult[]
  relevant_facts: Array<{ key: string; value: string }>
  active_protocols: Array<Record<string, unknown>>
  working_memory: Record<string, string>
  meta_config: Record<string, unknown>
}> {
  const [
    sessionHistory,
    recentInteractions,
    semanticMatches,
    relevantFacts,
    workingMemory,
    metaConfig,
  ] = await Promise.all([
    l3GetSession(sessionId, 20),
    l2Get(agentId, 10),
    l4Search(agentId, currentQuery, 5),
    l6GetFacts(agentId),
    l1GetAll(sessionId),
    l7GetMeta(agentId, 'config'),
  ])

  // Buscar protocolos relevantes para el contexto actual
  const activeProtocols = await l5GetByTrigger(agentId, 'context:' + agentId)

  return {
    session_history: sessionHistory.map(({ role, content }) => ({ role, content })),
    recent_interactions: recentInteractions,
    semantic_matches: semanticMatches,
    relevant_facts: relevantFacts,
    active_protocols: activeProtocols,
    working_memory: workingMemory,
    meta_config: metaConfig,
  }
}

// ── Express App ──────────────────────────────────────────────

const app = express()
app.use(express.json({ limit: '2mb' }))

// Auth middleware
function requireApiKey(req: Request, res: Response, next: NextFunction): void {
  const key = req.headers['x-memu-api-key'] ?? req.headers['authorization']?.replace('Bearer ', '')
  if (key !== MEMU_API_KEY) {
    res.status(401).json({ error: 'Unauthorized' })
    return
  }
  next()
}

app.use('/api', requireApiKey)

// ── Health ───────────────────────────────────────────────────

app.get('/health', async (_req: Request, res: Response) => {
  const layers: Record<string, 'ok' | 'down'> = {}

  // Check Redis
  try {
    await redis.ping()
    layers['L1_L2_redis'] = 'ok'
  } catch {
    layers['L1_L2_redis'] = 'down'
  }

  // Check Supabase
  try {
    await supabase.from('memu_meta').select('id').limit(1)
    layers['L3_L6_L7_supabase'] = 'ok'
  } catch {
    layers['L3_L6_L7_supabase'] = 'down'
  }

  // Check Qdrant
  try {
    await qdrant.getCollections()
    layers['L4_qdrant'] = 'ok'
  } catch {
    layers['L4_qdrant'] = 'down'
  }

  const allOk = Object.values(layers).every((s) => s === 'ok')
  const health: HealthStatus = {
    status: allOk ? 'ok' : 'degraded',
    layers,
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  }

  res.status(allOk ? 200 : 206).json(health)
})

// ── Context endpoint — el más usado ─────────────────────────

app.post('/api/context', async (req: Request, res: Response) => {
  const { agent_id = 'openclaw', session_id, query } = req.body as {
    agent_id?: string; session_id: string; query: string
  }

  if (!session_id || !query) {
    res.status(400).json({ error: 'session_id and query are required' })
    return
  }

  try {
    const context = await buildAgentContext(agent_id, session_id, query)
    res.json({ ok: true, context })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Episode endpoints ────────────────────────────────────────

app.post('/api/episodes', async (req: Request, res: Response) => {
  const { session_id, agent_id = 'openclaw', role, content, metadata } = req.body as {
    session_id: string; agent_id?: string
    role: 'user' | 'assistant' | 'system' | 'tool'
    content: string; metadata?: Record<string, unknown>
  }

  try {
    const episodeId = await l3Save(session_id, agent_id, role, content, metadata)
    // Guardar también en L2 para acceso rápido
    await l2Push(agent_id, { content: `[${role}] ${content}`, metadata })
    // Indexar en L4 si es respuesta del asistente
    if (role === 'assistant' && content.length > 100) {
      await l4Index(agent_id, content, 'episode', episodeId, [], { session_id })
    }
    res.json({ ok: true, episode_id: episodeId })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Facts endpoints ──────────────────────────────────────────

app.post('/api/facts', async (req: Request, res: Response) => {
  const { agent_id = 'openclaw', key, value, category, metadata } = req.body as {
    agent_id?: string; key: string; value: string
    category: string; metadata?: Record<string, unknown>
  }

  try {
    await l6SetFact(agent_id, key, value, category, metadata)
    // Indexar en L4 para búsqueda semántica
    await l4Index(agent_id, `${key}: ${value}`, 'fact', undefined, [category])
    res.json({ ok: true })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

app.get('/api/facts', async (req: Request, res: Response) => {
  const { agent_id = 'openclaw', category } = req.query as {
    agent_id?: string; category?: string
  }

  try {
    const facts = await l6GetFacts(agent_id, category)
    res.json({ ok: true, facts })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Semantic search ──────────────────────────────────────────

app.post('/api/search', async (req: Request, res: Response) => {
  const { agent_id = 'openclaw', query, top_k = 5 } = req.body as {
    agent_id?: string; query: string; top_k?: number
  }

  try {
    const results = await l4Search(agent_id, query, top_k)
    res.json({ ok: true, results })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Working memory (L1) ──────────────────────────────────────

app.post('/api/working-memory', async (req: Request, res: Response) => {
  const { session_id, key, value } = req.body as {
    session_id: string; key: string; value: string
  }

  try {
    await l1Set(session_id, key, value)
    res.json({ ok: true })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Protocols ────────────────────────────────────────────────

app.get('/api/protocols/:slug', async (req: Request, res: Response) => {
  const { slug } = req.params
  const { agent_id = 'openclaw' } = req.query as { agent_id?: string }

  try {
    const protocol = await l5GetProtocol(agent_id, slug)
    if (!protocol) {
      res.status(404).json({ error: 'Protocol not found' })
      return
    }
    res.json({ ok: true, protocol })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Consolidation (llamado por n8n) ──────────────────────────

app.post('/api/consolidate', async (req: Request, res: Response) => {
  const { agent_id = 'openclaw' } = req.body as { agent_id?: string }

  try {
    // 1. Flush L2 → L3
    const l2Items = await l2Flush(agent_id)
    let l3Saved = 0

    for (const item of l2Items) {
      if (item.content && item.content.length > 50) {
        await l3Save('consolidation', agent_id, 'system', item.content, item.metadata ?? {})
        l3Saved++
      }
    }

    // 2. Actualizar stats en L7
    const currentStats = await l7GetMeta(agent_id, 'stats')
    await l7UpdateMeta(agent_id, 'stats', {
      ...currentStats,
      last_consolidation: new Date().toISOString(),
      total_episodes: ((currentStats.total_episodes as number) ?? 0) + l3Saved,
    })

    res.json({ ok: true, l2_flushed: l2Items.length, l3_saved: l3Saved })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Calendar context injection ───────────────────────────────

app.post('/api/calendar/inject', async (req: Request, res: Response) => {
  const { agent_id = 'openclaw', events } = req.body as {
    agent_id?: string
    events: Array<{ title: string; start_at: string; end_at: string; description?: string }>
  }

  try {
    const calendarContext = events
      .map((e) => `- ${e.title} (${new Date(e.start_at).toLocaleTimeString('es-ES')}): ${e.description ?? ''}`)
      .join('\n')

    await l1Set(agent_id, 'today_calendar', calendarContext)
    await l6SetFact(agent_id, 'last_calendar_sync', new Date().toISOString(), 'context')

    res.json({ ok: true, events_injected: events.length })
  } catch (error) {
    res.status(500).json({ error: (error as Error).message })
  }
})

// ── Start ─────────────────────────────────────────────────────

async function start(): Promise<void> {
  await redis.connect()
  console.log('[MEMU] Redis connected')

  // Inicializar colección Qdrant si no existe
  try {
    await qdrant.getCollection('memu_semantic')
  } catch {
    await qdrant.createCollection('memu_semantic', {
      vectors: { size: 1024, distance: 'Cosine' },
    })
    console.log('[MEMU] Qdrant collection created')
  }

  app.listen(PORT, () => {
    console.log(`[MEMU] API listening on port ${PORT}`)
    console.log('[MEMU] 7-layer memory system ready')
  })
}

start().catch((err: unknown) => {
  console.error('[MEMU] Fatal error:', err)
  process.exit(1)
})
