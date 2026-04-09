---
name: openai-agents-sdk
description: "Orquestación de múltiples agentes con @openai/agents SDK. Usar cuando se construyan sistemas multi-agente con handoffs, pipelines de agentes secuenciales, control de flujo, tools, streaming, escalado a producción, y coordinación entre agentes. Activar para: definición de agentes, handoff system, tool calling, streaming responses, guardrails, multi-agent orchestration, security limits, y patrones pipeline."
license: Complete terms in LICENSE.txt
---

# OpenAI Agents SDK - Orquestación Multi-Agente

## Visión General

El SDK de agentes de OpenAI (@openai/agents) es un framework TypeScript para construir sistemas multi-agente escalables con control de flujo explícito, handoffs nativos y herramientas integradas. Ideal para orquestación compleja donde múltiples agentes especializados colaboran en tareas.

**Casos de uso principales:**
- Sistemas de soporte multi-tier (triage → especialista → escalado)
- Pipelines de procesamiento de documentos
- Análisis complejos con agentes en serie
- Orquestación de servicios especializados
- Agentic workflows con control de flujo determinístico

---

## Instalación y Setup

### Dependencias

```bash
npm install @openai/agents openai zod
npm install -D typescript @types/node ts-node
```

### Configuración Inicial

```typescript
import Anthropic from "@openai/agents";

const client = new Anthropic({
  apiKey: process.env.OPENAI_API_KEY,
});
```

### Estructura de Proyecto

```
src/
├── agents/
│   ├── triage-agent.ts         # Agente de triaje
│   ├── specialist-agent.ts     # Agentes especializados
│   └── escalation-agent.ts     # Agente de escalado
├── tools/
│   ├── ticket-tools.ts         # Herramientas de tickets
│   ├── knowledge-tools.ts      # Acceso a KB
│   └── escalation-tools.ts     # Escalado
├── orchestration.ts            # Orquestador principal
└── types.ts                    # Esquemas compartidos
```

---

## Definición de Agentes

### Estructura Base

Un agente se define con:
- **name**: Identificador único
- **instructions**: Directivas de comportamiento
- **model**: Modelo LLM (gpt-4o, gpt-4-turbo)
- **tools**: Herramientas disponibles
- **handoff**: Habilidad de transferir a otro agente

```typescript
import { Agent } from "@openai/agents";
import { z } from "zod";

const triageAgent = new Agent({
  name: "triage",
  model: "gpt-4o",
  instructions: `Eres un agente de triaje de soporte técnico.
Tu responsabilidad es:
1. Entender el problema del cliente
2. Categorizar la urgencia (critical, high, medium, low)
3. Determinar el tipo de problema (billing, technical, account, other)
4. Transferir al agente especializado correcto

IMPORTANTE: Siempre completa triage completo antes de handoff.`,
  tools: [
    {
      type: "function",
      function: {
        name: "categorize_issue",
        description: "Categoriza un ticket por urgencia y tipo",
        parameters: {
          type: "object",
          properties: {
            urgency: {
              type: "string",
              enum: ["critical", "high", "medium", "low"],
            },
            category: {
              type: "string",
              enum: ["billing", "technical", "account", "other"],
            },
            summary: { type: "string" },
          },
          required: ["urgency", "category", "summary"],
        },
      },
    },
  ],
});
```

---

## Tipos de Agentes

### 1. Conversation Agent (Conversacional)

Mantiene diálogo con usuario, sin transferencias automáticas:

```typescript
const conversationAgent = new Agent({
  name: "chat",
  model: "gpt-4o",
  instructions: `Eres un asistente conversacional amable.
Responde preguntas y ayuda con información general.`,
  type: "conversation",
});
```

### 2. Post-Process Agent

Procesa y refina resultados de otros agentes:

```typescript
const postProcessAgent = new Agent({
  name: "formatter",
  model: "gpt-4o",
  instructions: `Eres un agente de post-procesamiento.
Tomas output de otros agentes y lo formatea para presentación final.`,
  type: "post_process",
});
```

### 3. Escalation Agent

Maneja escalaciones y casos especiales:

```typescript
const escalationAgent = new Agent({
  name: "escalation",
  model: "gpt-4o",
  instructions: `Eres especialista en escalaciones.
Maneja casos críticos, contacta a supervisores, y documenta problemas complejos.`,
  type: "escalation",
});
```

### 4. Pipeline Agent

Ejecuta como parte de secuencia determinística:

```typescript
const pipelineAgentA = new Agent({
  name: "pipeline_a",
  model: "gpt-4o",
  instructions: `Primera fase del pipeline.`,
  type: "pipeline",
});
```

