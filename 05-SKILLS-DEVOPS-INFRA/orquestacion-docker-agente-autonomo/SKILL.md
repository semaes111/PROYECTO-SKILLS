---
name: docker-agent-orchestration
description: >
  Orquestacion Docker de agente autonomo con Claude Max OAuth ($0 API billing),
  motor ClaudeMaxRunner (subprocess claude --print), SmartRouter dual-speed
  (5ms heuristic + 3s LLM fallback), bucle agentico multi-turn de 10 acciones,
  memoria 3-capas (Redis/mem0/pgvector 768-dim nomic embeddings), VeracityCore
  control epistemico con deteccion de degradacion, Watcher audit trail completo,
  sandboxes de ejecucion de codigo (snekbox + Docker), bot Telegram, n8n workflows.
  11 servicios Docker, 100% self-hosted en VPS. Basado en CLAUDE-BRAIN v2.0
  (Python 3.12 + FastAPI + PostgreSQL 15 + Redis + LibreChat).
  Usar cuando el usuario mencione: agente autonomo, orquestacion Docker,
  multi-agente, Claude Max, $0 API, agentic loop, router inteligente,
  sandbox de codigo, bot Telegram con IA, sistema de agentes, agent orchestration,
  self-hosted agent, watcher, audit trail, control epistemico, veracity.
metadata:
  version: "2.0.0"
  source_repo: "https://github.com/semaes111/CLAUDE-BRAIN"
  category: agent-infrastructure
  python: ">=3.12"
triggers:
  - "agente autonomo"
  - "orquestacion Docker"
  - "Claude Max OAuth"
  - "agentic loop"
  - "multi-agente"
  - "self-hosted agent"
  - "docker agent"
  - "watcher audit"
  - "veracity control"
---

# Docker Agent Orchestration: CLAUDE-BRAIN Architecture

## Vision General

CLAUDE-BRAIN es un agente autonomo 100% Dockerizado que ejecuta Claude via Max OAuth (subscription, **$0 API extra**) en lugar de API keys de pago. El diseno se basa en 5 pilares:

1. **ClaudeMaxRunner** — Motor subprocess que invoca `claude --print` CLI
2. **SmartRouter** — Enrutamiento dual-speed: heuristico (<5ms) + LLM fallback (~3s)
3. **AgenticLoop** — Bucle multi-turn con 10 tipos de accion y deteccion de atascos
4. **VeracityCore** — Control epistemico en 3 niveles con deteccion de degradacion
5. **Watcher** — Audit trail completo a Supabase + Redis con metricas en tiempo real

```
                    ┌──────────────────────────────────────────────────────┐
                    │              CLAUDE-BRAIN Stack (Docker)              │
                    │                                                      │
                    │   ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
                    │   │ Web UI   │  │ Telegram  │  │  n8n Workflows   │  │
                    │   │ :3080    │  │  Bot      │  │  :5678           │  │
                    │   └────┬─────┘  └────┬─────┘  └────────┬─────────┘  │
                    │        │             │                  │            │
                    │   ┌────▼─────────────▼──────────────────▼─────────┐  │
                    │   │              FastAPI Agent API (:8000)        │  │
                    │   │  SmartRouter → AgenticLoop → ClaudeMaxRunner  │  │
                    │   │  + Mem0Manager + Watcher + VeracityCore       │  │
                    │   └──┬──────┬──────┬──────┬──────┬───────────────┘  │
                    │      │      │      │      │      │                  │
                    │  ┌───▼──┐┌──▼──┐┌──▼──┐┌──▼───┐┌─▼────┐            │
                    │  │Redis ││PG15 ││Embed││Snek- ││Sand- │            │
                    │  │:6379 ││:5432││:8080││box   ││box   │            │
                    │  │      ││pgvec││768d ││nsjail││Docker│            │
                    │  └──────┘└─────┘└─────┘└──────┘└──────┘            │
                    └──────────────────────────────────────────────────────┘
```

## Los 11 Servicios Docker

