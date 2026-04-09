---
name: "knowledge-graph-markdown-vault"
description: "Construir grafos de conocimiento usando archivos Markdown (patrón Obsidian vault) con extracción automática de entidades, enlaces wiki y sincronización incremental"
triggers: ["construir grafo de conocimiento", "crear vault Obsidian", "extraer entidades", "indexar conocimiento", "enlaces wiki", "graph markdown"]
languages: ["es"]
category: "knowledge-management"
author: "PROYECTO-SKILLS"
---

## Concepto: Grafo de Conocimiento en Markdown Puro

Un **grafo de conocimiento descentralizado** almacenado como archivos Markdown simples, completamente compatible con Obsidian. Cada entidad (Persona, Organización, Proyecto, Tema) es un archivo individual con metadatos YAML y enlaces wiki (`[[Folder/Name]]`). El sistema:

1. Monitorea fuentes (email, calendario, transcripciones)
2. Extrae entidades con detección de cambios (mtime + SHA256)
3. Resuelve entidades contra notas existentes
4. Actualiza/crea notas con backlinks automáticos
5. Genera un índice centralizado searchable
6. Inyecta contexto en prompts de agentes IA

**Ventaja sobre RAG vectorial puro:** estructura explícita, relaciones tipadas, facilidad de auditoría, zero hallucinations en entidades, compatible con herramientas humanas (Obsidian).

---

## Estructura de Directorios

```
knowledge/
├── People/
│   ├── Juan Pérez.md
│   ├── María García.md
│   └── _template.md
├── Organizations/
│   ├── TechCorp.md
│   ├── Gobierno.md
│   └── _template.md
├── Projects/
│   ├── Sistema de RH.md
│   └── _template.md
├── Topics/
│   ├── Inteligencia Artificial.md
│   ├── Regulación.md
│   └── _template.md
├── Meetings/
│   ├── 2026-04-09 Kickoff.md
│   └── 2026-04-08 Sprint Review.md
├── Voice Memos/
│   ├── 2026-04-09-memo-001.md
│   └── 2026-04-09-memo-002.md
├── knowledge_graph_index.md    # Índice centralizado (generado)
└── knowledge_graph_state.json  # Estado de procesamiento
```

---

## Tipos de Entidades

### 1. **People** (Personas)
Atributos YAML: `name`, `role`, `organization`, `email`, `aliases`, `phone`, `location`, `expertise`, `tags`

### 2. **Organizations** (Organizaciones)
Atributos YAML: `name`, `type`, `industry`, `domain`, `headquarters`, `founded`, `employees`, `tags`

### 3. **Projects** (Proyectos)
Atributos YAML: `name`, `status`, `owner`, `start_date`, `end_date`, `budget`, `stakeholders`, `tags`

### 4. **Topics** (Temas)
Atributos YAML: `name`, `keywords`, `category`, `related_entities`, `description`, `tags`

---

## Sistema de Enlaces Wiki

**Sintaxis básica:**
```markdown
[[People/Juan Pérez]]           # enlace simple
[[Organizations/TechCorp|TC]]   # enlace con alias
[[Projects/Sistema de RH]]       # proyecto
```

**Reescritura automática:** Si `People/Juan Pérez.md` se renombra a `People/Juan Pérez López.md`, el sistema:
1. Escanea TODA la vault
2. Reemplaza `[[People/Juan Pérez]]` con `[[People/Juan Pérez López]]`
3. Mantiene aliases intactos: `[[People/Juan Pérez|JP]]` → `[[People/Juan Pérez López|JP]]`

---

## Índice de Conocimiento

Tabla Markdown generada automáticamente (formato inyección en prompts):

```markdown
| Tipo | Nombre | Organización | Email | Tags |
|------|--------|--------------|-------|------|
| Person | [[People/Juan Pérez]] | [[Organizations/TechCorp]] | juan@techcorp.com | ia,python |
| Organization | [[Organizations/TechCorp]] | - | - | tech,startup |
| Project | [[Projects/Sistema RH]] | [[Organizations/TechCorp]] | - | rh,ia |
| Topic | [[Topics/Machine Learning]] | - | - | ia,ml |
```

Actualizado cada 15 segundos. Formato ideal para `context_injection` en prompts de agentes.

---

## Pipeline de Extracción de Entidades

