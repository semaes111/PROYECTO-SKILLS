---
name: "Vercel AI SDK Multi-Provider System"
description: "Sistema integral para trabajar con múltiples proveedores de IA (OpenAI, Anthropic, Google, Ollama, OpenRouter) usando Vercel AI SDK. Incluye patrones de streaming, tool calling, embeddings, y optimizaciones de rendimiento."
triggers:
  - "vercel ai sdk"
  - "multi provider ia"
  - "ai streaming"
  - "tool calling"
  - "embeddings"
  - "structured output"
version: "1.0.0"
tags: ["backend", "ia", "streaming", "sdk", "next.js"]
---

# Vercel AI SDK: Sistema Multi-Proveedor

## Instalación

```bash
npm install ai @ai-sdk/openai @ai-sdk/anthropic @ai-sdk/google
# Proveedores adicionales según necesidad
npm install @ai-sdk/ollama @ai-sdk/cohere
```

## Configuración de Proveedores

### OpenAI

```typescript
import { openai } from '@ai-sdk/openai';

const model = openai('gpt-4-turbo');
// Alternativas: gpt-4o, gpt-3.5-turbo
```

### Anthropic (Claude)

```typescript
import { anthropic } from '@ai-sdk/anthropic';

const model = anthropic('claude-3-5-sonnet-20241022');
// Alternativas: claude-3-opus, claude-3-sonnet
```

### Google (Gemini)

```typescript
import { google } from '@ai-sdk/google';

const model = google('gemini-2.0-flash');
// Alternativas: gemini-1.5-pro, gemini-1.5-flash
```

### Ollama (Local)

```typescript
import { openai } from '@ai-sdk/openai';

const ollama = openai.baseURL('http://localhost:11434/v1')('mistral');
// Compatible con OpenAI API
```

### OpenRouter (Router Múltiple)

```typescript
import { openai } from '@ai-sdk/openai';

const router = openai.baseURL('https://openrouter.ai/api/v1')(
  'anthropic/claude-3.5-sonnet'
);
```

## Funciones Principales

### generateText() - Generación Simple

```typescript
import { generateText, openai } from 'ai';

const { text, usage } = await generateText({
  model: openai('gpt-4-turbo'),
  prompt: 'Explica quantum computing en 50 palabras.',
  maxTokens: 100,
  temperature: 0.7,
});

console.log(text);
console.log('Tokens:', usage?.totalTokens);
```

### streamText() - Streaming en Tiempo Real

```typescript
import { streamText } from 'ai';

const stream = await streamText({
  model: openai('gpt-4-turbo'),
  prompt: 'Genera una receta de pasta.',
  maxTokens: 500,
});

for await (const chunk of stream.fullStream) {
  if (chunk.type === 'text-delta') {
    process.stdout.write(chunk.delta);
  }
}
```

### generateObject() - Salida Estructurada

```typescript
import { generateObject } from 'ai';
import { z } from 'zod';

const schema = z.object({
  titulo: z.string(),
  resumen: z.string(),
  tags: z.array(z.string()),
});

const { object } = await generateObject({
  model: openai('gpt-4-turbo'),
  prompt: 'Analiza este artículo...',
  schema,
});
```

## Patrones de Streaming Avanzado

### Event-Driven Streaming

```typescript
const stream = await streamText({
  model: anthropic('claude-3-sonnet'),
  prompt: 'Cuéntame un chiste.',
  system: 'Eres un comediante.',
});

// Escuchar eventos específicos
for await (const event of stream.fullStream) {
  switch (event.type) {
    case 'text-delta':
      console.log('Texto:', event.delta);
      break;
    case 'tool-call':
      console.log('Herramienta:', event.toolName, event.toolCallId);
      break;
    case 'step-finish':
      console.log('Paso completado. Tokens:', event.usage);
      break;
  }
}
```

## Definición de Herramientas (Tools)

### Tool con Zod Schema

```typescript
import { tool } from 'ai';
import { z } from 'zod';

const obtenerTiempo = tool({
  description: 'Obtiene el clima de una ciudad',
  parameters: z.object({
    ciudad: z.string().describe('Nombre de la ciudad'),
    unidad: z.enum(['celsius', 'fahrenheit']).default('celsius'),
  }),
  execute: async ({ ciudad, unidad }) => {
    // Simular llamada API
    return { ciudad, temperatura: 22, unidad, condicion: 'soleado' };
  },
});

const buscarBD = tool({
  description: 'Busca documentos en base de datos',
  parameters: z.object({
    query: z.string(),
    limite: z.number().int().positive().default(10),
  }),
  execute: async ({ query, limite }) => {
    // Implementar búsqueda real
    return [{ id: 1, contenido: 'Resultado 1' }];
  },
});
```

### Tool Calling con Múltiples Pasos

