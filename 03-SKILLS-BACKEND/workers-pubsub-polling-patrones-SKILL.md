---
name: "Workers: Patrones Pub-Sub + Polling"
description: "Arquitectura de workers para procesamiento de trabajos en segundo plano. Patrones híbridos pub-sub + polling con locking versio nado, garantía de entrega cero-pérdida, trabajos programados y cierre graceful."
triggers:
  - "worker patterns"
  - "pub-sub polling"
  - "background jobs"
  - "job processing"
  - "redis workers"
---

# Workers: Patrones Pub-Sub + Polling

## 1. Introducción a la Arquitectura de Workers

Los workers son procesos en segundo plano que procesan trabajos de forma asíncrona, desacoplando operaciones costosas del flujo de solicitudes HTTP. Este documento cubre patrones para garantizar entrega confiable de trabajos con baja latencia.

**Objetivos clave:**
- **Baja latencia**: Pub-Sub para notificación inmediata
- **Confiabilidad**: Polling de respaldo para jobs perdidos
- **Atomicidad**: Locking versio nado previene race conditions
- **Escalabilidad**: Múltiples workers con aislamiento de trabajos

---

## 2. Patrón 1: Pub-Sub (Despacho Inmediato)

### Concepto

Redis Pub-Sub proporciona notificación instantánea cuando nuevos trabajos están listos. El worker se suscribe al canal `new_jobs` y maneja inmediatamente cada trabajo.

### Características

- **No-bloqueante**: El handler es asíncrono
- **Baja latencia**: Notificación en milisegundos
- **Sin persistencia**: Si el worker cae durante subscripción, pierde eventos

### Implementación

```typescript
import Redis from 'ioredis';
import { nanoid } from 'nanoid';

const redis = new Redis();
const workerId = nanoid(8);

async function pubSubWorker() {
  const subscriber = new Redis();
  
  subscriber.on('message', async (channel, jobId) => {
    console.log(`[${workerId}] Job notificado: ${jobId}`);
    
    try {
      const job = await redis.get(`job:${jobId}`);
      if (!job) {
        console.warn(`Job no encontrado: ${jobId}`);
        return;
      }
      
      const jobData = JSON.parse(job);
      await processJob(jobData);
      
      await redis.del(`job:${jobId}`);
      console.log(`[${workerId}] Job completado: ${jobId}`);
    } catch (error) {
      console.error(`[${workerId}] Error procesando job ${jobId}:`, error);
      await redis.hset(`job:${jobId}`, 'error', error.message);
    }
  });
  
  await subscriber.subscribe('new_jobs');
  console.log(`[${workerId}] Suscrito a new_jobs`);
}

async function processJob(jobData) {
  // Simular procesamiento
  await new Promise(r => setTimeout(r, 1000));
}

pubSubWorker().catch(console.error);
```

### Desventajas

- Sin garantía de entrega (topic de Pub-Sub no persiste)
- No es adecuado como único patrón

---

## 3. Patrón 2: Polling (Garantía de Respaldo)

### Concepto

Sondeo periódico (cada 5 segundos) de la cola de trabajos. Cualquier job en estado PENDING es candidato para procesamiento. El locking versio nado previene que múltiples workers procesen el mismo job.

### Características

- **Persistencia**: Examina la DB/Redis cada intervalo
- **Confiable**: Captura jobs perdidos por pub-sub
- **Mayor latencia**: Hasta 5 segundos de espera
- **Overhead**: Consultas periódicas incluso sin jobs

### Locking Versio nado

Cada job tiene un campo `version`. El worker solo adquiere el lock si la versión coincide:

```typescript
async function acquireJobLock(jobId, currentVersion, workerId) {
  // UPDATE job SET version = version + 1, locked_by = workerId
  // WHERE id = jobId AND version = currentVersion
  
  const script = `
    if redis.call('get', KEYS[1] .. ':version') == ARGV[1] then
      redis.call('set', KEYS[1] .. ':locked_by', ARGV[2])
      redis.call('incr', KEYS[1] .. ':version')
      return 1
    end
    return 0
  `;
  
  const locked = await redis.eval(script, 1, `job:${jobId}`, currentVersion, workerId);
  return locked === 1;
}
```

### Implementación