| Servicio | Imagen/Build | Puerto | Proposito |
|----------|-------------|--------|-----------|
| cb-agent | Build ./agent | 8000 | FastAPI principal: API, routing, loop, memoria |
| cb-webui | LibreChat | 3080 | Interfaz web de chat |
| cb-postgres | supabase/postgres:15.6.1 | 5432 | PostgreSQL + pgvector (768 dims) |
| cb-redis | redis:7-alpine | 6379 | Working memory (24h TTL) + metricas hot |
| cb-embeddings | ghcr.io/huggingface/tgi | 8080 | nomic-embed-text-v1.5 (768 dims, local, $0) |
| cb-snekbox | ghcr.io/python-discord/snekbox | — | Sandbox Python (nsjail, aislado) |
| cb-sandbox | Build ./sandbox | — | Sandbox Docker generico para code execution |
| cb-jupyter | Build ./jupyter | 8888 | IPython kernel con estado persistente |
| cb-n8n | n8n | 5678 | Workflow automation |
| cb-telegram | Build ./telegram | — | Bot Telegram como interfaz conversacional |
| cb-nginx | nginx | 80/443 | Reverse proxy + SSL termination |

## Modelo de Coste: $0 API

```
┌─────────────────────────────────────────────────────┐
│  CRITICO: NO usar ANTHROPIC_API_KEY                  │
│                                                      │
│  CLAUDE_CREDENTIALS_JSON = OAuth credentials         │
│  → claude CLI usa Max OAuth (incluido en suscripcion)│
│  → Sin ANTHROPIC_API_KEY → subprocess NO factura API │
│                                                      │
│  Coste mensual:                                      │
│  · Claude Max subscription: ~€200/mo                 │
│  · VPS (4 vCPU, 16GB RAM): €20-60/mo               │
│  · API extra: €0                                     │
│  · Embeddings: €0 (modelo local nomic)              │
└─────────────────────────────────────────────────────┘
```

## Componente 1: ClaudeMaxRunner

Motor que ejecuta Claude como subprocess, evitando la API de pago.

```python
class ClaudeMaxRunner:
    """Wrapper para claude --print CLI usando Max OAuth."""

    async def run(self, prompt, system_prompt=None, tools=None,
                  timeout=300, output_format="text") -> RunResult:
        cmd = ["claude", "--print"]
        if system_prompt:
            cmd += ["--system-prompt", system_prompt]
        if output_format:
            cmd += ["--output-format", output_format]
        if tools:
            for tool in tools:
                cmd += ["--allowedTools", tool]
        cmd += ["--max-turns", "1"]
        cmd.append(prompt)

        # CLAVE: sin ANTHROPIC_API_KEY en env → usa Max OAuth
        env = {
            "HOME": "/root",
            "PATH": "/usr/local/bin:/usr/bin:/bin",
            "CLAUDE_CONFIG_DIR": "/root/.claude",
        }

        proc = await asyncio.create_subprocess_exec(
            *cmd, stdout=PIPE, stderr=PIPE, env=env
        )
        stdout, stderr = await asyncio.wait_for(
            proc.communicate(), timeout=timeout
        )
        return RunResult(text=stdout.decode(), exit_code=proc.returncode)

    async def run_with_tools(self, prompt, system_prompt):
        """Ejecuta con herramientas builtin (Read, Write, Bash, etc.)"""
        tools = ["Read", "Write", "Edit", "Bash", "Glob", "Grep",
                 "WebSearch", "WebFetch", "TodoRead", "TodoWrite"]
        return await self.run(prompt, system_prompt, tools=tools)

    async def run_code_task(self, prompt, system_prompt):
        """Especializado para tareas de codigo."""
        return await self.run_with_tools(
            prompt, system_prompt, timeout=600
        )

    async def stream(self, prompt, system_prompt=None):
        """Streaming via stream-json format."""
        return await self.run(
            prompt, system_prompt, output_format="stream-json"
        )
```

**Herramientas builtin disponibles (sin coste extra):**
Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch, TodoRead, TodoWrite

## Componente 2: SmartRouter (Dual-Speed)

Enruta cada peticion al agente/skill optimo usando dos velocidades.

