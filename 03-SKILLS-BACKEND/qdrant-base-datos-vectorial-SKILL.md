---
name: Qdrant - Base de Datos Vectorial
description: Base de datos vectorial de alto rendimiento escrita en Rust para almacenar y buscar embeddings en aplicaciones de IA y RAG
triggers:
  - qdrant
  - base de datos vectorial
  - búsqueda semántica
  - embeddings
  - vector database
  - RAG
  - retrieval augmented generation
---

# Qdrant - Base de Datos Vectorial de Alto Rendimiento

## ¿Qué es Qdrant?

Qdrant es una base de datos vectorial de **código abierto**, escrita en **Rust**, optimizada para almacenar, indexar y buscar vectores de alta dimensión con latencias ultra bajas. Es perfecta para aplicaciones de búsqueda semántica, sistemas RAG (Retrieval Augmented Generation), recomendaciones personalizadas y análisis de similitud.

**Características principales:**
- Motor escrito en Rust para máximo rendimiento
- Búsqueda vectorial extremadamente rápida con índices HNSW
- Filtrado avanzado con payloads mientras se busca
- Vectores nombrados para múltiples espacios vectoriales
- Snapshots y replicación para alta disponibilidad
- API REST y gRPC
- Gestión automática de memoria
- Indexación de payloads para filtros ultra rápidos

---

## Instalación

### Docker (Recomendado para desarrollo)

```bash
docker run -p 6333:6333 -p 6334:6334 qdrant/qdrant:latest
```

Con volumen persistente:
```bash
docker run -d \
  --name qdrant \
  -p 6333:6333 \
  -p 6334:6334 \
  -v $(pwd)/qdrant_storage:/qdrant/storage \
  qdrant/qdrant:latest
```

### Binario standalone

```bash
# Descargar desde https://github.com/qdrant/qdrant/releases
wget https://github.com/qdrant/qdrant/releases/download/v1.8.0/qdrant-linux-x86_64
chmod +x qdrant-linux-x86_64
./qdrant-linux-x86_64
```

### Qdrant Cloud (Managed)

Registrarse en https://cloud.qdrant.io para usar clusters gestionados en producción.

---

## Clientes

### Cliente JavaScript/TypeScript

```bash
npm install @qdrant/js-client-rest
```

### Cliente Python

```bash
pip install qdrant-client
```

---

## Conceptos Centrales

### Collections (Colecciones)

Contenedor para vectores. Similar a una tabla en SQL. Cada colección tiene:
- **Nombre único**
- **Dimensión vectorial** (ej: 1536 para OpenAI)
- **Métrica de distancia** (Cosine, Euclidean, Manhattan, Dot Product)
- **Configuración de indexación**

### Points (Puntos)

Cada documento/registro almacenado. Contiene:
- **ID único** (entero o UUID)
- **Vector**: array de floats
- **Payload**: datos JSON asociados (metadatos, texto, etc)

### Vectors (Vectores)

Arrays de números reales de alta dimensión. Representan embeddings de texto, imágenes, etc.

### Payloads (Cargas)

Datos estructurados JSON asociados a cada punto. Ejemplos:
```json
{
  "title": "Mi documento",
  "content": "Contenido...",
  "author": "Juan",
  "timestamp": 1704067200,
  "tags": ["IA", "embeddings"],
  "metadata": {"source": "pdf", "page": 1}
}
```

### Métricas de Distancia

- **Cosine**: ángulo entre vectores (0-2). Mejor para embeddings normalizados
- **Euclidean**: distancia geométrica. Mejor para espacios normalizados
- **Manhattan**: suma de diferencias absolutas
- **Dot Product**: producto punto. Mejor si vectores no están normalizados

---

## Gestión de Colecciones

### Crear colección

```typescript
import { QdrantClient } from '@qdrant/js-client-rest';

const client = new QdrantClient({ url: 'http://localhost:6333' });

// Crear colección simple
await client.recreateCollection('documentos', {
  vectors: {
    size: 1536,
    distance: 'Cosine',
  },
});

// Crear con configuración avanzada (HNSW + cuantización)
await client.recreateCollection('documentos_optimizado', {
  vectors: {
    size: 1536,
    distance: 'Cosine',
  },
  quantization_config: {
    scalar: {
      type: 'uint8',
      quantile: 0.99,
      always_ram: false,
    },
  },
  hnsw_config: {
    m: 16,
    ef_construct: 200,
    full_scan_threshold: 10000,
    max_indexing_threads: 4,
  },
});
```

### Obtener información de colección