```typescript
const POLL_INTERVAL = 5000; // 5 segundos
const BATCH_SIZE = 10;

async function pollingWorker() {
  const workerId = nanoid(8);
  console.log(`[${workerId}] Worker polling iniciado`);
  
  const pollingInterval = setInterval(async () => {
    try {
      // Obtener trabajos PENDING
      const jobs = await redis.zrange('jobs:pending', 0, BATCH_SIZE - 1);
      
      for (const jobId of jobs) {
        const jobStr = await redis.get(`job:${jobId}`);
        if (!jobStr) continue;
        
        const job = JSON.parse(jobStr);
        const currentVersion = job.version || 0;
        
        // Intentar adquirir lock
        const locked = await acquireJobLock(jobId, currentVersion, workerId);
        
        if (!locked) {
          console.log(`[${workerId}] Job ${jobId} ya está siendo procesado`);
          continue;
        }
        
        // Actualizar estado a PROCESSING
        const updatedJob = { ...job, status: 'PROCESSING', version: currentVersion + 1 };
        await redis.set(`job:${jobId}`, JSON.stringify(updatedJob));
        await redis.zrem('jobs:pending', jobId);
        await redis.zadd('jobs:processing', Date.now(), jobId);
        
        // Procesar de forma no-bloqueante
        (async () => {
          try {
            await processJob(updatedJob);
            updatedJob.status = 'COMPLETED';
            await redis.set(`job:${jobId}`, JSON.stringify(updatedJob));
            await redis.zrem('jobs:processing', jobId);
            await redis.zadd('jobs:completed', Date.now(), jobId);
          } catch (error) {
            updatedJob.status = 'FAILED';
            updatedJob.error = error.message;
            await redis.set(`job:${jobId}`, JSON.stringify(updatedJob));
            await redis.zrem('jobs:processing', jobId);
          }
        })();
      }
    } catch (error) {
      console.error(`[${workerId}] Error en polling:`, error);
    }
  }, POLL_INTERVAL);
  
  return () => clearInterval(pollingInterval);
}

// Adquirir lock (Lua script para atomicidad)
async function acquireJobLock(jobId, currentVersion, workerId) {
  const script = `
    local key = KEYS[1]
    local jobStr = redis.call('get', key)
    if not jobStr then return 0 end
    
    local job = cjson.decode(jobStr)
    if job.version ~= tonumber(ARGV[1]) then return 0 end
    
    job.version = job.version + 1
    job.locked_by = ARGV[2]
    redis.call('set', key, cjson.encode(job))
    return 1
  `;
  
  const result = await redis.eval(script, 1, `job:${jobId}`, currentVersion, workerId);
  return result === 1;
}
```

---

## 4. Patrón 3: Híbrido Pub-Sub + Polling (RECOMENDADO)

### Concepto

Combina ambos patrones: Pub-Sub para baja latencia, polling como respaldo. El worker corre ambos concurrentemente.

**Ventajas:**
- Latencia típica: milisegundos (Pub-Sub)
- Garantía: cero-pérdida (Polling)
- Robustez: maneja desconexiones Pub-Sub

### Implementación