```python
class SmartRouter:
    """Routing dual: heuristico (<5ms) + LLM fallback (~3s)."""

    def __init__(self, runner: ClaudeMaxRunner, registry):
        self.runner = runner
        self.registry = registry
        self.rules = self._build_semantic_rules()  # 20+ reglas

    async def route(self, task: str) -> RouteDecision:
        # FAST PATH: reglas heuristicas (<5ms)
        decision = self._fast_route(task)
        if decision.confidence >= 0.7:
            return decision

        # LLM PATH: Claude analiza la tarea (~3s)
        agents = self.registry.list_agents()
        skills = self.registry.list_skills()
        prompt = f"Analyze task and pick best agent+skills:\n{task}"
        result = await self.runner.run(prompt, output_format="json")
        return RouteDecision.from_llm(result)

    def _fast_route(self, task: str) -> RouteDecision:
        """20+ reglas semanticas por keywords."""
        rules = {
            "code review|review code|PR review": ("code-reviewer", ["code-review"]),
            "debug|error|traceback|fix bug": ("debugger", ["code-review"]),
            "next.js|nextjs|app router": ("nextjs-developer", ["nextjs-supabase-dev"]),
            "database|sql|postgres|query": ("postgres-pro", ["nextjs-supabase-dev"]),
            "deploy|docker|ci/cd|pipeline": ("devops-engineer", ["github-ops"]),
            "n8n|workflow|automation": ("n8n-specialist", ["n8n-workflows"]),
            # ... 14+ reglas mas
        }
        for pattern, (agent, skills) in rules.items():
            if re.search(pattern, task, re.I):
                return RouteDecision(agent, skills, confidence=0.8, fast_path=True)
        return RouteDecision("general", [], confidence=0.3, fast_path=True)
```

**Output:** `RouteDecision(agent, skills, command, confidence, fast_path, reasoning)`

## Componente 3: AgenticLoop (Multi-Turn Engine)

Bucle autonomo que ejecuta tareas complejas en multiples turnos.

### 10 Tipos de Accion

| Accion | Descripcion | Executor |
|--------|-------------|----------|
| BASH | Ejecutar comando shell | subprocess |
| READ | Leer archivo (con lineas inicio/fin) | filesystem |
| WRITE | Crear/sobreescribir archivo | filesystem |
| EDIT | Modificar archivo in-place | filesystem |
| BROWSE | Navegacion web | Playwright |
| IPYTHON | Python en kernel con estado | Jupyter |
| THINK | Razonamiento interno (sin ejecucion) | — |
| FINISH | Completar tarea | — |
| REJECT | Rechazar tarea (con razon) | — |
| DELEGATE | Delegar a sub-agente | recursive |

### Ciclo del Loop

```python
class AgenticLoop:
    async def run(self, task, session_id, max_iterations=30):
        history = []
        stuck_detector = StuckDetector(window=6)
        condenser = ContextCondenser(max_chars=80_000, keep_steps=4)

        for i in range(max_iterations):
            # 1. Inyectar recalibracion epistemica cada 5 iteraciones
            if i > 0 and i % RECALIBRATE_EVERY == 0:
                history.append(RECALIBRATION_MESSAGE)

            # 2. Obtener respuesta de Claude
            response = await self.runner.run(
                system_prompt=VERSION_FULL + skill_context,
                prompt=self._build_prompt(task, history)
            )

            # 3. Parsear accion
            action = self._parse_action(response)

            # 4. Validar accion (ActionValidator)
            action = self.validator.validate(action)

            # 5. Detectar atascos
            if stuck_detector.is_stuck(action):
                history.append(stuck_detector.recovery_instruction())

            # 6. Ejecutar accion
            observation = await self.executor.execute(action)
            history.append((action, observation))

            # 7. Detectar degradacion
            score = self.degradation_detector.score(response)
            if score > 0.5:
                await self.watcher.alert_degradation(session_id, score)

            # 8. Condensar contexto si excede 80k chars
            if condenser.should_condense(history):
                history = await condenser.condense(history)

            # 9. Terminar si FINISH o REJECT
            if action.type in (FINISH, REJECT):
                return action
```

