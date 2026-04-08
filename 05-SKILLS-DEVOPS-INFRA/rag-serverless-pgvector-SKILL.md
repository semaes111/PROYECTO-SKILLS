---
name: rag-serverless-pgvector
description: >
  Blueprint RAG minimalista para busqueda semantica serverless con Vercel
  Functions + Supabase pgvector + embeddings. Patron mas simple posible para
  montar semantic search en minutos: 1 tabla, 1 funcion SQL, 1 indice IVFFlat,
  2 endpoints API. Adaptable a cualquier modelo de embeddings (OpenAI, nomic,
  NVIDIA). Basado en faq-backend-vercel (Next.js 14 + Supabase + pgvector).
  Usar cuando el usuario necesite: busqueda semantica, RAG, knowledge base,
  FAQ inteligente, semantic search, pgvector, embeddings, search by meaning.
triggers:
  - "busqueda semantica"
  - "semantic search"
  - "RAG"
  - "knowledge base con embeddings"
  - "pgvector search"
  - "FAQ inteligente"
  - "busqueda por significado"
type: blueprint
---

# RAG Serverless con pgvector: Blueprint Minimalista

## Vision General

El patron RAG (Retrieval-Augmented Generation) mas simple que funciona en produccion:

```
Pregunta del usuario
    │
    ▼
Generar embedding (OpenAI / nomic / NVIDIA)
    │
    ▼
Buscar por similitud coseno en pgvector
    │
    ▼
Devolver top-K resultados con score
```

**Stack:** Vercel Functions (o Next.js API routes) + Supabase PostgreSQL + pgvector

**Coste:** ~$0 si usas el free tier de Supabase + Vercel

## Schema SQL Completo

```sql
-- 1. Habilitar pgvector
create extension if not exists vector;

-- 2. Tabla con embeddings
create table if not exists faqs (
  id uuid primary key default gen_random_uuid(),
  tema text,                          -- Categoria/topic
  pregunta text not null,             -- Texto original
  respuesta text not null,            -- Contenido asociado
  embedding vector(1536),             -- Embedding del texto
  created_at timestamptz default now()
);

-- 3. Indice IVFFlat para busqueda rapida
--    (IVFFlat para <100K filas, HNSW para >100K)
create index if not exists faqs_embedding_ivfflat
on faqs using ivfflat (embedding vector_cosine_ops)
with (lists = 100);

-- 4. Vista publica (sin embeddings — ahorra bandwidth)
create or replace view public_faqs as
select id, tema, pregunta, respuesta, created_at
from faqs;

-- 5. RLS
alter table faqs enable row level security;

-- 6. Funcion de busqueda semantica
create or replace function match_faqs(
  query_embedding vector(1536),
  match_count int default 5
)
returns table(
  id uuid,
  tema text,
  pregunta text,
  respuesta text,
  score float
)
language sql stable as $$
  select f.id, f.tema, f.pregunta, f.respuesta,
         1 - (f.embedding <#> query_embedding) as score
  from faqs f
  where f.embedding is not null
  order by f.embedding <#> query_embedding
  limit match_count;
$$;

grant execute on function match_faqs(vector, int) to anon, authenticated;
```

## Adaptacion de Dimensiones

El schema usa `vector(1536)` (OpenAI text-embedding-3-small). Para otros modelos:

| Modelo | Dims | Cambiar a |
|--------|------|-----------|
| OpenAI text-embedding-3-small | 1536 | `vector(1536)` |
| OpenAI text-embedding-3-large | 3072 | `vector(3072)` |
| nomic-embed-text-v1.5 (local) | 768 | `vector(768)` |
| NVIDIA llama-3.2-nv-embedqa | 1024 | `vector(1024)` |

## API Endpoints

### POST /api/faqs/search — Busqueda Semantica