```typescript
const info = await client.getCollection('documentos');
console.log(info);
// {
//   status: 'green',
//   vectors_count: 1500,
//   points_count: 1500,
//   config: {...}
// }
```

### Eliminar colección

```typescript
await client.deleteCollection('documentos');
```

---

## Operaciones con Puntos

### Upsert (Insertar o actualizar)

```typescript
// Un punto
await client.upsert('documentos', {
  points: [
    {
      id: 1,
      vector: [0.1, 0.2, 0.3, ...],
      payload: {
        title: 'Documento 1',
        content: 'Lorem ipsum...',
        source: 'pdf',
        timestamp: Date.now(),
      },
    },
  ],
});

// Múltiples puntos (batch)
const points = [];
for (let i = 0; i < 1000; i++) {
  points.push({
    id: i,
    vector: generateEmbedding(`documento_${i}`),
    payload: {
      doc_id: i,
      content: `Contenido ${i}`,
      chunk_index: i % 10,
    },
  });
}

await client.upsert('documentos', { points });
```

### Búsqueda semántica

```typescript
// Búsqueda simple
const results = await client.search('documentos', {
  vector: queryEmbedding,
  limit: 5,
  with_payload: true,
  with_vectors: false,
});

console.log(results);
// [
//   { id: 1, score: 0.95, payload: {...} },
//   { id: 3, score: 0.87, payload: {...} },
//   ...
// ]
```

### Búsqueda con filtros

```typescript
const results = await client.search('documentos', {
  vector: queryEmbedding,
  limit: 10,
  filter: {
    must: [
      {
        key: 'source',
        match: { value: 'pdf' },
      },
      {
        key: 'timestamp',
        range: {
          gte: Date.now() - 30 * 24 * 60 * 60 * 1000, // últimos 30 días
        },
      },
    ],
    should: [
      {
        key: 'importance',
        range: { gte: 7 },
      },
    ],
  },
  with_payload: true,
});
```

### Scroll (Obtener todos los puntos)

```typescript
let all_points = [];
let next_page_offset = null;

do {
  const response = await client.scroll('documentos', {
    limit: 100,
    offset: next_page_offset,
    with_payload: true,
    with_vectors: true,
  });

  all_points = all_points.concat(response.points);
  next_page_offset = response.next_page_offset;
} while (next_page_offset !== null);
```

### Eliminar por filtro

```typescript
await client.deleteByFilter('documentos', {
  filter: {
    must: [
      {
        key: 'source',
        match: { value: 'obsoleto' },
      },
    ],
  },
});
```

---

## Filtrado Avanzado

### Match (igualdad exacta)

```typescript
filter: {
  must: [
    {
      key: 'status',
      match: { value: 'active' },
    },
  ],
}
```

### Range (rango numérico)

```typescript
filter: {
  must: [
    {
      key: 'score',
      range: {
        gte: 0.5,
        lte: 0.99,
      },
    },
  ],
}
```

### Geo (ubicación geográfica)

```typescript
filter: {
  must: [
    {
      key: 'location',
      geo_bounding_box: {
        bottom_right: { lat: -33.5, lon: -55.5 },
        top_left: { lat: -33.0, lon: -55.0 },
      },
    },
  ],
}
```

### Nested (documentos anidados)

```typescript
filter: {
  must: [
    {
      key: 'tags',
      has_id: 'python', // array contiene
    },
  ],
}
```

### Must/Should/MustNot

```typescript
filter: {
  must: [
    // TODOS estos deben ser verdaderos
    { key: 'lang', match: { value: 'es' } },
  ],
  should: [
    // AL MENOS UNO debe ser verdadero
    { key: 'category', match: { value: 'tech' } },
    { key: 'category', match: { value: 'science' } },
  ],
  must_not: [
    // NINGUNO debe ser verdadero
    { key: 'archived', match: { value: true } },
  ],
}
```

---

## Indexación de Payloads

Para que los filtros sean ultra rápidos, indexa los campos que usas frecuentemente:

```typescript
await client.recreateCollection('documentos', {
  vectors: { size: 1536, distance: 'Cosine' },
  payload_indexing_threshold: 10000,
});

// Luego crear índices específicos
await client.createPayloadIndex('documentos', {
  field_name: 'source',
  field_schema: 'keyword', // o 'integer', 'float', 'geo'
});

await client.createPayloadIndex('documentos', {
  field_name: 'timestamp',
  field_schema: 'integer',
});

await client.createPayloadIndex('documentos', {
  field_name: 'tags',
  field_schema: 'keyword',
});
```

---

## Vectores Nombrados

Almacena múltiples vectores por punto para diferentes espacios/modelos:

```typescript
// Crear colección con vectores nombrados
await client.recreateCollection('multi_modal', {
  vectors: {
    text: { size: 1536, distance: 'Cosine' },
    image: { size: 512, distance: 'Cosine' },
    audio: { size: 256, distance: 'Cosine' },
  },
});

// Upsert con múltiples vectores
await client.upsert('multi_modal', {
  points: [
    {
      id: 1,
      vectors: {
        text: textEmbedding,    // 1536
        image: imageEmbedding,  // 512
        audio: audioEmbedding,  // 256
      },
      payload: { title: 'Contenido multimedia' },
    },
  ],
});

// Buscar en vector específico
const results = await client.search('multi_modal', {
  vector: { name: 'text', vector: queryTextEmbedding },
  limit: 5,
});
```

---

## Snapshots y Backups

### Crear snapshot

```typescript
const snapshot = await client.createSnapshot('documentos');
console.log(snapshot.snapshot_description.name);
// qdrant-snapshot-2025-01-15-19-48-32.tar
```

### Recuperar de snapshot

```bash
# En Docker, copiar archivo al volumen
docker cp qdrant-snapshot-2025-01-15-19-48-32.tar qdrant:/qdrant/snapshots/

# Luego en la aplicación
await client.recoverSnapshot('documentos', 'qdrant-snapshot-2025-01-15-19-48-32.tar');
```

---

## Monitoreo

### Health check

```typescript
const health = await client.healthzCheck();
console.log(health.ok); // true/false
```

### Información de clúster

```typescript
const cluster_info = await client.clusterInfo();
console.log(cluster_info.peer_count);
console.log(cluster_info.consensus);
```

### Métricas

```typescript
const collections = await client.getCollections();
console.log(collections.collections);

for (const coll of collections.collections) {
  const info = await client.getCollection(coll.name);
  console.log(`${coll.name}: ${info.points_count} puntos`);
}
```

---

## Ejemplo Completo: Pipeline RAG con TypeScript

```typescript
import { QdrantClient } from '@qdrant/js-client-rest';
import OpenAI from 'openai';

const client = new QdrantClient({ url: 'http://localhost:6333' });
const openai = new OpenAI();

// 1. Crear colección para documentos
async function setupCollection() {
  try {
    await client.recreateCollection('rag_docs', {
      vectors: { size: 1536, distance: 'Cosine' },
    });
    console.log('Colección creada');
  } catch (e) {
    console.log('Colección ya existe');
  }
}

// 2. Embeddings y almacenamiento de documentos
async function indexDocuments(documents) {
  const points = [];

  for (const doc of documents) {
    const embedding = await openai.embeddings.create({
      model: 'text-embedding-3-small',
      input: doc.content,
    });

    points.push({
      id: doc.id,
      vector: embedding.data[0].embedding,
      payload: {
        title: doc.title,
        content: doc.content,
        source: doc.source,
        created_at: Date.now(),
      },
    });
  }

  await client.upsert('rag_docs', { points });
  console.log(`${points.length} documentos indexados`);
}

// 3. Búsqueda semántica
async function semanticSearch(query, limit = 5) {
  const queryEmbedding = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: query,
  });

  const results = await client.search('rag_docs', {
    vector: queryEmbedding.data[0].embedding,
    limit,
    with_payload: true,
  });

  return results;
}

// 4. Generar respuesta con RAG
async function ragGenerate(query) {
  const searchResults = await semanticSearch(query, 3);

  const context = searchResults
    .map(r => `Fuente: ${r.payload.title}\n${r.payload.content}`)
    .join('\n\n---\n\n');

  const completion = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [
      {
        role: 'system',
        content: 'Responde basándote en el contexto proporcionado.',
      },
      {
        role: 'user',
        content: `Contexto:\n${context}\n\nPregunta: ${query}`,
      },
    ],
  });

  return completion.choices[0].message.content;
}

// Uso
await setupCollection();
await indexDocuments([
  {
    id: 1,
    title: 'Introdución a IA',
    content: 'La IA es...',
    source: 'wiki',
  },
]);
const answer = await ragGenerate('¿Qué es la inteligencia artificial?');
console.log(answer);
```

---

## Operaciones en Batch para RAG