### Subsistemas de Seguridad

**StuckDetector:**
- Detecta 3+ comandos bash repetidos identicos
- Detecta errores identicos 3 veces consecutivas
- Detecta ciclos A→B→A→B en las ultimas 6 acciones
- Inyecta instruccion de recuperacion en el historial

**ContextCondenser:**
- Se activa al superar 80,000 caracteres en historial
- Preserva los ultimos 4 pasos completos
- Resume pasos anteriores con marcadores de verificacion
- Preserva mensajes de error LITERALMENTE
- Marca claramente los fallos con "FALLO"

**ActionValidator:**
- Rechaza comandos vacios o con placeholders
- Rechaza rutas sin extension de archivo
- Rechaza FINISH con mensajes vagos (<80 chars)
- Rechaza REJECT sin razon especifica
- Convierte acciones invalidas en THINK + recalibracion

## Componente 4: VeracityCore (Control Epistemico)

Sistema de 3 niveles que previene confabulacion y alucinaciones.

### Nivel 1: VERSION_COMPACT (~200 tokens)

Inyectado como prefijo en CADA llamada a ClaudeMaxRunner:
```
No inventes. Distingue hecho/opinion/incertidumbre.
Verifica antes de afirmar. Si no sabes, di "no se".
```

### Nivel 2: VERSION_STANDARD (~600 tokens)

Para el endpoint `/v1/chat`:
```
Tabla de calibracion:
- Alta certeza: "Segun [fuente]..."
- Media certeza: "Creo que... pero verificar"
- Baja certeza: "Probablemente..."
- Sin datos: "No tengo informacion sobre esto"

Prohibido: citas inventadas, estadisticas fabricadas,
afirmaciones sin fuente verificable.
```

### Nivel 3: VERSION_FULL (~1200 tokens)

Para AgenticLoop (sesiones multi-turn):
```
Incluye todas las reglas de STANDARD mas:
- Checklist de 4 puntos antes de cada accion
- Reglas especificas por tipo de accion (BASH/READ/WRITE/EDIT/FINISH)
- Senales de STOP para recalibracion forzada
- Deteccion de degradacion por iteracion
```

### DegradationDetector

```python
class DegradationDetector:
    PATTERNS = {
        # Confabulacion (0.25 por patron)
        "confabulation": [
            "como mencione", "as i mentioned", "we discussed",
            "as we established", "earlier we agreed"
        ],
        # Sobreconfianza (0.20 por patron)
        "overconfidence": [
            "clearly", "obviously", "no doubt",
            "definitely", "certainly"
        ],
        # Exito alucinado (0.30 por patron)
        "hallucinated_success": [
            "should work now", "must be working",
            "file has been", "successfully completed"
        ]
    }

    def score(self, response: str) -> float:
        """0.0 = limpio, >0.5 = alerta severa."""
        total = 0.0
        for category, patterns in self.PATTERNS.items():
            weight = {"confabulation": 0.25,
                      "overconfidence": 0.20,
                      "hallucinated_success": 0.30}[category]
            for p in patterns:
                if p.lower() in response.lower():
                    total += weight
        return min(total, 1.0)
```

### MemoryGuard

Filtra memorias antes de persistirlas:
- Rechaza si contiene marcadores de incertidumbre (23 patrones: "creo que", "maybe", "not sure"...)
- Rechaza datos tecnicos de sesiones fallidas
- Minimo 20 caracteres para persistir
- Auto-eliminacion de memorias filtradas

## Componente 5: Memoria 3-Capas (Mem0Manager)

| Capa | Backend | TTL | Proposito |
|------|---------|-----|-----------|
| L0 | Redis | 24h | Conversacion activa (ultimos 50 msgs) |
| L1 | mem0 + pgvector | Permanente | Semantica/episodica (768-dim nomic embeddings) |
| L2 | Supabase tables | 30 dias | Hechos de usuario, preferencias, config proyecto |