```typescript
import Redis from 'ioredis';
import { nanoid } from 'nanoid';

async function hybridWorker() {
  const workerId = nanoid(8);
  const redis = new Redis();
  const subscriber = new Redis();
  
  console.log(`[${workerId}] Worker híbrido iniciando...`);
  
  let isShuttingDown = false;
  const intervals = [];
  
  // ===== PUB-SUB: Notificación inmediata =====
  const pubSubTask = (async () => {
    subscriber.on('message', async (channel, jobId) => {
      if (isShuttingDown) return;
      
      console.log(`[${workerId}] [PUB-SUB] Job notificado: ${jobId}`);
      await handleJobById(jobId, workerId, redis);
    });
    
    await subscriber.subscribe('new_jobs');
  })();
  
  // ===== POLLING: Respaldo cada 5 segundos =====
  const pollingTask = (async () => {
    const pollInterval = setInterval(async () => {
      if (isShuttingDown) return;
      
      try {
        const jobs = await redis.zrange('jobs:pending', 0, 9);
        
        for (const jobId of jobs) {
          if (isShuttingDown) break;
          console.log(`[${workerId}] [POLLING] Examinando job: ${jobId}`);
          await handleJobById(jobId, workerId, redis);
        }
      } catch (error) {
        console.error(`[${workerId}] [POLLING] Error:`, error);
      }
    }, 5000);
    
    intervals.push(pollInterval);
  })();
  
  // ===== SHUTDOWN GRACEFUL =====
  const gracefulShutdown = () => {
    console.log(`[${workerId}] Cierre graceful iniciado...`);
    isShuttingDown = true;
    
    intervals.forEach(clearInterval);
    subscriber.unsubscribe();
    redis.disconnect();
    
    console.log(`[${workerId}] Apagado completado`);
  };
  
  process.on('SIGTERM', gracefulShutdown);
  process.on('SIGINT', gracefulShutdown);
  
  await Promise.all([pubSubTask, pollingTask]);
}

async function handleJobById(jobId, workerId, redis) {
  try {
    const jobStr = await redis.get(`job:${jobId}`);
    if (!jobStr) return;
    
    const job = JSON.parse(jobStr);
    
    // Intentar lock
    const locked = await tryLockJob(jobId, job.version || 0, workerId, redis);
    if (!locked) return;
    
    // Procesar
    console.log(`[${workerId}] Procesando: ${jobId}`);
    const updatedJob = { ...job, status: 'PROCESSING', version: (job.version || 0) + 1 };
    await redis.set(`job:${jobId}`, JSON.stringify(updatedJob));
    
    try {
      await processJob(updatedJob);
      updatedJob.status = 'COMPLETED';
      await redis.set(`job:${jobId}`, JSON.stringify(updatedJob));
      console.log(`[${workerId}] Completado: ${jobId}`);
    } catch (error) {
      updatedJob.status = 'FAILED';
      updatedJob.error = error.message;
      await redis.set(`job:${jobId}`, JSON.stringify(updatedJob));
      console.error(`[${workerId}] Falló ${jobId}:`, error.message);
    }
  } catch (error) {
    console.error(`[${workerId}] Error manejando job ${jobId}:`, error);
  }
}

async function tryLockJob(jobId, currentVersion, workerId, redis) {
  const script = `
    local key = KEYS[1]
    local jobStr = redis.call('get', key)
    if not jobStr then return 0 end
    
    local job = cjson.decode(jobStr)
    if (job.version or 0) ~= tonumber(ARGV[1]) then return 0 end
    if job.status ~= 'PENDING' then return 0 end
    
    job.status = 'LOCKED'
    job.locked_by = ARGV[2]
    job.locked_at = redis.call('time')[1]
    redis.call('set', key, cjson.encode(job))
    return 1
  `;
  
  const result = await redis.eval(script, 1, `job:${jobId}`, currentVersion, workerId);
  return result === 1;
}

async function processJob(job) {
  // Simular procesamiento
  await new Promise(r => setTimeout(r, Math.random() * 2000));
}

hybridWorker().catch(console.error);
```

---

## 5. Job Locking con Control de Versión

### Ciclo de Vida del Job

```
PENDING → LOCKED → PROCESSING → COMPLETED
                 ↘ (error) → FAILED
```

### Componentes de Locking

```typescript
interface Job {
  id: string;
  status: 'PENDING' | 'LOCKED' | 'PROCESSING' | 'COMPLETED' | 'FAILED';
  version: number;        // Incrementa en cada transición
  locked_by?: string;     // ID del worker que lo bloquea
  locked_at?: number;     // Timestamp de bloqueo
  error?: string;         // Mensaje de error si falló
  retries: number;        // Intentos de procesamiento
  max_retries: number;    // Máximo permitido
}
```

### Adquisición Atómica de Lock

```typescript
// Script Lua garantiza atomicidad
const acquireLockScript = `
  local jobKey = KEYS[1]
  local jobStr = redis.call('get', jobKey)
  
  if not jobStr then
    return { 0, 'Job not found' }
  end
  
  local job = cjson.decode(jobStr)
  
  -- Verificar versión
  if job.version ~= tonumber(ARGV[1]) then
    return { 0, 'Version mismatch' }
  end
  
  -- Verificar estado
  if job.status ~= 'PENDING' then
    return { 0, 'Not pending' }
  end
  
  -- Verificar límite de reintentos
  if job.retries >= job.max_retries then
    job.status = 'FAILED'
    job.error = 'Max retries exceeded'
    redis.call('set', jobKey, cjson.encode(job))
    return { 0, 'Max retries exceeded' }
  end
  
  -- Adquirir lock
  job.status = 'LOCKED'
  job.version = job.version + 1
  job.locked_by = ARGV[2]
  job.locked_at = tonumber(ARGV[3])
  redis.call('set', jobKey, cjson.encode(job))
  
  return { 1, 'Locked' }
