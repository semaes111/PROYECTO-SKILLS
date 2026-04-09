---
name: Orquestación Multi-Agente - Patrones Avanzados
description: Patrones técnicos completos para sistemas multi-agente en producción, incluyendo arquitecturas, mecanismos de handoff, gestión de estado y comparativas de frameworks
triggers:
  - "multi-agente"
  - "orquestación de agentes"
  - "arquitectura de agentes"
  - "handoff entre agentes"
  - "patrones de coordinación"
  - "SDK handoff"
  - "agentes especializados"
tags:
  - agents
  - orchestration
  - architecture
  - sdk
  - advanced
---

# Orquestación Multi-Agente: Patrones y Arquitecturas Avanzadas

## 1. INTRODUCCIÓN: SISTEMAS MULTI-AGENTE VS MONOAGENTE

### Por qué sistemas multi-agente?

**Descomposición de complejidad**: Cada agente maneja un dominio específico, evitando que un único modelo maneje todas las tareas.

**Escalabilidad**: Agregar especialistas nuevos sin modificar agentes existentes (Open/Closed Principle).

**Resiliencia**: Si un agente falla, otros pueden retomar. Colas de escalamiento gracioso.

**Paralelización**: Agentes independientes pueden ejecutarse concurrentemente (Hub-and-Spoke).

**Mejora de tokens**: Agentes pequeños y enfocados usan menos tokens que prompts monolíticos.

---

## 2. PATRONES ARQUITECTÓNICOS FUNDAMENTALES

### Patrón 1: Stack-Based Turn Loop (Pila de Turnos)

```
Usuario → Agente Inicial
        ↓ (procesa, genera respuesta)
        ↓ (decide handoff)
    Agente B (toma control)
        ↓ (continúa contexto)
    Agente C (si es necesario)
        ↓
    Retorna al Usuario
```

**Características**:
- Cada agente completa su trabajo, luego cede control
- Contexto se acumula en conversation_history
- FIFO o stack ordering de turnos

**Ventaja**: Simple, determinista, fácil de debuggear.

**Desventaja**: No paralelo, latencia acumulativa.

### Patrón 2: Hub-and-Spoke (Centro y Radios)

```
           [Coordinador Central]
                    ↓
    ┌───────────────┼───────────────┐
    ↓               ↓               ↓
[Especialista   [Especialista   [Especialista
 Búsqueda]      Análisis]        Síntesis]
```

**Características**:
- Un coordinador central orquesta múltiples especialistas
- Coordinador mantiene estado global y reglas de despacho
- Especialistas son stateless o semi-stateless

**Ventaja**: Paralelizable, escalable, clara separación de responsabilidades.

**Desventaja**: Cuello de botella en coordinador, mayor complejidad.

### Patrón 3: Pipeline/Sequential (Tubería Secuencial)

```
[Input] → [Agente A: Limpieza] → [Agente B: Enriquecimiento] 
       → [Agente C: Validación] → [Output]
```

**Características**:
- Cada agente transforma output del anterior
- PipelineStateManager gestiona handoffs
- pipelineData estructura porta datos entre etapas

**Ventaja**: Clara progresión, reutilizable, predecible.

**Desventaja**: Rígido, difícil cambiar orden dinámicamente.

### Patrón 4: Hierarchical (Jerárquico)

```
         [Agente Manager]
            ↙          ↖
     [Worker A]      [Worker B]
       ↙   ↖          ↙   ↖
    [Task] [Task]  [Task] [Task]
```

**Características**:
- Manager delega a workers específicos
- Workers reportan progreso/éxito
- Manager reintenta, escala o reasigna

**Ventaja**: Control fino, reintentos, rebalanceo de carga.

**Desventaja**: Overhead comunicacional, mayor latencia.

---

## 3. TIPOS Y ROLES DE AGENTES