```typescript
import { generateText } from 'ai';

const { text } = await generateText({
  model: openai('gpt-4-turbo'),
  tools: { obtenerTiempo, buscarBD },
  prompt: '¿Cuál es el clima hoy en Madrid?',
  maxSteps: 5, // Permite hasta 5 pasos de tool calling
  system: 'Usa las herramientas disponibles para responder.',
});
```

## Embeddings

### Generar Embeddings

```typescript
import { embed } from 'ai';
import { openai } from '@ai-sdk/openai';

const { embedding } = await embed({
  model: openai.embedding('text-embedding-3-small'),
  value: 'Este es un texto importante para analizar.',
});

console.log('Embedding:', embedding); // Array de 1536 dimensiones
```

### Batch Embeddings

```typescript
import { embedMany } from 'ai';

const { embeddings } = await embedMany({
  model: openai.embedding('text-embedding-3-small'),
  values: [
    'Primer documento',
    'Segundo documento',
    'Tercer documento',
  ],
});

// Calcular similitud coseno
function cosineSimilarity(a: number[], b: number[]): number {
  const dotProduct = a.reduce((sum, x, i) => sum + x * b[i], 0);
  const norm_a = Math.sqrt(a.reduce((sum, x) => sum + x * x, 0));
  const norm_b = Math.sqrt(b.reduce((sum, x) => sum + x * x, 0));
  return dotProduct / (norm_a * norm_b);
}
```

## RAG Pattern (Retrieval-Augmented Generation)

```typescript
import { generateText, embed, embedMany } from 'ai';

async function ragPipeline(query: string) {
  // 1. Embedear la consulta
  const { embedding: queryEmbedding } = await embed({
    model: openai.embedding('text-embedding-3-small'),
    value: query,
  });

  // 2. Buscar documentos similares (simulado)
  const documentos = [
    'Base de datos de clientes activos en 2024',
    'Políticas de privacidad actualizadas',
  ];
  const { embeddings } = await embedMany({
    model: openai.embedding('text-embedding-3-small'),
    values: documentos,
  });

  // 3. Seleccionar documentos relevantes
  const similaridades = embeddings.map((emb, idx) => ({
    idx,
    score: cosineSimilarity(queryEmbedding, emb),
    doc: documentos[idx],
  }));
  similaridades.sort((a, b) => b.score - a.score);
  const contexto = similaridades.slice(0, 3).map(s => s.doc).join('\n\n');

  // 4. Generar respuesta
  const { text } = await generateText({
    model: openai('gpt-4-turbo'),
    prompt: `Contexto:\n${contexto}\n\nPregunta: ${query}`,
  });

  return text;
}
```

## Generación de Imágenes

```typescript
import { experimental_generateImage } from 'ai';
import { openai } from '@ai-sdk/openai';

const { image } = await experimental_generateImage({
  model: openai.image('dall-e-3'),
  prompt: 'Un gato jugando ajedrez en una cafetería parisina',
  size: '1024x1024',
  quality: 'hd',
});

console.log('URL imagen:', image.url);
```

## Provider Router (Dinámico)

```typescript
import { openai } from '@ai-sdk/openai';
import { anthropic } from '@ai-sdk/anthropic';
import { generateText } from 'ai';

type ProviderKey = 'openai' | 'anthropic' | 'fallback';

const providers = {
  openai: openai('gpt-4-turbo'),
  anthropic: anthropic('claude-3-sonnet'),
  fallback: openai('gpt-3.5-turbo'),
};

async function routeRequest(
  prompt: string,
  preferredProvider: ProviderKey = 'openai'
) {
  try {
    const { text } = await generateText({
      model: providers[preferredProvider],
      prompt,
      maxTokens: 500,
    });
    return { text, provider: preferredProvider };
  } catch (error) {
    // Fallback automático
    if (preferredProvider !== 'fallback') {
      return routeRequest(prompt, 'fallback');
    }
    throw error;
  }
}
```

## Configuración de Modelos

```typescript
const config = {
  temperature: 0.7,      // 0=determinístico, 1=creativo
  topP: 0.9,             // Nucleus sampling
  maxTokens: 2000,
  presencePenalty: 0.6,  // Penalizar repetición
  frequencyPenalty: 0.5, // Penalizar tokens frecuentes
  topK: 40,              // Top K sampling (algunos modelos)
};

await generateText({
  model: openai('gpt-4-turbo'),
  prompt: 'Genera código creativo.',
  ...config,
});
```

## Manejo de Errores y Reintentos

```typescript
import { generateText } from 'ai';
import { openai } from '@ai-sdk/openai';

async function withRetry(
  fn: () => Promise<string>,
  maxRetries = 3,
  delayMs = 1000
): Promise<string> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries) throw error;
      
      const delay = delayMs * Math.pow(2, attempt - 1); // Backoff exponencial
      console.log(`Intento ${attempt} falló. Reintentando en ${delay}ms`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw new Error('Max retries exceeded');
}

const result = await withRetry(async () => {
  const { text } = await generateText({
    model: openai('gpt-4-turbo'),
    prompt: 'Importante',
  });
  return text;
});
```

