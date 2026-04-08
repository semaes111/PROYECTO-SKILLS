---
name: mcp-reference-patterns
description: >
  Patrones arquitectonicos de los 20+ servidores MCP oficiales de Anthropic.
  Cubre: bootstrap de servidor, definicion de herramientas con JSON Schema,
  request handlers, transport layer (stdio), wrapping de APIs externas,
  acceso a bases de datos, operaciones de filesystem, y manejo de errores.
  Basado en el repositorio oficial modelcontextprotocol/servers.
  Usar cuando el usuario necesite: crear un MCP server, entender patrones MCP,
  implementar herramientas para Claude, wrappear una API como MCP, conectar
  una base de datos via MCP.
triggers:
  - "crear MCP server"
  - "mcp server"
  - "herramientas MCP"
  - "tool definition MCP"
  - "wrappear API como MCP"
  - "MCP patterns"
  - "model context protocol"
type: reference
---

# MCP Reference Patterns: Arquitectura de Servidores MCP Oficiales

## Catalogo de Servidores Oficiales (20+)

| Servidor | Tipo | Lenguaje | Proposito |
|----------|------|----------|-----------|
| filesystem | File ops | TypeScript | Leer/escribir/buscar archivos |
| git | VCS | Python | Operaciones git (clone, commit, diff, log) |
| github | API wrapper | TypeScript | Issues, PRs, repos, search |
| gitlab | API wrapper | TypeScript | MRs, issues, pipelines |
| slack | API wrapper | TypeScript | Mensajes, canales, reacciones |
| postgres | DB access | TypeScript | Queries SQL read-only |
| sqlite | DB access | TypeScript | Queries SQLite |
| redis | DB access | TypeScript | Operaciones Redis |
| puppeteer | Browser | TypeScript | Navegacion, screenshots, scraping |
| brave-search | Search | TypeScript | Busqueda web |
| fetch | HTTP | Python | Fetch de URLs y conversion a markdown |
| memory | Knowledge | TypeScript | Grafo de conocimiento persistente |
| google-maps | API wrapper | TypeScript | Geocoding, directions, places |
| gdrive | API wrapper | TypeScript | Google Drive files |
| sentry | API wrapper | TypeScript | Error tracking |
| everart | API wrapper | TypeScript | Generacion de imagenes |
| sequentialthinking | Reasoning | TypeScript | Pensamiento paso a paso |
| time | Utility | TypeScript | Timezone conversion |
| aws-kb-retrieval | Knowledge | TypeScript | AWS Knowledge Base RAG |

## Patron 1: Bootstrap de Servidor MCP

Todos los servidores siguen exactamente esta estructura:

```typescript
#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
  McpError,
  ErrorCode,
} from "@modelcontextprotocol/sdk/types.js";

// 1. Crear instancia del servidor
const server = new Server(
  { name: "mi-servidor", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

// 2. Registrar handler para listar herramientas
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [miHerramienta1, miHerramienta2]
}));

// 3. Registrar handler para ejecutar herramientas
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  switch (name) {
    case "mi_herramienta_1":
      return await ejecutarHerramienta1(args);
    default:
      throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
  }
});

// 4. Conectar transport y arrancar
const transport = new StdioServerTransport();
await server.connect(transport);
```

**Dependencia unica:** `@modelcontextprotocol/sdk`

## Patron 2: Definicion de Herramientas (Tool Schema)

Cada herramienta se define como un objeto `Tool` con JSON Schema para validacion:

```typescript
// Ejemplo real del servidor Slack
const postMessageTool: Tool = {
  name: "slack_post_message",
  description: "Post a new message to a Slack channel",
  inputSchema: {
    type: "object",
    properties: {
      channel_id: {
        type: "string",
        description: "The ID of the channel to post to"
      },
      text: {
        type: "string",
        description: "The message text (supports Slack markdown)"
      }
    },
    required: ["channel_id", "text"]
  }
};
```

**Reglas clave:**
- `name`: snake_case, prefijado con el servicio (ej: `slack_post_message`)
- `description`: Una linea clara de lo que hace
- `inputSchema`: JSON Schema completo con tipos, descriptions y required
- Siempre definir `required` para parametros obligatorios

## Patron 3: Request Handler con Switch