| Tipo | Rol | Cuando usar | Ejemplo |
|------|-----|------------|---------|
| **conversation** | User-facing, interactivo, mantiene diálogo | Interfaz principal con usuario | Agente de servicio al cliente |
| **post_process** | Corre tras agente principal, interno | Validación, formateo, guardar | Agente que limpia respuestas JSON |
| **escalation** | Maneja errores y edge cases | Recuperación de fallos | Agente que detecta consultas fuera de scope |
| **pipeline** | Ejecución secuencial determinista | Transformaciones en cadena | Agente de investigación → borrador → revisión |
| **specialist** | Dominio muy específico (Hub) | Tareas focalizadas en coordinador | Experto en análisis financiero |

---

## 4. MECANISMOS DE HANDOFF

### Handoff Nativo: `handoff()` API

```python
# Agente Actual cede control a Siguiente
result = await handoff(
    agent="specialist_agent",
    context=HandoffContext(
        conversation_history=messages,
        metadata={
            "escalation_reason": "requires_expert_analysis",
            "confidence": 0.45,
            "domain": "financial_regulation"
        }
    )
)
```

**Estructura de HandoffContext**:
```typescript
interface HandoffContext {
  conversation_history: Message[];
  metadata?: Record<string, unknown>;
  execution_state?: ExecutionState;
  user_id?: string;
  session_id?: string;
}
```

### Handoff Manual: Synthetic Transfer Messages

Para frameworks sin SDK nativo, simular:

```json
{
  "type": "transfer_to_agent",
  "target_agent": "financial_analyst",
  "payload": {
    "analysis_request": "quarterly_variance",
    "data": {...},
    "prior_context": "conversation_history"
  }
}
```

### Context Passing: Tres Estrategias

1. **ConversationContext**: Acumula todo (risgo de context explosion)
2. **PipelineContext**: Solo datos actuales + metadata (limpio)
3. **TaskContext**: Mini-contexto funcional (minimalista)

---

## 5. PATRONES DE FLUJO DE CONTROL

### `retain`: Agente mantiene control

```python
# Agente completa tarea, usuario responde, continúa mismo agente
agent.control_flow = ControlFlow.RETAIN
# Útil para conversaciones multi-turno
```

### `relinquish_to_parent`: Retorna a agente que lo llamó

```python
# Especialista termina, vuelve a Coordinador
agent.control_flow = ControlFlow.RELINQUISH_TO_PARENT
```

### `relinquish_to_start`: Retorna al primer agente

```python
# Pipeline termina, resultado vuelve a entrada
agent.control_flow = ControlFlow.RELINQUISH_TO_START
```

---

## 6. LÍMITES DE SEGURIDAD

| Límite | Valor Típico | Propósito | Cómo Aplicar |
|--------|--------------|----------|-------------|
| **Max Turnos por Conversación** | 25 | Evitar infinite loops usuario-agente | `conversation.max_turns = 25` |
| **Max SDK Turnos por Ejecución** | 25 | Límite de handoffs internos | `execution.max_sdk_turns = 25` |
| **AgentTransferCounter** | + | Tracking recursión de handoffs | Incrementar en cada `handoff()` |
| **maxCallsPerParentAgent** | Configurable | Evitar llamadas infinitas al padre | `parent.max_children_calls = 10` |

**Implementación de contador**:

```python
class AgentTransferTracker:
    def __init__(self, max_transfers=25):
        self.max_transfers = max_transfers
        self.current_count = 0
    
    def before_handoff(self, target_agent):
        self.current_count += 1
        if self.current_count > self.max_transfers:
            raise TransferLimitExceeded(
                f"Exceeded {self.max_transfers} handoffs"
            )
```

---

## 7. GESTIÓN DE ESTADO ENTRE AGENTES

### PipelineStateManager (Recomendado para Pipelines)

```python
class PipelineStateManager:
    def __init__(self):
        self.stages = {}
        self.current_stage = 0
    
    def forward_to_next(self, stage_name, result):
        self.stages[stage_name] = result
        self.current_stage += 1
        return self.stages[stage_name]
```

### pipelineData: Estructura Portadora