---

## Sistema de Handoffs

### Handoff Nativo - Transferencia Explícita

```typescript
const specialistAgent = new Agent({
  name: "billing_specialist",
  model: "gpt-4o",
  instructions: `Eres especialista en facturación.
Resuelve problemas de billing. Si es técnico, transfiere a tech_specialist.`,
  tools: [
    {
      type: "function",
      function: {
        name: "handoff_to_technical",
        description: "Transfiere a especialista técnico",
        parameters: {
          type: "object",
          properties: {
            reason: {
              type: "string",
              description: "Razón del handoff",
            },
            context: {
              type: "object",
              description: "Context para el siguiente agente",
            },
          },
          required: ["reason", "context"],
        },
      },
    },
  ],
});
```

### HandoffContext - Contexto Estructurado

```typescript
interface HandoffContext {
  source_agent: string;
  target_agent: string;
  reason: string;
  data: {
    ticket_id: string;
    issue_summary: string;
    urgency: string;
    customer_name: string;
    previous_attempts: string[];
  };
  timestamp: string;
}

// En handler:
const handoffContext: HandoffContext = {
  source_agent: "triage",
  target_agent: "billing_specialist",
  reason: "Issue is billing-related after categorization",
  data: {
    ticket_id: "TKT-12345",
    issue_summary: "Customer charged twice",
    urgency: "critical",
    customer_name: "John Doe",
    previous_attempts: [],
  },
  timestamp: new Date().toISOString(),
};
```

### PipelineContext - Estado Compartido en Pipeline

```typescript
interface PipelineContext {
  stage: number;
  input: any;
  output: any;
  state: {
    [key: string]: any;
  };
  errors: string[];
}

const pipelineContext: PipelineContext = {
  stage: 1,
  input: documentRaw,
  output: null,
  state: {
    extracted_text: "",
    entities: [],
    sentiment: "",
  },
  errors: [],
};
```

### TaskContext - Contexto de Tarea Individual

```typescript
interface TaskContext {
  task_id: string;
  agent_name: string;
  instruction: string;
  tools: string[];
  state: Record<string, any>;
  parent_context?: TaskContext;
}
```

---

## Tool Calling

### Definición con Zod

```typescript
import { z } from "zod";

const TicketToolSchema = z.object({
  ticket_id: z.string().describe("ID del ticket"),
  action: z
    .enum(["create", "update", "close", "escalate"])
    .describe("Acción a realizar"),
  details: z.object({
    title: z.string(),
    description: z.string(),
    priority: z.enum(["low", "medium", "high", "critical"]),
  }),
});

const ticketTool = {
  type: "function" as const,
  function: {
    name: "manage_ticket",
    description: "Crear, actualizar, cerrar o escalar tickets",
    parameters: TicketToolSchema.parseSync({}),
  },
};
```

### Ejecución de Tools

```typescript
async function executeToolCall(
  toolName: string,
  toolInput: Record<string, any>
): Promise<string> {
  switch (toolName) {
    case "manage_ticket":
      const ticketData = TicketToolSchema.parse(toolInput);
      // Llamar API o DB
      const result = await db.tickets.update(ticketData);
      return JSON.stringify(result);

    case "escalate_ticket":
      await notificationService.notifySupervisor(toolInput);
      return "Ticket escalado a supervisor";

    default:
      throw new Error(`Unknown tool: ${toolName}`);
  }
}
```

### Tool Results

```typescript
interface ToolResult {
  type: "tool_result";
  tool_use_id: string;
  content: string;
  is_error?: boolean;
}

const toolResult: ToolResult = {
  type: "tool_result",
  tool_use_id: "call_abc123",
  content: JSON.stringify({
    ticket_id: "TKT-12345",
    status: "escalated",
    timestamp: new Date().toISOString(),
  }),
  is_error: false,
};
```

---

## Streaming

### Async Generators

```typescript
async function* streamAgentResponse(
  agent: Agent,
  messages: any[]
): AsyncGenerator<StreamEvent> {
  const stream = await client.agents.stream({
    agent_id: agent.name,
    messages: messages,
  });

  for await (const event of stream) {
    yield event;
  }
}
```

### Text Delta Events

```typescript
async function handleTextStreaming(agentMessages: any[]) {
  for await (const event of streamAgentResponse(triageAgent, agentMessages)) {
    if (event.type === "content_block_delta") {
      if (event.delta.type === "text_delta") {
        process.stdout.write(event.delta.text);
        // Renderizar en real-time
      }
    }
  }
}
```