`;

async function acquireLock(jobId, version, workerId, redis) {
  const now = Date.now();
  const [success, message] = await redis.eval(
    acquireLockScript,
    1,
    `job:${jobId}`,
    version,
    workerId,
    now
  );
  
  return { success: success === 1, message };
}
```

### Detección de Deadlocks

```typescript
// Los locks pueden expirar si el worker falla
const LOCK_TIMEOUT = 30000; // 30 segundos

async function cleanupStaleLocks(redis) {
  const now = Date.now();
  const pattern = 'job:*';
  
  let cursor = '0';
  do {
    const [nextCursor, keys] = await redis.scan(cursor, 'MATCH', pattern);
    cursor = nextCursor;
    
    for (const key of keys) {
      const jobStr = await redis.get(key);
      if (!jobStr) continue;
      
      const job = JSON.parse(jobStr);
      
      // Si está LOCKED hace más de 30 segundos, liberar
      if (job.status === 'LOCKED' && (now - job.locked_at) > LOCK_TIMEOUT) {
        job.status = 'PENDING';
        job.locked_by = undefined;
        job.locked_at = undefined;
        job.retries += 1;
        await redis.set(key, JSON.stringify(job));
        console.log(`Lock expirado liberado: ${key}`);
      }
    }
  } while (cursor !== '0');
}

// Ejecutar cada 10 segundos
setInterval(() => cleanupStaleLocks(redis), 10000);
```

---

## 6. Trabajos Programados (Scheduled Jobs)

### Patrón 1: Trabajos de Una Sola Ejecución

```typescript
interface OneTimeRule {
  id: string;
  type: 'one-time';
  scheduled_for: number;    // Unix timestamp
  job_template: any;
  created_at: number;
  executed_at?: number;
}

async function processOneTimeRules(redis) {
  const now = Date.now();
  
  // Buscar reglas vencidas
  const rules = await redis.zrangebyscore('rules:one-time', 0, now);
  
  for (const ruleId of rules) {
    const ruleStr = await redis.get(`rule:${ruleId}`);
    if (!ruleStr) continue;
    
    const rule = JSON.parse(ruleStr);
    
    // Crear job
    const jobId = nanoid();
    const job = {
      id: jobId,
      ...rule.job_template,
      status: 'PENDING',
      version: 0,
      retries: 0,
      max_retries: 3,
      created_from_rule: ruleId,
      created_at: now
    };
    
    await redis.set(`job:${jobId}`, JSON.stringify(job));
    await redis.zadd('jobs:pending', now, jobId);
    await redis.publish('new_jobs', jobId);
    
    // Marcar regla como ejecutada
    rule.executed_at = now;
    await redis.set(`rule:${ruleId}`, JSON.stringify(rule));
    await redis.zrem('rules:one-time', ruleId);
    
    console.log(`Job creado desde regla one-time: ${jobId}`);
  }
}
```

### Patrón 2: Trabajos Recurrentes (Cron)