```python
class Mem0Manager:
    async def build_context(self, session_id, query, user_id):
        """Construye contexto combinando las 3 capas."""
        # Paralelo para minima latencia
        redis_history, semantic_memories, user_facts = await asyncio.gather(
            self._get_redis_history(session_id, limit=50),      # L0
            self._search_semantic(query, user_id, top_k=10),    # L1
            self._get_user_facts(user_id),                      # L2
        )
        return self._format_context(redis_history, semantic_memories, user_facts)

    async def remember(self, session_id, content, user_id):
        """Extrae y persiste memorias de una interaccion."""
        # MemoryGuard filtra antes de persistir
        if not self.memory_guard.should_persist(content):
            return
        # Push a Redis (L0)
        await self.redis.lpush(f"conv:{session_id}", content)
        await self.redis.ltrim(f"conv:{session_id}", 0, 49)
        # Index en mem0/pgvector (L1)
        await self.mem0.add(content, user_id=user_id, session_id=session_id)
```

**Redis Key Patterns:**
```
conv:{session_id}     → Lista de mensajes (max 50, TTL 24h)
ctx:{session_id}      → Metadata de sesion (JSONB)
metrics:*             → Contadores hot del Watcher
```

## Componente 6: Watcher (Audit Trail)

Observa y registra CADA interaccion con el agente.

```python
class Watcher:
    @asynccontextmanager
    async def observe(self, session_id, task):
        """Context manager que auto-persiste al salir."""
        ctx = ObserveContext(session_id, task)
        ctx.start_timer()
        try:
            yield ctx
        finally:
            ctx.stop_timer()
            await self._persist_to_supabase(ctx)
            await self._update_redis_metrics(ctx)
            await self._publish_event(ctx)

# Uso en endpoint /v1/chat:
async with watcher.observe(session_id, task) as ctx:
    route = await router.route(task)
    ctx.set_routing(route.agent, route.skills, route.confidence)
    result = await runner.run(prompt)
    ctx.set_result(result.text, result.exit_code == 0)
```

**Datos persistidos por interaccion:**
- session_id, task_preview, task_hash
- agent_used, skills_used, command_used
- routing_reasoning, routing_confidence
- response_preview, success, error
- latency_ms, tokens_estimated
- degradation_score, degradation_triggers

**Redis Pub/Sub Events:**
- `claude-brain:interaction.started`
- `claude-brain:interaction.completed`
- `claude-brain:epistemic.alert` (degradacion > 0.5)

**PostgreSQL Views:**
- `agent_metrics` — stats por agente (usos, latencia, tokens, success rate)
- `session_activity` — stats por sesion
- `degradation_report` — sesiones con problemas epistemicos

## Schemas de Base de Datos

### agent_memories (02-memories.sql)

```sql
CREATE TABLE agent_memories (
  id         TEXT PRIMARY KEY,
  content    TEXT NOT NULL,
  memory_type TEXT NOT NULL,  -- 'episodic' | 'semantic' | 'procedural'
  embedding  VECTOR(768),     -- nomic-embed-text-v1.5
  metadata   JSONB DEFAULT '{}',
  session_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_mem_embedding ON agent_memories
  USING hnsw (embedding vector_cosine_ops) WITH (m=16, ef_construction=64);

-- Busqueda semantica
CREATE FUNCTION match_memories(
  query_embedding VECTOR(768),
  match_threshold FLOAT DEFAULT 0.65,
  match_count INT DEFAULT 20,
  p_memory_type TEXT DEFAULT NULL
) RETURNS TABLE (id, content, memory_type, similarity, metadata, session_id);
```

### interactions (04-watcher.sql)

```sql
CREATE TABLE interactions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id          TEXT NOT NULL,
  task_preview        TEXT,
  task_hash           TEXT,
  agent_used          TEXT,
  skills_used         JSONB DEFAULT '[]',
  command_used        TEXT,
  routing_reasoning   TEXT,
  routing_confidence  FLOAT,
  response_preview    TEXT,
  success             BOOLEAN,
  error               TEXT,
  latency_ms          INTEGER,
  tokens_estimated    INTEGER,
  degradation_score   FLOAT DEFAULT 0,
  degradation_triggers JSONB DEFAULT '[]',
  created_at          TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_degradation ON interactions(degradation_score DESC)
  WHERE degradation_score > 0.3;
```