### Tool Call Events

```typescript
async function handleToolCalls(agentMessages: any[]) {
  for await (const event of streamAgentResponse(specialistAgent, agentMessages)) {
    if (event.type === "content_block_start") {
      if (event.content_block.type === "tool_use") {
        console.log(`[Tool] Calling ${event.content_block.name}`);
      }
    }

    if (event.type === "content_block_delta") {
      if (event.delta.type === "input_json_delta") {
        // Stream JSON de parámetros del tool
        console.log(event.delta.partial_json);
      }
    }
  }
}
```

---

## Runner

### Función run()

Ejecución única, sin streaming:

```typescript
async function runAgent(
  agent: Agent,
  userMessage: string,
  context: Record<string, any> = {}
): Promise<string> {
  const messages = [
    {
      role: "user",
      content: userMessage,
    },
  ];

  // Pasar contexto como message del sistema
  if (Object.keys(context).length > 0) {
    messages.unshift({
      role: "user",
      content: `Context: ${JSON.stringify(context)}`,
    });
  }

  const response = await client.agents.run({
    agent_id: agent.name,
    messages: messages,
    max_turns: 10,
  });

  return response.messages[response.messages.length - 1].content;
}
```

### Función streamRun()

Ejecución con streaming:

```typescript
async function streamRunAgent(
  agent: Agent,
  userMessage: string
): Promise<void> {
  const messages = [
    {
      role: "user",
      content: userMessage,
    },
  ];

  const stream = await client.agents.streamRun({
    agent_id: agent.name,
    messages: messages,
    max_turns: 10,
  });

  for await (const event of stream) {
    switch (event.type) {
      case "message_start":
        console.log(`\n[${event.message.role}]`);
        break;

      case "content_block_delta":
        if (event.delta.type === "text_delta") {
          process.stdout.write(event.delta.text);
        }
        break;

      case "message_stop":
        console.log("\n");
        break;
    }
  }
}
```

---

## Guardrails

### Input Validation

```typescript
async function validateInput(
  input: string,
  maxLength: number = 10000
): Promise<boolean> {
  if (!input || input.trim().length === 0) {
    throw new Error("Input cannot be empty");
  }

  if (input.length > maxLength) {
    throw new Error(`Input exceeds maximum length of ${maxLength}`);
  }

  // Detectar contenido peligroso
  const dangerousPatterns = [
    /DROP\s+TABLE/i,
    /DELETE\s+FROM/i,
    /<script/i,
  ];

  for (const pattern of dangerousPatterns) {
    if (pattern.test(input)) {
      throw new Error("Input contains potentially dangerous content");
    }
  }

  return true;
}
```

### Output Validation

```typescript
async function validateOutput(
  output: string,
  agent: Agent
): Promise<string> {
  // Verificar formato JSON si es esperado
  if (agent.name.includes("json")) {
    try {
      JSON.parse(output);
    } catch {
      throw new Error("Output is not valid JSON");
    }
  }

  // Remover datos sensibles
  const sanitized = output
    .replace(/\b\d{16}\b/g, "[REDACTED_CC]")
    .replace(/\b\d{3}-\d{2}-\d{4}\b/g, "[REDACTED_SSN]");

  return sanitized;
}
```

---

## Variables de Contexto

### Passing State Between Agents

```typescript
class AgentOrchestrator {
  private context: Map<string, any> = new Map();

  setContextVariable(key: string, value: any): void {
    this.context.set(key, value);
  }

  getContextVariable(key: string): any {
    return this.context.get(key);
  }

  async transferWithContext(
    fromAgent: Agent,
    toAgent: Agent,
    data: any
  ): Promise<void> {
    // Guardar contexto
    this.setContextVariable("transfer_data", data);
    this.setContextVariable("source_agent", fromAgent.name);
    this.setContextVariable("target_agent", toAgent.name);

    // Pasar en el mensaje
    const contextMessage = `
Previous context from ${fromAgent.name}:
${JSON.stringify(data, null, 2)}

Continue with this context in mind.`;

    // Ejecutar agente siguiente
    await runAgent(toAgent, contextMessage, this.context as any);
  }
}
```

---

## Control de Flujo

### Retain

Agente continúa la conversación:

```typescript
interface RetainInstruction {
  type: "retain";
  reason: string;
}

// Implementar en instructions del agente:
const retainAgent = new Agent({
  name: "followup",
  instructions: `Si el usuario dice "continue", responde manteniendo el tema.
No transfiera a otro agente.`,
});
```

### Relinquish to Parent