```typescript
import cron from 'node-cron';

interface RecurringRule {
  id: string;
  type: 'recurring';
  cron_expression: string;    // "0 9 * * *" (9am diariamente)
  job_template: any;
  enabled: boolean;
  last_run?: number;
}

async function setupRecurringRule(rule, redis) {
  // Validar expresión cron
  try {
    const task = cron.schedule(rule.cron_expression, async () => {
      if (!rule.enabled) return;
      
      const now = Date.now();
      
      // Crear job
      const jobId = nanoid();
      const job = {
        id: jobId,
        ...rule.job_template,
        status: 'PENDING',
        version: 0,
        retries: 0,
        max_retries: 3,
        created_from_rule: rule.id,
        created_at: now
      };
      
      await redis.set(`job:${jobId}`, JSON.stringify(job));
      await redis.zadd('jobs:pending', now, jobId);
      await redis.publish('new_jobs', jobId);
      
      // Actualizar último run
      rule.last_run = now;
      await redis.set(`rule:${rule.id}`, JSON.stringify(rule));
      
      console.log(`Job creado desde regla recurring: ${jobId}`);
    }, {
      // Alineado a minutos para polling sincronizado
      scheduled: true,
      timezone: 'UTC'
    });
    
    return task;
  } catch (error) {
    console.error(`Cron inválido: ${rule.cron_expression}`, error);
    throw error;
  }
}

// Polling-based alternativo (sin dependencias externas)
async function pollingBasedRecurringRules(redis) {
  setInterval(async () => {
    const now = Date.now();
    const nowMinute = Math.floor(now / 60000) * 60000; // Alineado a minuto
    
    const rules = await redis.smembers('rules:recurring');
    
    for (const ruleId of rules) {
      const ruleStr = await redis.get(`rule:${ruleId}`);
      if (!ruleStr) continue;
      
      const rule = JSON.parse(ruleStr);
      if (!rule.enabled) continue;
      
      // Comprobar si debe ejecutarse
      const lastRun = rule.last_run || 0;
      const shouldRun = (nowMinute - lastRun) >= 60000; // Al menos 1 minuto
      
      if (!shouldRun) continue;
      
      // Crear job
      const jobId = nanoid();
      const job = {
        id: jobId,
        ...rule.job_template,
        status: 'PENDING',
        version: 0,
        retries: 0,
        max_retries: 3,
        created_from_rule: ruleId,
        created_at: now
      };
      
      await redis.set(`job:${jobId}`, JSON.stringify(job));
      await redis.zadd('jobs:pending', now, jobId);
      await redis.publish('new_jobs', jobId);
      
      rule.last_run = now;
      await redis.set(`rule:${ruleId}`, JSON.stringify(rule));
    }
  }, 5000); // Comprobar cada 5 segundos
}
```

---

## 7. Quota y Límites de Concurrencia

### Enforcement de Cuota

```typescript
interface JobQuota {
  max_concurrent: number;     // Workers simultáneos
  max_per_minute: number;     // Rate limit
  max_per_hour: number;       // Límite horario
}

async function checkQuotaBeforeExecution(jobType, redis) {
  const quota = await redis.get(`quota:${jobType}`);
  if (!quota) return true; // Sin límite
  
  const q = JSON.parse(quota);
  const now = Date.now();
  const minute = Math.floor(now / 60000);
  const hour = Math.floor(now / 3600000);
  
  // Contar concurrentes
  const concurrentKey = `metric:${jobType}:concurrent`;
  const concurrent = await redis.get(concurrentKey) || '0';
  
  if (parseInt(concurrent) >= q.max_concurrent) {
    return false; // Cuota de concurrencia excedida
  }
  
  // Contar por minuto
  const minuteKey = `metric:${jobType}:minute:${minute}`;
  const perMinute = await redis.get(minuteKey) || '0';
  
  if (parseInt(perMinute) >= q.max_per_minute) {
    return false;
  }
  
  // Contar por hora
  const hourKey = `metric:${jobType}:hour:${hour}`;
  const perHour = await redis.get(hourKey) || '0';
  
  if (parseInt(perHour) >= q.max_per_hour) {
    return false;
  }
  
  return true;
}

async function recordJobExecution(jobType, redis) {
  const now = Date.now();
  const minute = Math.floor(now / 60000);
  const hour = Math.floor(now / 3600000);
  
  // Incrementar concurrentes
  await redis.incr(`metric:${jobType}:concurrent`);
  await redis.expire(`metric:${jobType}:concurrent`, 3600);
  
  // Incrementar por minuto
  await redis.incr(`metric:${jobType}:minute:${minute}`);
  await redis.expire(`metric:${jobType}:minute:${minute}`, 60);
  
  // Incrementar por hora
  await redis.incr(`metric:${jobType}:hour:${hour}`);
  await redis.expire(`metric:${jobType}:hour:${hour}`, 3600);
}

async function recordJobCompletion(jobType, redis) {
  await redis.decr(`metric:${jobType}:concurrent`);
}
```

---

## 8. Cierre Graceful y Cleanup

### Implementación Completa