## Docker Compose (Estructura)

```yaml
services:
  cb-agent:
    build: ./agent
    ports: ["8000:8000"]
    environment:
      REDIS_URL: redis://redis:6379
      SUPABASE_URL: http://supabase-kong:8000
      SUPABASE_SERVICE_KEY: ${SUPABASE_SERVICE_KEY}
      CLAUDE_CREDENTIALS_JSON: ${CLAUDE_CREDENTIALS_JSON}
      EMBEDDING_URL: http://embeddings:8080
      JUPYTER_URL: http://jupyter:8888
      SANDBOX_URL: http://sandbox-api:8080
      # NO ANTHROPIC_API_KEY → Max OAuth
    volumes:
      - claude_auth:/root/.claude
      - workspaces:/workspaces
    depends_on: [cb-redis, cb-postgres, cb-embeddings]

  cb-redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru
    volumes: [redis_data:/data]

  cb-postgres:
    image: supabase/postgres:15.6.1.120
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes: [postgres_data:/var/lib/postgresql/data]

  cb-embeddings:
    image: ghcr.io/huggingface/text-embeddings-inference:cpu-1.5
    command: --model-id nomic-ai/nomic-embed-text-v1.5 --port 8080
    # Modelo local: 768 dims, $0/mes

  cb-snekbox:
    image: ghcr.io/python-discord/snekbox:latest
    # Sandbox Python con nsjail (aislamiento kernel-level)

  cb-jupyter:
    build: ./jupyter
    environment:
      JUPYTER_TOKEN: ${JUPYTER_TOKEN}
    volumes: [jupyter_data:/root/.ipython]
```

## Variables de Entorno Requeridas

```bash
# Autenticacion Claude (CRITICO)
CLAUDE_CREDENTIALS_JSON=<OAuth credentials JSON>
# ANTHROPIC_API_KEY=  ← VACIO o no definir (para usar Max OAuth)

# Base de datos
POSTGRES_PASSWORD=<generado>
SUPABASE_SERVICE_KEY=<service role key>

# Redis
REDIS_URL=redis://redis:6379

# Embeddings (local, sin API key)
EMBEDDING_URL=http://embeddings:8080

# Jupyter
JUPYTER_TOKEN=claude-brain-jupyter-token

# Telegram (opcional)
TELEGRAM_BOT_TOKEN=<bot token>
TELEGRAM_ALLOWED_IDS=<user_ids>

# GitHub (opcional)
GITHUB_TOKEN=<PAT para git ops>

# Tuning
AGENT_TIMEOUT_SECONDS=300
AGENT_MAX_SUBAGENTS=4
```

## Flujo de Request Completo

```
POST /v1/chat {task, session_id, user_id}
    │
    ▼
Watcher.observe() ─────────────────────────────┐
    │                                           │
    ▼                                           │
SmartRouter.route(task)                         │
    ├── Fast path (<5ms): regex rules           │
    └── LLM path (~3s): Claude analiza          │
    │                                           │
    ▼                                           │
Mem0Manager.build_context()                     │
    ├── L0: Redis history (50 msgs)             │
    ├── L1: mem0 semantic search (top 10)       │
    └── L2: Supabase user facts                 │
    │                                           │
    ▼                                           │
ComponentRegistry.build_prompt()                │
    ├── Agent persona (YAML)                    │
    ├── Skills instructions (markdown)          │
    ├── VeracityCore (COMPACT/STANDARD/FULL)    │
    └── Memory context inyectado                │
    │                                           │
    ▼                                           │
ClaudeMaxRunner.run(prompt)                     │
    └── subprocess: claude --print              │
    │                                           │
    ▼                                           │
Mem0Manager.remember() [async]                  │
    ├── MemoryGuard filtra                      │
    ├── Redis L0 push                           │
    └── mem0/pgvector L1 index                  │
    │                                           │
    ▼                                           │
Watcher.persist() ◄────────────────────────────┘
    ├── Supabase: interactions row
    ├── Redis: metricas hot
    └── Pub/Sub: eventos
    │
    ▼
Response → cliente
```