Devolver control al agente padre:

```typescript
interface RelinquishParent {
  type: "relinquish_to_parent";
  result: any;
}

const childAgent = new Agent({
  name: "child_agent",
  instructions: `Completa tu tarea específica.
Si necesitas validación, pasa result al agente padre.`,
  tools: [
    {
      type: "function",
      function: {
        name: "relinquish_to_parent",
        description: "Devolver control al agente padre",
        parameters: {
          type: "object",
          properties: {
            result: { type: "object" },
            status: { type: "string" },
          },
        },
      },
    },
  ],
});
```

### Relinquish to Start

Reiniciar desde el inicio:

```typescript
const restartAgent = new Agent({
  name: "restart_handler",
  instructions: `Si detectas error crítico, reinicia todo desde triage.
Usa relinquish_to_start.`,
  tools: [
    {
      type: "function",
      function: {
        name: "relinquish_to_start",
        description: "Reinicia el flujo desde el agente inicial",
        parameters: {
          type: "object",
          properties: {
            reason: { type: "string" },
          },
        },
      },
    },
  ],
});
```

---

## Orquestación Multi-Agente

### Stack-Based Turn Loop Pattern

```typescript
class StackBasedOrchestrator {
  private agentStack: Agent[] = [];
  private messageHistory: any[] = [];
  private maxTurns = 50;
  private turnCount = 0;

  async execute(
    initialAgent: Agent,
    userMessage: string
  ): Promise<string> {
    this.agentStack = [initialAgent];
    this.messageHistory = [{ role: "user", content: userMessage }];

    while (this.agentStack.length > 0 && this.turnCount < this.maxTurns) {
      const currentAgent = this.agentStack[this.agentStack.length - 1];
      this.turnCount++;

      console.log(
        `\n[Turn ${this.turnCount}] Agent: ${currentAgent.name}`
      );

      const response = await client.agents.run({
        agent_id: currentAgent.name,
        messages: this.messageHistory,
        max_turns: 1,
      });

      this.messageHistory.push(...response.messages);

      // Procesar handoff si existe
      const lastMessage = response.messages[response.messages.length - 1];
      if (this.isHandoffMessage(lastMessage)) {
        const nextAgent = this.parseHandoff(lastMessage);
        this.agentStack.push(nextAgent);
      } else {
        // Sin handoff, pop agent
        this.agentStack.pop();
      }
    }

    const finalMessage = this.messageHistory[
      this.messageHistory.length - 1
    ] as any;
    return finalMessage.content;
  }

  private isHandoffMessage(message: any): boolean {
    return message.content.includes("HANDOFF:");
  }

  private parseHandoff(message: any): Agent {
    // Parsear qué agente de la stack
    const match = message.content.match(/HANDOFF:(\w+)/);
    return this.getAgentByName(match?.[1] || "default");
  }

  private getAgentByName(name: string): Agent {
    // Retornar agente de registro
    return new Agent({ name });
  }
}
```

---

## Security Limits

### Max Turns

```typescript
const LIMITED_AGENT = new Agent({
  name: "limited",
  model: "gpt-4o",
  instructions: "Procesa rápido sin loops",
});

async function runWithMaxTurns(agent: Agent, maxTurns: number = 5) {
  const response = await client.agents.run({
    agent_id: agent.name,
    messages: [{ role: "user", content: "Tu tarea" }],
    max_turns: maxTurns, // LÍMITE DURO
  });

  if (response.messages.length >= maxTurns) {
    console.warn("Agent hit max turns limit!");
  }

  return response;
}
```

### Agent Transfer Counters

```typescript
class TransferCounterManager {
  private transferCounts: Map<string, number> = new Map();
  private maxTransfersPerSession = 10;

  canTransfer(agentName: string): boolean {
    const count = this.transferCounts.get(agentName) || 0;
    return count < this.maxTransfersPerSession;
  }

  recordTransfer(fromAgent: string, toAgent: string): void {
    const count = this.transferCounts.get(fromAgent) || 0;
    this.transferCounts.set(fromAgent, count + 1);

    if (count >= this.maxTransfersPerSession) {
      throw new Error(
        `Agent ${fromAgent} exceeded max transfers. Escalating to human.`
      );
    }
  }

  reset(): void {
    this.transferCounts.clear();
  }
}
```

---

## Pipeline Pattern

### 3-Agent Sequential Pipeline