```typescript
class WorkerPool {
  private workerId: string;
  private isShuttingDown = false;
  private activeJobs = new Set<string>();
  private intervals: NodeJS.Timeout[] = [];
  private promises: Promise<any>[] = [];
  private redis: Redis;
  private subscriber: Redis;
  
  constructor() {
    this.workerId = nanoid(8);
    this.redis = new Redis();
    this.subscriber = new Redis();
  }
  
  async start() {
    console.log(`[${this.workerId}] Iniciando worker pool...`);
    
    // Pub-Sub
    this.subscriber.on('message', (ch, jobId) => this.handleJob(jobId));
    await this.subscriber.subscribe('new_jobs');
    
    // Polling
    const pollInterval = setInterval(() => this.pollJobs(), 5000);
    this.intervals.push(pollInterval);
    
    // Cleanup de locks expirados
    const cleanupInterval = setInterval(() => this.cleanupStaleLocks(), 10000);
    this.intervals.push(cleanupInterval);
    
    // Señales de termninación
    process.on('SIGTERM', () => this.gracefulShutdown());
    process.on('SIGINT', () => this.gracefulShutdown());
  }
  
  private async handleJob(jobId: string) {
    if (this.isShuttingDown) return;
    
    try {
      const jobStr = await this.redis.get(`job:${jobId}`);
      if (!jobStr) return;
      
      const job = JSON.parse(jobStr);
      
      // Verificar cuota
      const canExecute = await checkQuotaBeforeExecution(job.type, this.redis);
      if (!canExecute) {
        console.warn(`Cuota excedida para ${job.type}`);
        return;
      }
      
      // Intentar lock
      const locked = await tryLockJob(jobId, job.version || 0, this.workerId, this.redis);
      if (!locked) return;
      
      this.activeJobs.add(jobId);
      
      const promise = (async () => {
        try {
          await recordJobExecution(job.type, this.redis);
          
          console.log(`[${this.workerId}] Procesando: ${jobId}`);
          await processJob(job);
          
          const updated = { ...job, status: 'COMPLETED', version: (job.version || 0) + 1 };
          await this.redis.set(`job:${jobId}`, JSON.stringify(updated));
          
          console.log(`[${this.workerId}] Completado: ${jobId}`);
        } catch (error) {
          const updated = {
            ...job,
            status: 'FAILED',
            error: error.message,
            version: (job.version || 0) + 1,
            retries: (job.retries || 0) + 1
          };
          await this.redis.set(`job:${jobId}`, JSON.stringify(updated));
          
          console.error(`[${this.workerId}] Error: ${jobId}`, error.message);
        } finally {
          await recordJobCompletion(job.type, this.redis);
          this.activeJobs.delete(jobId);
        }
      })();
      
      this.promises.push(promise);
    } catch (error) {
      console.error(`Error manejando job ${jobId}:`, error);
    }
  }
  
  private async pollJobs() {
    if (this.isShuttingDown) return;
    
    try {
      const jobs = await this.redis.zrange('jobs:pending', 0, 9);
      for (const jobId of jobs) {
        await this.handleJob(jobId);
      }
    } catch (error) {
      console.error('Error en polling:', error);
    }
  }
  
  private async cleanupStaleLocks() {
    const now = Date.now();
    const LOCK_TIMEOUT = 30000;
    
    let cursor = '0';
    do {
      const [nextCursor, keys] = await this.redis.scan(cursor, 'MATCH', 'job:*');
      cursor = nextCursor;
      
      for (const key of keys) {
        const jobStr = await this.redis.get(key);
        if (!jobStr) continue;
        
        const job = JSON.parse(jobStr);
        if (job.status === 'LOCKED' && (now - job.locked_at) > LOCK_TIMEOUT) {
          job.status = 'PENDING';
          job.locked_by = undefined;
          job.locked_at = undefined;
          job.retries = (job.retries || 0) + 1;
          await this.redis.set(key, JSON.stringify(job));
          console.log(`Lock expirado liberado: ${key}`);
        }
      }
    } while (cursor !== '0');
  }
  
  private async gracefulShutdown() {
    console.log(`[${this.workerId}] Iniciando cierre graceful...`);
    this.isShuttingDown = true;
    
    // Dejar de aceptar nuevos trabajos
    this.subscriber.unsubscribe();
    this.intervals.forEach(clearInterval);
    
    // Esperar a que terminen los actuales (con timeout)
    console.log(`[${this.workerId}] Esperando ${this.activeJobs.size} jobs activos...`);
    const timeout = setTimeout(() => {
      console.warn(`[${this.workerId}] Timeout en cierre, forzando...`);
      process.exit(1);
    }, 30000);
    
    await Promise.allSettled(this.promises);
    clearTimeout(timeout);
    
    // Limpiar locks
    for (const jobId of this.activeJobs) {
      const jobStr = await this.redis.get(`job:${jobId}`);
      if (jobStr) {
        const job = JSON.parse(jobStr);
        if (job.locked_by === this.workerId) {
          job.status = 'PENDING';
          job.locked_by = undefined;
          job.locked_at = undefined;
          await this.redis.set(`job:${jobId}`, JSON.stringify(job));
        }
      }
    }
    
    this.redis.disconnect();
    console.log(`[${this.workerId}] Apagado completado`);
    process.exit(0);
  }
}

const pool = new WorkerPool();
await pool.start();
```