```typescript
// app/api/faqs/search/route.ts
import { createClient } from '@supabase/supabase-js';
import OpenAI from 'openai';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export async function POST(request: Request) {
  const { query, limit = 5 } = await request.json();

  // 1. Generar embedding de la pregunta
  const embeddingResponse = await openai.embeddings.create({
    model: process.env.EMBEDDING_MODEL || 'text-embedding-3-small',
    input: query,
  });
  const embedding = embeddingResponse.data[0].embedding;

  // 2. Buscar por similitud en pgvector
  const { data, error } = await supabase.rpc('match_faqs', {
    query_embedding: embedding,
    match_count: limit,
  });

  if (error) return Response.json({ error: error.message }, { status: 500 });

  return Response.json({ results: data });
}
```

### POST /api/faqs/ingest — Ingesta con Embedding

```typescript
// app/api/faqs/ingest/route.ts
export async function POST(request: Request) {
  const { tema, pregunta, respuesta } = await request.json();

  // 1. Generar embedding del contenido
  const embeddingResponse = await openai.embeddings.create({
    model: process.env.EMBEDDING_MODEL || 'text-embedding-3-small',
    input: `${pregunta}\n${respuesta}`,
  });
  const embedding = embeddingResponse.data[0].embedding;

  // 2. Insertar con embedding
  const { data, error } = await supabase
    .from('faqs')
    .insert({ tema, pregunta, respuesta, embedding })
    .select('id')
    .single();

  if (error) return Response.json({ error: error.message }, { status: 500 });

  return Response.json({ id: data.id, status: 'indexed' });
}
```

## Script de Backfill (CSV → pgvector)

```typescript
// scripts/backfill-embeddings.ts
import { parse } from 'csv-parser';
import { createReadStream } from 'fs';

async function backfill(csvPath: string) {
  const rows: any[] = [];

  // Leer CSV
  await new Promise((resolve) => {
    createReadStream(csvPath)
      .pipe(parse())
      .on('data', (row) => rows.push(row))
      .on('end', resolve);
  });

  // Procesar en batches de 100
  for (let i = 0; i < rows.length; i += 100) {
    const batch = rows.slice(i, i + 100);
    const texts = batch.map(r => `${r.pregunta}\n${r.respuesta}`);

    // Batch embedding
    const response = await openai.embeddings.create({
      model: 'text-embedding-3-small',
      input: texts,
    });

    // Upsert a Supabase
    for (let j = 0; j < batch.length; j++) {
      await supabase.from('faqs').insert({
        tema: batch[j].tema,
        pregunta: batch[j].pregunta,
        respuesta: batch[j].respuesta,
        embedding: response.data[j].embedding,
      });
    }

    console.log(`Processed ${Math.min(i + 100, rows.length)}/${rows.length}`);
  }
}
```

## Variables de Entorno

```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...        # Para client-side
SUPABASE_SERVICE_ROLE_KEY=eyJ... # Para server-side (backfill, ingest)
OPENAI_API_KEY=sk-...            # O usar embeddings locales
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIM=1536
```

## IVFFlat vs HNSW

| Metrica | IVFFlat | HNSW |
|---------|---------|------|
| Build time | Rapido | Lento |
| Query speed | Bueno (<100K) | Mejor (>100K) |
| Memory | Bajo | Alto |
| Recuando | Necesita REINDEX | No |

**Regla:** Usa IVFFlat para empezar. Migra a HNSW cuando superes 100K filas.

```sql
-- Migrar de IVFFlat a HNSW
drop index faqs_embedding_ivfflat;
create index faqs_embedding_hnsw
on faqs using hnsw (embedding vector_cosine_ops)
with (m = 16, ef_construction = 64);
```

## Implementacion Paso a Paso

1. `npx create-next-app@latest mi-rag --typescript`
2. `npm install @supabase/supabase-js openai csv-parser`
3. Crear tabla en Supabase (ejecutar schema.sql)
4. Crear los 2 API routes (search + ingest)
5. Backfill datos iniciales con script
6. Deploy a Vercel: `vercel --prod`