### Paso 1: Monitoreo de Fuentes
```typescript
const sources = [
  { type: 'email', path: '~/.thunderbird/profile/Mail/' },
  { type: 'calendar', path: '~/.local/share/evolution/calendar/' },
  { type: 'transcript', path: './transcripts/' },
];
```

### Paso 2: Detección de Cambios (Híbrida)
- **mtime check:** cambio en timestamp de archivo
- **SHA256 hash:** verificar contenido realmente cambió
- Evita reprocessing falso

### Paso 3: Extracción en Lotes
Procesa **máximo 10 archivos por lote** cada 15 segundos:
```
[15s] → extraer emails 1-10
[30s] → extraer emails 11-20, procesar batch 1
[45s] → extraer emails 21-30, procesar batch 2
```

### Paso 4: Resolución de Entidades
Dado nombre extraído "Juan Pérez", buscar:
1. `People/Juan Pérez.md` (exact match)
2. `People/Juan*.md` (prefix match)
3. Contenido YAML `aliases: ["JP", "Juan P"]`
4. Si no existe → crear nueva nota

### Paso 5: Creación/Actualización de Notas
- Añadir backlinks automáticos
- Actualizar campos de metadatos
- Preservar contenido existente
- Incrementar versión YAML

### Paso 6: Polling Continuo
Cada 15 segundos, ejecutar ciclo completo (configurable).

---

## Gestión de Estado

Archivo `knowledge_graph_state.json`:

```json
{
  "last_scan": "2026-04-09T14:32:15Z",
  "processed_files": {
    "emails:inbox": {
      "file": "~/.thunderbird/.../mail/INBOX",
      "hash": "abc123def456...",
      "mtime": 1712690535000,
      "processed_at": "2026-04-09T14:32:10Z",
      "entities_extracted": 3
    }
  },
  "graph_version": 42,
  "total_entities": 247,
  "pending_resolution": []
}
```

Permite resumir desde último punto sin reprocessing.

---

## Inyección de Contexto para Agentes IA

El índice se formatea como tabla Markdown para prompt injection:

```typescript
const systemPrompt = `
Eres un asistente de gestión de proyectos.

## Contexto del Grafo de Conocimiento:

${generateIndexTable()}

Usa el grafo para:
- Resolver referencias a personas/orgs
- Sugerir conexiones relevantes
- Validar nombres contra registros
`;
```

El agente puede referenciar entidades por `[[Path/Name]]` y el sistema resuelve automáticamente.

---

## Patrones de Integración

### Con Obsidian
- Vault en `~/Obsidian Vaults/Conocimiento/`
- Plugin "Obsidian Sync" sincroniza con servidor
- Gráficos visuales nativos en Obsidian
- Búsqueda full-text automática

### Con Agentes IA
- Inyectar índice en `system_prompt`
- Agentes escriben respuestas con `[[References]]`
- Post-procesamiento valida enlaces
- Creación automática de notas desde outputs IA

### Con Sistemas RAG
- Índice Markdown actúa como **filtro inicial**
- Reduce corpus vectorial a entidades relevantes
- Complementario (no reemplazo) a embeddings
- Híbrido: búsqueda semántica + búsqueda estructurada

---

## Ejemplos de Código

### 1. Construir Índice desde Vault

```typescript
import * as fs from "fs";
import * as path from "path";

interface Entity {
  type: string;
  name: string;
  metadata: Record<string, any>;
  path: string;
}

function buildKnowledgeIndex(vaultPath: string): Entity[] {
  const entities: Entity[] = [];
  const entityTypes = ["People", "Organizations", "Projects", "Topics"];

  for (const type of entityTypes) {
    const typePath = path.join(vaultPath, type);
    if (!fs.existsSync(typePath)) continue;

    const files = fs.readdirSync(typePath).filter((f) => f.endsWith(".md"));

    for (const file of files) {
      const content = fs.readFileSync(path.join(typePath, file), "utf-8");
      const yamlMatch = content.match(/^---\n([\s\S]*?)\n---/);
      
      if (yamlMatch) {
        const metadata = parseYAML(yamlMatch[1]);
        entities.push({
          type: type.slice(0, -1), // "People" → "Person"
          name: metadata.name || file.replace(".md", ""),
          metadata,
          path: `${type}/${file.replace(".md", "")}`,
        });
      }
    }
  }

  return entities;
}

function generateIndexTable(entities: Entity[]): string {
  const rows = entities.map((e) => 
    `| ${e.type} | [[${e.path}]] | ${e.metadata.organization || "-"} | ${e.metadata.email || "-"} | ${(e.metadata.tags || []).join(",")} |`
  );

  return `| Tipo | Nombre | Organización | Email | Tags |\n|------|--------|--------------|-------|------|\n${rows.join("\n")}`;
}
```