```typescript
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "slack_list_channels": {
      // Type assertion para validar args
      const { limit = 100, cursor } = args as ListChannelsArgs;
      const result = await slackApi.listChannels(limit, cursor);
      return {
        content: [{ type: "text", text: JSON.stringify(result, null, 2) }]
      };
    }

    case "slack_post_message": {
      const { channel_id, text } = args as PostMessageArgs;
      const result = await slackApi.postMessage(channel_id, text);
      return {
        content: [{ type: "text", text: `Message posted: ${result.ts}` }]
      };
    }

    default:
      throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
  }
});
```

**Formato de respuesta:**
```typescript
// Exito
{ content: [{ type: "text", text: "resultado" }] }

// Error controlado
{ content: [{ type: "text", text: "Error: descripcion" }], isError: true }

// Error no recuperable
throw new McpError(ErrorCode.InternalError, "mensaje")
```

## Patron 4: API Wrapper (Slack, GitHub, etc.)

```typescript
// Clase wrapper que encapsula la API externa
class SlackAPI {
  private token: string;
  private teamId: string;

  constructor() {
    // Auth via environment variables
    this.token = process.env.SLACK_BOT_TOKEN!;
    this.teamId = process.env.SLACK_TEAM_ID!;
    if (!this.token) throw new Error("SLACK_BOT_TOKEN required");
  }

  async listChannels(limit: number, cursor?: string) {
    const params = new URLSearchParams({
      types: "public_channel",
      exclude_archived: "true",
      limit: limit.toString(),
      team_id: this.teamId,
    });
    if (cursor) params.append("cursor", cursor);

    const response = await fetch(
      `https://slack.com/api/conversations.list?${params}`,
      { headers: { Authorization: `Bearer ${this.token}` } }
    );
    return response.json();
  }
}
```

## Patron 5: Database Access (PostgreSQL, SQLite)

```typescript
// Ejemplo real del servidor PostgreSQL
import pg from "pg";

const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });

const queryTool: Tool = {
  name: "postgres_query",
  description: "Run a read-only SQL query",
  inputSchema: {
    type: "object",
    properties: {
      sql: { type: "string", description: "SQL query to execute" }
    },
    required: ["sql"]
  }
};

// Handler con transaction read-only por seguridad
async function executeQuery(sql: string) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN TRANSACTION READ ONLY");
    const result = await client.query(sql);
    await client.query("COMMIT");
    return {
      content: [{
        type: "text",
        text: JSON.stringify(result.rows, null, 2)
      }]
    };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}
```

**Seguridad:** Siempre usar `READ ONLY` transactions para queries.

## Patron 6: Manejo de Errores

```typescript
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";

// Codigos de error estandar
ErrorCode.MethodNotFound    // Herramienta no existe
ErrorCode.InvalidParams     // Parametros invalidos
ErrorCode.InternalError     // Error interno del servidor

// Uso en handler
if (!args.channel_id) {
  throw new McpError(ErrorCode.InvalidParams, "channel_id is required");
}

// Error handler global
server.onerror = (error) => console.error("[MCP Error]", error);
```

## Patron 7: Configuracion en Claude Desktop

```json
// claude_desktop_config.json
{
  "mcpServers": {
    "mi-servidor": {
      "command": "node",
      "args": ["/path/to/mi-servidor/build/index.js"],
      "env": {
        "API_KEY": "tu-api-key",
        "DATABASE_URL": "postgresql://..."
      }
    }
  }
}
```

## Guia Rapida: Crear un MCP Server Nuevo

```bash
# 1. Scaffold
mkdir mi-mcp-server && cd mi-mcp-server
npm init -y
npm install @modelcontextprotocol/sdk

# 2. tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./build",
    "strict": true
  },
  "include": ["src"]
}
EOF

# 3. src/index.ts → usar Patron 1 como base

# 4. Build
npx tsc

# 5. Registrar en Claude Desktop config
```

## Referencia: Todos los ErrorCodes

| Code | Uso |
|------|-----|
| ParseError | JSON malformado |
| InvalidRequest | Request structure invalida |
| MethodNotFound | Tool/method no existe |
| InvalidParams | Parametros invalidos |
| InternalError | Error interno del servidor |