```typescript
const docExtractorAgent = new Agent({
  name: "doc_extractor",
  model: "gpt-4o",
  instructions: "Extrae texto y estructura del documento.",
});

const contentAnalyzerAgent = new Agent({
  name: "content_analyzer",
  model: "gpt-4o",
  instructions: "Analiza contenido extraído y extrae entidades.",
});

const reportGeneratorAgent = new Agent({
  name: "report_generator",
  model: "gpt-4o",
  instructions: "Genera reporte final con hallazgos.",
});

async function executePipeline(
  documentContent: string
): Promise<PipelineContext> {
  const context: PipelineContext = {
    stage: 1,
    input: documentContent,
    output: null,
    state: {},
    errors: [],
  };

  try {
    // Stage 1: Extract
    const extractResult = await runAgent(
      docExtractorAgent,
      `Procesa este documento: ${documentContent}`,
      context
    );
    context.state.extracted_text = extractResult;
    context.stage = 2;

    // Stage 2: Analyze
    const analyzeResult = await runAgent(
      contentAnalyzerAgent,
      `Analiza este contenido: ${extractResult}`,
      context
    );
    context.state.analysis = analyzeResult;
    context.stage = 3;

    // Stage 3: Report
    const reportResult = await runAgent(
      reportGeneratorAgent,
      `Genera reporte basado en: ${analyzeResult}`,
      context
    );
    context.output = reportResult;
    context.stage = 4;

    return context;
  } catch (error) {
    context.errors.push((error as Error).message);
    throw error;
  }
}
```

---

## Ejemplo Completo: Sistema de Soporte Multi-Tier

```typescript
// 1. Definir agentes
const triageAgent = new Agent({
  name: "triage_support",
  model: "gpt-4o",
  instructions: "Categoriza tickets y realiza handoff.",
  tools: [/* categorize tool */],
});

const billingAgent = new Agent({
  name: "billing_support",
  model: "gpt-4o",
  instructions: "Resuelve problemas de facturación.",
});

const techAgent = new Agent({
  name: "tech_support",
  model: "gpt-4o",
  instructions: "Resuelve problemas técnicos.",
});

// 2. Orquestación
const orchestrator = new StackBasedOrchestrator();

// 3. Ejecutar
const supportTicket = "My subscription was charged twice!";
const result = await orchestrator.execute(triageAgent, supportTicket);

console.log("Resolution:", result);
```

---

## Integración con Vercel AI SDK

### Adapter Pattern

```typescript
import { generateObject } from "ai";
import { z } from "zod";

async function integratWithVercelAI() {
  // Usar modelo de OpenAI Agent
  const result = await generateObject({
    model: openai("gpt-4o"),
    schema: z.object({
      category: z.string(),
      urgency: z.string(),
      recommendation: z.string(),
    }),
    prompt: "Categoriza este ticket de soporte",
  });

  // Pasar a agente para procesamiento
  const agentResponse = await runAgent(triageAgent, JSON.stringify(result));
  return agentResponse;
}
```

---

## Comparación: @openai/agents vs Alternativas

| Aspecto | @openai/agents | LangChain | CrewAI | AutoGen |
|--------|---|---|---|---|
| **Setup** | Mínimo | Extenso | Moderado | Complejo |
| **Handoffs** | Nativo | Via tools | Via delegation | Built-in |
| **Type-safety** | Excelente | Débil | Débil | Débil |
| **Streaming** | Nativo | Manual | No | Limitado |
| **Control flujo** | Explícito | Implícito | Implícito | Explícito |
| **Max turns** | Configurable | N/A | N/A | Configurable |
| **Curva aprendizaje** | Baja | Alta | Media | Alta |
| **Escalabilidad** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Producción ready** | Sí | Sí | Parcialmente | Sí |
| **Costo** | Bajo | Bajo | Bajo | Bajo |
| **Community** | Creciente | Grande | Creciente | Grande |

---

## Best Practices

1. **Always validate inputs**: Guardrails en cada punto de entrada
2. **Limit turns aggressively**: Max 10-15 por sesión
3. **Log everything**: Auditoría completa de handoffs
4. **Type-safe tools**: Siempre usar Zod schemas
5. **Stream for UX**: Mejor experiencia con streaming
6. **Test handoffs**: Verify transfer logic antes de deploy
7. **Monitor costs**: Contar turns y tokens por agente
8. **Human escalation**: Siempre una salida a humano

---

## Recursos Oficiales

- [OpenAI Agents Documentation](https://platform.openai.com/docs/guides/agents)
- [TypeScript SDK Reference](https://github.com/openai/openai-node)
- [Zod Schema Validation](https://zod.dev/)
- [Agent Best Practices](https://platform.openai.com/docs/guides/agent-design)