### 2. Extracción de Entidades con LLM

```typescript
interface ExtractionResult {
  entity_type: "Person" | "Organization" | "Project" | "Topic";
  name: string;
  attributes: Record<string, string>;
  references: string[]; // [[Other/Entity]] references
}

async function extractEntitiesFromText(
  text: string,
  context: string
): Promise<ExtractionResult[]> {
  const prompt = `
Extract entities from this text:

${text}

Context:
${context}

Return JSON array with structure:
[{
  "entity_type": "Person|Organization|Project|Topic",
  "name": "string",
  "attributes": { "email": "...", "role": "..." },
  "references": ["[[People/Other Name]]", "[[Organizations/Corp]]"]
}]
`;

  const response = await callLLM(prompt);
  return JSON.parse(response);
}
```

### 3. Parser y Rewriter de Enlaces Wiki

```typescript
function parseWikiLinks(text: string): { target: string; display: string }[] {
  const regex = /\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/g;
  const links = [];
  let match;

  while ((match = regex.exec(text)) !== null) {
    links.push({
      target: match[1].trim(),
      display: match[2]?.trim() || match[1].trim(),
    });
  }

  return links;
}

function rewriteWikiLinks(
  text: string,
  oldPath: string,
  newPath: string
): string {
  const links = parseWikiLinks(text);
  let result = text;

  for (const link of links) {
    if (link.target === oldPath) {
      // Mantener el alias si existe
      const newLink = link.display !== link.target 
        ? `[[${newPath}|${link.display}]]`
        : `[[${newPath}]]`;
      
      result = result.replace(`[[${link.target}${link.display ? `|${link.display}` : ""}]]`, newLink);
    }
  }

  return result;
}
```

### 4. Constructor Incremental de Grafo

```typescript
interface GraphState {
  lastScan: number;
  processedFiles: Record<string, { hash: string; mtime: number; extracted: number }>;
  graphVersion: number;
}

async function incrementalGraphBuilder(
  sourceDir: string,
  vaultPath: string,
  stateFile: string
): Promise<void> {
  const state: GraphState = JSON.parse(fs.readFileSync(stateFile, "utf-8"));
  const batchSize = 10;
  let processed = 0;

  const files = fs.readdirSync(sourceDir);

  for (let i = 0; i < files.length; i += batchSize) {
    const batch = files.slice(i, i + batchSize);

    for (const file of batch) {
      const filePath = path.join(sourceDir, file);
      const content = fs.readFileSync(filePath, "utf-8");
      const hash = sha256(content);
      const mtime = fs.statSync(filePath).mtimeMs;

      const cached = state.processedFiles[file];
      if (cached?.hash === hash && cached?.mtime === mtime) {
        continue; // Ya procesado, skip
      }

      const entities = await extractEntitiesFromText(content, generateIndexTable(buildKnowledgeIndex(vaultPath)));
      const created = await createOrUpdateNotes(entities, vaultPath);

      state.processedFiles[file] = { hash, mtime, extracted: created };
      processed += created;
    }

    console.log(`Batch ${Math.floor(i / batchSize) + 1}: ${processed} entidades procesadas`);
  }

  state.lastScan = Date.now();
  state.graphVersion++;
  fs.writeFileSync(stateFile, JSON.stringify(state, null, 2));
}
```

### 5. Búsqueda en el Grafo

```typescript
function searchKnowledgeGraph(
  entities: Entity[],
  query: string,
  limit: number = 10
): Entity[] {
  const lowerQuery = query.toLowerCase();

  const results = entities.filter((e) => {
    const nameMatch = e.name.toLowerCase().includes(lowerQuery);
    const tagsMatch = (e.metadata.tags || []).some((t: string) =>
      t.toLowerCase().includes(lowerQuery)
    );
    const contentMatch =
      (e.metadata.description || "").toLowerCase().includes(lowerQuery);

    return nameMatch || tagsMatch || contentMatch;
  });

  return results.sort((a, b) => {
    const aScore = a.name.toLowerCase().startsWith(lowerQuery) ? 2 : 1;
    const bScore = b.name.toLowerCase().startsWith(lowerQuery) ? 2 : 1;
    return bScore - aScore;
  }).slice(0, limit);
}
```