```typescript
interface PipelineData {
  stage: string;
  input: unknown;
  output: unknown;
  metadata: {
    timestamp: number;
    source_agent: string;
    target_agent: string;
    error?: string;
  };
}
```

### Acumulación de Conversation History

```python
# Cada handoff suma a history, NO reemplaza
history.append({
    "agent": "current_agent_name",
    "timestamp": now(),
    "messages": agent_output,
    "transfer_reason": transfer_metadata
})
```

**CUIDADO**: Historia sin límite = context explosion. Implementar ventanas deslizantes.

---

## 8. STREAMING EN MULTI-AGENTE

Rendimiento crítico: no esperar a que agente A termine para mostrar al usuario.

```python
async def orchestrator_with_streaming():
    async for event in agent_a.stream():
        if event.type == "text_delta":
            yield event  # Forward al usuario en tiempo real
        elif event.type == "tool_use":
            await trigger_parallel_agents(event)
```

---

## 9. MANEJO DE ERRORES

### Patrón: Fallback Gracioso

```python
async def call_specialist_with_fallback(query):
    try:
        return await specialist_agent(query)
    except TimeoutError:
        logger.warning("Specialist timed out, using general fallback")
        return await general_agent(query)
    except Exception as e:
        logger.error(f"Specialist failed: {e}")
        return await escalation_agent(query)
```

### Timeout Handling

```python
result = await asyncio.wait_for(
    agent_call(data),
    timeout=30.0  # segundos
)
# Si timeout, escalación automática
```

---

## 10. EJEMPLOS DE CÓDIGO

### Ejemplo 1: Handoff Básico (2 Agentes)

```python
# Agente 1: Customer Service
async def customer_service_agent(message: str):
    if "refund" in message.lower():
        return await handoff(
            agent="billing_specialist",
            context=HandoffContext(
                conversation_history=[{"role": "user", "content": message}],
                metadata={"issue_type": "refund"}
            )
        )
    return "Consulta respondida por CS"

# Agente 2: Specialist
async def billing_specialist(context: HandoffContext):
    return "Revisando política de reembolsos..." + str(context.metadata)
```

### Ejemplo 2: Pipeline de 3 Agentes

```python
async def research_draft_review_pipeline(topic: str):
    state = PipelineStateManager()
    
    # Stage 1: Research
    research_result = await research_agent(topic)
    state.forward_to_next("research", research_result)
    
    # Stage 2: Draft (input = output of research)
    draft_result = await draft_agent(research_result)
    state.forward_to_next("draft", draft_result)
    
    # Stage 3: Review (input = output of draft)
    final = await review_agent(draft_result)
    state.forward_to_next("review", final)
    
    return final
```

### Ejemplo 3: Hub Coordinator (4 Especialistas)

```python
class CoordinatorHub:
    def __init__(self):
        self.specialists = {
            "search": SearchAgent(),
            "analysis": AnalysisAgent(),
            "synthesis": SynthesisAgent(),
            "formatting": FormattingAgent()
        }
    
    async def orchestrate(self, request: str):
        # Despacho paralelo
        search_task = self.specialists["search"](request)
        analysis_task = self.specialists["analysis"](request)
        
        search_result, analysis_result = await asyncio.gather(
            search_task, analysis_task
        )
        
        # Síntesis secuencial
        synthesis = await self.specialists["synthesis"](
            search_result, analysis_result
        )
        
        # Formateo final
        final = await self.specialists["formatting"](synthesis)
        return final
```

### Ejemplo 4: Patrón de Escalación

```python
async def escalation_pattern(user_input: str):
    try:
        result = await tier1_agent(user_input)
        if result.get("confidence", 1.0) < 0.5:
            raise LowConfidenceError("Need expert review")
        return result
    except LowConfidenceError:
        logger.info("Escalating to Tier 2 expert")
        return await tier2_agent(user_input)
    except Exception:
        logger.error("Critical error, human intervention")
        return await human_review_queue(user_input)
```

### Ejemplo 5: Streaming Multi-Agente