## Implementacion Paso a Paso

### Paso 1: Preparar VPS
```bash
# Requisitos minimos: 4 vCPU, 16GB RAM, 80GB SSD
# Ubuntu 22.04 recomendado
apt update && apt install -y docker.io docker-compose-v2 git
```

### Paso 2: Clonar y Configurar
```bash
git clone https://github.com/semaes111/CLAUDE-BRAIN.git
cd CLAUDE-BRAIN
cp .env.example .env
# Editar .env con tus credenciales
```

### Paso 3: Autenticar Claude Max
```bash
docker compose up -d cb-agent
docker compose exec cb-agent claude auth login
# → Genera CLAUDE_CREDENTIALS_JSON
# → Copiar al .env
docker compose down
```

### Paso 4: Levantar Stack Completo
```bash
docker compose up -d --build
# Verificar: curl http://localhost:8000/v1/health
```

### Paso 5: Aplicar Migraciones SQL
```bash
# Las migraciones se aplican automaticamente via init scripts
# en config/supabase/*.sql (orden numerico)
```

## Patrones Clave para Reutilizar

### Patron 1: Subprocess Engine sin API Billing
El ClaudeMaxRunner demuestra que puedes ejecutar Claude con capacidades completas (herramientas, streaming, multi-turn) sin pagar por API, solo con la suscripcion Max.

### Patron 2: Routing Dual-Speed
El SmartRouter muestra como combinar reglas heuristicas rapidas con LLM fallback para enrutamiento inteligente sin latencia innecesaria.

### Patron 3: Degradation-Aware Agent Loop
El AgenticLoop con StuckDetector + ContextCondenser + DegradationDetector es un patron replicable para cualquier agente autonomo que necesite ejecutar tareas complejas sin supervision.

### Patron 4: Epistemic Control Layer
VeracityCore demuestra que inyectar reglas de calibracion epistemica reduce alucinaciones mediblemente. El patron de 3 niveles (compact/standard/full) permite adaptar el overhead al tipo de tarea.

### Patron 5: Observable Agent
Watcher como context manager (`async with watcher.observe()`) es un patron elegante para audit trail sin ensuciar la logica de negocio.

## Nota sobre Sistemas Complementarios

Este skill documenta CLAUDE-BRAIN (Python + FastAPI), el sistema de orquestacion Docker para agente autonomo. Es **independiente** del sistema de memoria MEMU de 7 capas (TypeScript + Express, documentado en `persistent-memory-7layer`). Ambos usan pgvector pero con dimensiones diferentes:

- **CLAUDE-BRAIN**: nomic-embed-text-v1.5 → VECTOR(**768**) dims (modelo local, $0)
- **MEMU**: NVIDIA llama-3.2-nv-embedqa-1b-v2 → VECTOR(**1024**) dims (API externa)

NO son intercambiables. Elige uno segun tu stack (Python vs TypeScript).

## Archivos de Referencia

- `references/docker-compose.yml` — Docker Compose completo con los 11 servicios (402 lineas)
- `references/Dockerfile.agent` — Dockerfile del servicio principal agent-api
- `references/config.py` — Settings dataclass con todas las variables de configuracion (65 lineas)
- `references/claude_runner.py` — Motor ClaudeMaxRunner (236 lineas)
- `references/agentic_loop.py` — Bucle agentico multi-turn (855 lineas)
- `references/veracity.py` — Control epistemico 3 niveles (330 lineas)
- `references/mem0_manager.py` — Memoria 3-capas (324 lineas)
- `references/router.py` — SmartRouter dual-speed (276 lineas)
- `references/watcher.py` — Audit trail (353 lineas)
- `references/02-memories.sql` — Schema de memorias pgvector (77 lineas)
- `references/04-watcher.sql` — Schema de interacciones + views (116 lineas)