---

## Plantillas de Entidades

### People Template
```yaml
---
name: "Nombre Completo"
role: "Cargo"
organization: "[[Organizations/Org Name]]"
email: "correo@dominio.com"
phone: "+34 XXX XXX XXX"
aliases: ["Alias1", "Alias2"]
expertise: ["Area1", "Area2"]
location: "Ciudad, País"
tags: ["tag1", "tag2"]
created: "2026-04-09"
updated: "2026-04-09"
---

## Resumen
Descripción breve de la persona.

## Contexto
- Rol: `role`
- Org: [[Organizations/Name]]
- Contacto: correo@dominio.com

## Relaciones
- Proyectos: [[Projects/X]], [[Projects/Y]]
- Colegas: [[People/Other1]], [[People/Other2]]

## Notas
...
```

### Organizations Template
```yaml
---
name: "Nombre Organización"
type: "Tipo (Empresa/Gobierno/ONG)"
industry: "Industria"
domain: "dominio.com"
headquarters: "Ciudad, País"
founded: "YYYY"
employees: 0
tags: ["tag1"]
created: "2026-04-09"
---

## Descripción
...

## Equipos Clave
- [[People/Person1]]
- [[People/Person2]]

## Proyectos Activos
- [[Projects/Project1]]
```

### Projects Template
```yaml
---
name: "Nombre Proyecto"
status: "Active|Completed|On Hold|Cancelled"
owner: "[[People/Owner Name]]"
start_date: "2026-04-01"
end_date: "2026-12-31"
budget: "USD 100000"
stakeholders:
  - "[[People/Stakeholder1]]"
  - "[[Organizations/Org1]]"
tags: ["tag1"]
---

## Descripción
...

## Hitos
- Q2 2026: Milestone 1
- Q3 2026: Milestone 2

## Decisiones
- Decision 1: Rationale
```

### Topics Template
```yaml
---
name: "Tema"
keywords: ["keyword1", "keyword2"]
category: "Categoría"
tags: ["tag1"]
created: "2026-04-09"
---

## Descripción

## Entidades Relacionadas
- [[People/Expert1]]
- [[Organizations/Research Org]]
- [[Projects/Related Project]]

## Recursos
- Enlace 1
- Enlace 2
```

---

## Ventajas Sobre RAG Vectorial Puro

| Aspecto | Grafo Markdown | RAG Vectorial |
|--------|---|---|
| **Relaciones Tipadas** | Sí (`[[Type/Name]]`) | No |
| **Auditoría** | Archivos humanos legibles | Black box embeddings |
| **Zero Hallucinations** | Entidades verificables | Posibles alucinaciones |
| **Herramientas Humanas** | Obsidian nativo | Requiere UI custom |
| **Escalabilidad** | ~10K entidades óptimo | Millones posible |
| **Latencia Query** | Milisegundos (búsqueda texto) | ~100ms (vector search) |
| **Colaboración** | Git-friendly, mergeable | Snapshots binarios |

**Híbrido recomendado:** Usar grafo Markdown para estructura + embeddings para semántica.

---

## Configuración Inicial

1. **Crear estructura base:**
   ```bash
   mkdir -p knowledge/{People,Organizations,Projects,Topics,Meetings,"Voice Memos"}
   ```

2. **Inicializar state.json:**
   ```json
   { "lastScan": 0, "processedFiles": {}, "graphVersion": 0 }
   ```

3. **Crear .gitignore:**
   ```
   knowledge_graph_state.json
   knowledge_graph_index.md
   .obsidian/
   ```

4. **Ejecutar polling cada 15s:**
   ```bash
   while true; do
     node incremental-builder.js
     sleep 15
   done
   ```

---

## Resumen

Este patrón crea un **grafo de conocimiento descentralizado, auditable y agnóstico** usando Markdown puro. Compatible con Obsidian, inyectable en prompts de IA, y superior a RAG vectorial para entidades y relaciones tipadas. Ideal para sistemas que requieren trazabilidad, colaboración humana y rigor estructural.