```python
async def streaming_orchestrator():
    # Agente 1 con streaming
    async for chunk in research_agent.stream():
        if isinstance(chunk, TextDelta):
            yield {"type": "research_update", "data": chunk.text}
    
    # Agente 2 usa output de Agente 1
    async for chunk in synthesis_agent.stream():
        yield {"type": "synthesis_update", "data": chunk.text}
```

---

## 11. COMPARATIVA DE FRAMEWORKS

| Framework | Paradigma | SDK Handoff | Paralelismo | Curva | Production-Ready |
|-----------|-----------|------------|----------|-------|-----------------|
| **OpenAI Agents SDK** | Nativo | Sí | Limitado | Baja | Sí |
| **LangGraph** | DAG + StateMachine | Manual | Excelente | Media | Sí |
| **CrewAI** | Role-Based | Implícito | Bueno | Media | Beta |
| **AutoGen** | Conversation-Based | Automático | Limitado | Alta | Sí |
| **Mastra** | Lightweight | Sí (nuevo) | Bueno | Muy baja | Beta |
| **Rowboat** | Specialized | Propio | Medio | Alta | Limited |

**Recomendación**: OpenAI SDK para simplicidad, LangGraph para máxima control.

---

## 12. ANTI-PATRONES COMUNES

### ❌ Anti-Patrón 1: Infinite Loop de Handoffs

```python
# MAL: Agente A → B → A → B (nunca termina)
if not solved:
    await handoff("other_agent")
```

**Solución**: AgentTransferCounter con límite.

### ❌ Anti-Patrón 2: Context Explosion

```python
# MAL: Acumular todo sin límite
context.history.append(all_messages)  # 1M de mensajes
```

**Solución**: Ventana deslizante (últimos 50 mensajes).

### ❌ Anti-Patrón 3: Ownership Ambiguo

```python
# MAL: Tres agentes pueden modificar estado
state.data = new_value  # ¿Quién es responsable?
```

**Solución**: Un agente = un estado, otros leen solo.

### ❌ Anti-Patrón 4: Handoff sin Contexto

```python
# MAL: Pasar nada
await handoff("expert_agent")  # Expert no sabe qué hacer
```

**Solución**: Siempre pasar HandoffContext completo.

---

## 13. MATRIZ DE DECISIÓN

### Cuándo usar cada patrón:

**Stack-Based**: 
- ✓ Conversación simple customer service
- ✓ 2-3 agentes secuenciales
- ✗ Paralelismo requerido

**Hub-and-Spoke**: 
- ✓ Análisis paralelo de múltiples sources
- ✓ Problema muy grande que descompone bien
- ✗ Overhead de coordinador tolerable

**Pipeline**: 
- ✓ ETL, procesamiento datos secuencial
- ✓ Orden fijo de transformaciones
- ✗ Lógica condicional compleja

**Hierarchical**: 
- ✓ Reintentos y rebalanceo necesario
- ✓ Control fino de delegación
- ✗ Latencia crítica

---

## 14. CHECKLIST PARA PRODUCCIÓN

- [ ] AgentTransferCounter implementado
- [ ] Context history con límite (max 100 turnos)
- [ ] Timeouts en todos los handoffs (30s default)
- [ ] Escalación graceful a agente de fallback
- [ ] Logging de transfer_reason en cada handoff
- [ ] Tests de max_turns limit
- [ ] Monitoreo de latencia por agente
- [ ] Circuit breaker si agente falla >3 veces
- [ ] Streaming configurado si latencia <1s crítica
- [ ] Documentación de ownership de estado por agente

---

## 15. RECURSOS Y REFERENCIAS

- OpenAI Agents SDK Documentation
- LangGraph: State Management Patterns
- Anthropic Claude API: Handoff Specification
- CrewAI GitHub: Role-Based Architecture

---

**Versión**: 1.0  
**Última actualización**: 2026-04-09  
**Mantenedor**: PROYECTO-SKILLS  
**Nivel**: Avanzado / Producción