```typescript
// Batch search: múltiples queries simultáneamente
async function batchSearch(queries) {
  const queryEmbeddings = await Promise.all(
    queries.map(q =>
      openai.embeddings.create({
        model: 'text-embedding-3-small',
        input: q,
      })
    )
  );

  const searchRequests = queryEmbeddings.map(emb => ({
    vector: emb.data[0].embedding,
    limit: 5,
    with_payload: true,
  }));

  const results = await Promise.all(
    searchRequests.map(req =>
      client.search('rag_docs', req)
    )
  );

  return results;
}

// Batch delete: eliminar múltiples puntos por filtro
async function cleanupOldDocuments(sourceName) {
  await client.deleteByFilter('rag_docs', {
    filter: {
      must: [
        {
          key: 'source',
          match: { value: sourceName },
        },
        {
          key: 'created_at',
          range: {
            lt: Date.now() - 90 * 24 * 60 * 60 * 1000, // más de 90 días
          },
        },
      ],
    },
  });
}
```

---

## Comparativa: Qdrant vs Alternativas

| Base Datos | Lenguaje | Mejor Para | Fortalezas | Debilidades |
|-----------|----------|-----------|-----------|------------|
| **Qdrant** | Rust | RAG, búsqueda semántica | Rendimiento, filtrado avanzado, open-source | Menos maduro que Pinecone |
| **Pinecone** | Managed | Producción serverless | Infraestructura gestionada, escalabilidad | Caro, lock-in de vendor |
| **Weaviate** | Go | Multimodal, recomendaciones | Flexibilidad, múltiples tipos de búsqueda | Más lento en grandes datasets |
| **pgvector** | PostgreSQL | Datos relacionales + vectores | Integración SQL, ACID | No optimizado solo para vectores |
| **ChromaDB** | Python | Prototipado rápido | Fácil de usar, embebido | No escalable, demo solamente |
| **Milvus** | C++ | Datos masivos | Muy rápido, distributed | Complejidad operativa |

**Conclusión**: Qdrant es ideal para **startups y empresas** que necesitan **control, flexibilidad y costos bajos** con **máximo rendimiento**.

---

## Configuración de Producción

### Docker Compose con réplicas

```yaml
version: '3.9'

services:
  qdrant-node-1:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - ./qdrant_node_1:/qdrant/storage
    environment:
      - QDRANT_INIT_TIMEOUT_SEC=30
      - QDRANT_API_KEY=your-secure-key
    command: >
      ./qdrant
      --listen-addr 0.0.0.0:6333
      --grpc-addr 0.0.0.0:6334

  qdrant-node-2:
    image: qdrant/qdrant:latest
    ports:
      - "6335:6333"
      - "6336:6334"
    volumes:
      - ./qdrant_node_2:/qdrant/storage
    environment:
      - QDRANT_INIT_TIMEOUT_SEC=30
      - QDRANT_API_KEY=your-secure-key

  qdrant-node-3:
    image: qdrant/qdrant:latest
    ports:
      - "6337:6333"
      - "6338:6334"
    volumes:
      - ./qdrant_node_3:/qdrant/storage
    environment:
      - QDRANT_INIT_TIMEOUT_SEC=30
      - QDRANT_API_KEY=your-secure-key
```

### Configuración de sharding

```typescript
// Crear colección con múltiples shards para distribuir carga
await client.recreateCollection('large_dataset', {
  vectors: { size: 1536, distance: 'Cosine' },
  shard_number: 4, // distribuir en 4 shards
  replication_factor: 3, // 3 replicas por shard
  hnsw_config: {
    m: 16,
    ef_construct: 200,
  },
});
```

### Parámetros recomendados

```typescript
// Producción de alto volumen
const PROD_CONFIG = {
  hnsw_config: {
    m: 32,          // mayor densidad de conexiones
    ef_construct: 400,
    max_indexing_threads: 8,
  },
  quantization_config: {
    scalar: {
      type: 'uint8',
      quantile: 0.99,
      always_ram: false, // mejor para memoria
    },
  },
  shard_number: 8,
  replication_factor: 3,
};
```

### Monitoreo en Producción

```typescript
async function monitorHealth() {
  setInterval(async () => {
    try {
      const health = await client.healthzCheck();
      if (!health.ok) {
        console.error('Qdrant no responde');
        // alertar
      }

      const collections = await client.getCollections();
      for (const coll of collections.collections) {
        const info = await client.getCollection(coll.name);
        if (info.status !== 'green') {
          console.warn(`⚠️ ${coll.name} status: ${info.status}`);
        }
      }
    } catch (err) {
      console.error('Error en health check:', err);
    }
  }, 30000); // cada 30 segundos
}
```

---

## Recursos

- **Documentación oficial**: https://qdrant.tech/documentation/
- **API Reference**: https://api.qdrant.tech/
- **GitHub**: https://github.com/qdrant/qdrant
- **Discord Community**: https://qdrant.tech/discord

---

*Última actualización: Abril 2025 | Qdrant v1.8+*