---

## 9. Comparación con Alternativas

| Aspecto | Este Patrón | BullMQ | Trigger.dev | Temporal |
|--------|------------|--------|------------|----------|
| **Setup** | Mínimo (Redis) | Moderno, con UI | Cloud only | Complejo |
| **Latencia** | ms (Pub-Sub) | ms | segundos | segundos |
| **Confiabilidad** | Alta (Polling) | Alta | Muy Alta | Muy Alta |
| **Costo** | Bajo | Bajo | Pago | Bajo (self-hosted) |
| **Escalabilidad** | Horizontal | Horizontal | Ilimitado | Horizontal |
| **Monitoreo** | Manual | Incluido | Incluido | Incluido |
| **Persistencia** | Redis | Redis | Distribuida | Distribuida |
| **Workflows complejos** | Manual | Soporte | Excelente | Excelente |

### Cuándo usar este patrón

- **Volúmenes bajos-medios** (< 10k jobs/minuto)
- **Latencia crítica** (< 100ms)
- **Costos mínimos**
- **Control total del código**
- **Ya tienes Redis**

### Cuándo migrar a alternativas

- **BullMQ**: Si necesitas UI, rate limiting avanzado
- **Trigger.dev**: Workflows complejos, multi-tenant
- **Temporal**: Orquestación distribuida, larga duración

---

## 10. Ejemplo Completo: Sistema de Email

```typescript
const emailWorker = new WorkerPool();

// Definir regla de envío
await redis.set('rule:daily-digest', JSON.stringify({
  id: 'daily-digest',
  type: 'recurring',
  cron_expression: '0 9 * * *',
  job_template: {
    type: 'email.send-digest',
    user_id: 'all',
    template: 'daily-digest'
  },
  enabled: true
}));

// Implementar handler
async function processJob(job) {
  if (job.type === 'email.send-digest') {
    // Obtener usuarios
    const users = await db.query('SELECT * FROM users WHERE notifications_enabled = true');
    
    for (const user of users) {
      const digest = await generateDigest(user);
      await sendEmail(user.email, digest);
    }
  }
}

await emailWorker.start();
```

---

## 11. Métricas y Observabilidad

```typescript
async function getMetrics(redis) {
  return {
    pending: await redis.zcard('jobs:pending'),
    processing: await redis.zcard('jobs:processing'),
    completed: await redis.zcard('jobs:completed'),
    failed: await redis.zcard('jobs:failed'),
    active_workers: await redis.smembers('workers:active'),
    avg_processing_time: await getAverageProcessingTime(redis)
  };
}

// Guardar métricas históricas
async function recordMetrics(redis) {
  const now = Date.now();
  const metrics = await getMetrics(redis);
  
  await redis.zadd(
    'metrics:history',
    now,
    JSON.stringify(metrics)
  );
  
  // Mantener solo últimas 24 horas
  const oneDayAgo = now - 86400000;
  await redis.zremrangebyscore('metrics:history', 0, oneDayAgo);
}
```

---

**Resumen:** Este patrón proporciona workers confiables con baja latencia usando Pub-Sub para notificación inmediata y polling como garantía de entrega. El locking versio nado previene race conditions, mientras que la programación integrada permite trabajos programados de una sola ejecución o recurrentes. Es ideal para volúmenes medios con requisitos de confiabilidad y costos bajos.