## Tracking de Tokens

```typescript
interface TokenMetrics {
  inputTokens: number;
  outputTokens: number;
  totalTokens: number;
  estimatedCost: number;
}

function calculateTokenCost(
  usage: Record<string, number>,
  provider: 'openai' | 'anthropic'
): TokenMetrics {
  const costs = {
    openai: { input: 0.003 / 1000, output: 0.006 / 1000 },
    anthropic: { input: 0.003 / 1000, output: 0.015 / 1000 },
  };

  const { input: inputCost, output: outputCost } = costs[provider];
  const inputTokens = usage.inputTokens || 0;
  const outputTokens = usage.outputTokens || 0;

  return {
    inputTokens,
    outputTokens,
    totalTokens: inputTokens + outputTokens,
    estimatedCost:
      inputTokens * inputCost + outputTokens * outputCost,
  };
}
```

## Integración Next.js: useChat Hook

```typescript
// app/components/ChatComponent.tsx
'use client';

import { useChat } from 'ai/react';

export function ChatComponent() {
  const { messages, input, handleInputChange, handleSubmit } =
    useChat({
      api: '/api/chat',
      onError: (error) => console.error('Error:', error),
    });

  return (
    <div className="chat-container">
      <div className="messages">
        {messages.map((msg) => (
          <div key={msg.id} className={`message ${msg.role}`}>
            {msg.content}
          </div>
        ))}
      </div>
      <form onSubmit={handleSubmit} className="input-form">
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Escribe tu pregunta..."
        />
        <button type="submit">Enviar</button>
      </form>
    </div>
  );
}
```

## Route Handler para Chat

```typescript
// app/api/chat/route.ts
import { streamText } from 'ai';
import { openai } from '@ai-sdk/openai';

export const runtime = 'nodejs';

export async function POST(req: Request) {
  const { messages } = await req.json();

  const stream = await streamText({
    model: openai('gpt-4-turbo'),
    system: 'Eres un asistente experto en tecnología.',
    messages,
    maxTokens: 1000,
  });

  return stream.toDataStreamResponse();
}
```

## Server Component con Streaming

```typescript
// app/components/AIContent.tsx
import { streamText } from 'ai';
import { openai } from '@ai-sdk/openai';

export async function AIContent({ prompt }: { prompt: string }) {
  const { text, usage } = await streamText({
    model: openai('gpt-4-turbo'),
    prompt,
  });

  return (
    <div>
      <p>{await text}</p>
      <small>Tokens utilizados: {usage?.totalTokens}</small>
    </div>
  );
}
```

## Caching y Rate Limiting

```typescript
import { LRUCache } from 'lru-cache';
import { generateText } from 'ai';

const cache = new LRUCache<string, string>({
  max: 500,
  ttl: 1000 * 60 * 60, // 1 hora
});

async function cachedGenerate(prompt: string) {
  const cacheKey = `prompt:${prompt}`;

  if (cache.has(cacheKey)) {
    return { text: cache.get(cacheKey)!, fromCache: true };
  }

  const { text } = await generateText({
    model: openai('gpt-4-turbo'),
    prompt,
  });

  cache.set(cacheKey, text);
  return { text, fromCache: false };
}

// Rate Limiting
class RateLimiter {
  private calls: number[] = [];
  constructor(
    private maxCalls: number,
    private windowMs: number
  ) {}

  async acquire(): Promise<void> {
    const now = Date.now();
    this.calls = this.calls.filter(t => now - t < this.windowMs);

    if (this.calls.length >= this.maxCalls) {
      const oldestCall = this.calls[0];
      const waitTime = oldestCall + this.windowMs - now;
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }

    this.calls.push(now);
  }
}

const limiter = new RateLimiter(10, 60000); // 10 calls/min
```

## Proveedores Fallback

```typescript
import { generateText } from 'ai';
import { openai } from '@ai-sdk/openai';
import { anthropic } from '@ai-sdk/anthropic';

async function generateWithFallback(prompt: string) {
  const providers = [
    { model: openai('gpt-4-turbo'), name: 'OpenAI' },
    { model: anthropic('claude-3-sonnet'), name: 'Anthropic' },
  ];

  for (const { model, name } of providers) {
    try {
      console.log(`Intentando con ${name}...`);
      const { text } = await generateText({
        model,
        prompt,
        maxTokens: 500,
      });
      return { text, provider: name };
    } catch (error) {
      console.error(`${name} falló:`, error);
    }
  }

  throw new Error('Todos los proveedores fallaron');
}
```

## Notas de Rendimiento

- **Streaming**: Siempre usa `streamText()` para UX responsivo en chat
- **Embeddings**: Cachea embeddings para consultas frecuentes
- **Tokens**: Monitorea uso de tokens para controlar costos
- **Fallbacks**: Implementa múltiples proveedores para resiliencia
- **Modelos**: Usa GPT-3.5 para tareas simples, GPT-4 para complejas
