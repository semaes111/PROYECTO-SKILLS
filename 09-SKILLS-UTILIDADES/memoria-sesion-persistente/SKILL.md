---
name: session-memory
description: >
  Sistema de pseudo-memoria persistente entre sesiones de Cowork.
  Usa un archivo CLAUDE-MEMORY.md en la carpeta del usuario como almacen
  estructurado de hechos, decisiones, proyectos, preferencias y contexto
  acumulado entre sesiones. Cuando el usuario dice "guarda en la memoria",
  Claude escribe/actualiza el archivo. Cuando dice "carga la memoria",
  Claude lo lee y recupera todo el contexto. El archivo actua como
  cerebro externo que persiste en el disco del usuario.
  Usar cuando el usuario mencione: guarda en la memoria, recuerda esto,
  carga la memoria, que sabes de mi, memoria persistente, contexto entre
  sesiones, no te olvides, apunta esto, actualiza la memoria.
triggers:
  - "guarda en la memoria"
  - "carga la memoria"
  - "recuerda esto"
  - "que sabes de mi"
  - "actualiza la memoria"
  - "no te olvides"
  - "apunta esto"
  - "memoria persistente"
  - "borra de la memoria"
  - "busca en la memoria"
---

# Session Memory: Pseudo-Memoria Persistente para Cowork

## Concepto

Claude no tiene memoria entre sesiones. Este skill resuelve esa limitacion
usando un archivo `CLAUDE-MEMORY.md` almacenado en la carpeta seleccionada
por el usuario como **cerebro externo persistente**.

El flujo es:

```
INICIO DE SESION                    FIN DE SESION
      │                                   │
      ▼                                   ▼
"carga la memoria"              "guarda en la memoria"
      │                                   │
      ▼                                   ▼
Read CLAUDE-MEMORY.md           Write/Edit CLAUDE-MEMORY.md
      │                                   │
      ▼                                   ▼
Claude tiene contexto           Contexto persiste en disco
de sesiones anteriores          para la proxima sesion
```

## Comandos del Usuario y Comportamiento Esperado

### 1. "carga la memoria" / "que sabes de mi"

**Accion:** Leer `CLAUDE-MEMORY.md` de la carpeta del usuario.

```
Paso 1: Buscar el archivo en la carpeta montada del usuario
        → Ruta: /sessions/*/mnt/outputs/CLAUDE-MEMORY.md
        → O en la carpeta seleccionada: /sessions/*/mnt/*/CLAUDE-MEMORY.md

Paso 2: Si existe → Read completo del archivo
        Si NO existe → Informar al usuario y ofrecer crear uno nuevo

Paso 3: Parsear las secciones y resumir al usuario:
        "He cargado tu memoria. Conozco X proyectos, Y decisiones
         tecnicas, y Z preferencias. La ultima sesion fue el [fecha]
         donde trabajamos en [tema]."

Paso 4: Mantener el contenido en contexto para toda la sesion
```

### 2. "guarda en la memoria" / "recuerda esto" / "apunta esto"

**Accion:** Actualizar `CLAUDE-MEMORY.md` con informacion de la sesion actual.

```
Paso 1: Si el archivo NO existe → Crear con template completo (ver abajo)
        Si existe → Read el contenido actual

Paso 2: Determinar QUE guardar de la sesion actual:

   GUARDAR SIEMPRE:
   ✅ Decisiones tecnicas tomadas (stack, herramientas, patrones)
   ✅ Proyectos mencionados y su estado actual
   ✅ Preferencias del usuario (formato, idioma, estilo)
   ✅ Problemas resueltos y como se resolvieron
   ✅ Credenciales/tokens referenciados (solo nombre, NUNCA el valor)
   ✅ URLs de repos, proyectos, recursos importantes
   ✅ Skills creadas o modificadas
   ✅ Errores recurrentes y sus soluciones

   NO GUARDAR NUNCA:
   ❌ Tokens, passwords, API keys (valores reales)
   ❌ Conversacion literal (solo resumen)
   ❌ Informacion temporal sin valor futuro
   ❌ Datos personales sensibles (medicos, financieros)

Paso 3: Actualizar las secciones correspondientes del archivo:
   - Anadir nueva entrada en ## Historial de Sesiones
   - Actualizar ## Proyectos Activos si hubo cambios
   - Actualizar ## Stack Tecnologico si se tomaron decisiones
   - Actualizar ## Decisiones y Patrones si se establecieron nuevos
   - Actualizar ## Preferencias si se descubrieron nuevas

Paso 4: Escribir el archivo actualizado usando Edit (no Write, para
        preservar contenido existente cuando sea posible)

Paso 5: Confirmar al usuario:
        "Memoria actualizada. He guardado: [lista de lo guardado].
         Proximo inicio de sesion, dime 'carga la memoria' y tendre
         todo este contexto."
```

### 3. "actualiza la memoria" / "corrige en la memoria"

**Accion:** Modificar una entrada especifica existente.

```
Paso 1: Read CLAUDE-MEMORY.md
Paso 2: Pedir al usuario que especifique que cambiar (si no lo indico)
Paso 3: Edit la seccion correspondiente
Paso 4: Confirmar el cambio
```

### 4. "borra de la memoria" / "olvida esto"

**Accion:** Eliminar informacion especifica.

```
Paso 1: Read CLAUDE-MEMORY.md
Paso 2: Identificar que eliminar
Paso 3: Edit para remover la seccion/entrada
Paso 4: Confirmar: "Eliminado [X] de la memoria."
```

### 5. "busca en la memoria" / "que tenemos sobre [tema]"

**Accion:** Buscar informacion especifica en la memoria.

```
Paso 1: Read CLAUDE-MEMORY.md
Paso 2: Filtrar por el tema solicitado
Paso 3: Presentar la informacion encontrada con contexto
```

## Template de CLAUDE-MEMORY.md

Cuando se crea por primera vez, usar exactamente esta estructura:

```markdown
# CLAUDE-MEMORY
> Memoria persistente entre sesiones de Cowork
> Ultima actualizacion: [FECHA]

---

## Perfil del Usuario

- **Nombre:** [nombre]
- **Email:** [email si disponible]
- **Rol/Profesion:** [rol]
- **Idioma preferido:** [idioma]
- **Zona horaria:** [timezone si conocido]

## Preferencias de Trabajo

- **Formato de respuestas:** [ej: tecnicas, detalladas, con ejemplos]
- **Skills favoritas:** [lista]
- **Patrones de uso:** [ej: usa /wizard para tareas complejas]
- **Estilo de commit:** [si aplica]
- **Herramientas preferidas:** [ej: VS Code, Docker, etc.]

## Stack Tecnologico

### Principal
- **Frontend:** [frameworks, librerias]
- **Backend:** [lenguajes, frameworks]
- **Base de datos:** [DBs usadas]
- **Infraestructura:** [cloud, Docker, etc.]
- **CI/CD:** [herramientas]

### Decisiones de Stack
| Fecha | Decision | Razon | Contexto |
|-------|----------|-------|----------|
| | | | |

## Proyectos Activos

### [Nombre del Proyecto]
- **Repo:** [URL]
- **Estado:** [activo/pausado/completado]
- **Stack:** [tecnologias]
- **Ultima actividad:** [fecha y que se hizo]
- **Notas:** [contexto importante]

## Decisiones y Patrones

### Arquitectura
| Fecha | Decision | Alternativas Consideradas | Razon |
|-------|----------|--------------------------|-------|
| | | | |

### Patrones Recurrentes
- [patron 1: descripcion]
- [patron 2: descripcion]

## Problemas Resueltos

### [Titulo del problema]
- **Fecha:** [fecha]
- **Contexto:** [que paso]
- **Solucion:** [como se resolvio]
- **Prevencion:** [como evitarlo en el futuro]

## Recursos y Referencias

- **Repos GitHub:** [lista con URLs]
- **Documentacion:** [links importantes]
- **APIs/Servicios:** [nombre + proposito, NUNCA keys]
- **Skills custom:** [lista de skills creadas]

## Historial de Sesiones

### [FECHA] — [Titulo descriptivo]
- **Temas:** [lista de temas tratados]
- **Logros:** [que se completo]
- **Pendiente:** [que quedo sin hacer]
- **Decisiones:** [decisiones tomadas]
- **Nota:** [cualquier contexto relevante para futuras sesiones]

---
> Generado por session-memory skill | No editar manualmente la estructura
```

## Reglas de Actualizacion

### Regla 1: Append, No Overwrite
Siempre ANADIR al historial, nunca borrar sesiones anteriores.
Las secciones como "Proyectos Activos" se ACTUALIZAN (edit), no se reescriben.

### Regla 2: Compactacion Periodica
Si el historial supera 50 sesiones, crear un resumen de las 40 mas antiguas
y mantener las 10 mas recientes en detalle:

```markdown
### Resumen Sesiones Anteriores (Ene 2026 - Mar 2026)
- 40 sesiones totales
- Proyectos principales: [X, Y, Z]
- Decisiones clave: [lista]
- Temas recurrentes: [lista]
```

### Regla 3: Prioridad de Informacion
Al guardar, priorizar en este orden:
1. Decisiones tecnicas (mayor valor futuro)
2. Estado de proyectos (orientacion de trabajo)
3. Problemas resueltos (evitar repetir trabajo)
4. Preferencias descubiertas (mejorar interaccion)
5. Contexto general (background)

### Regla 4: Formato Consistente
- Fechas siempre en formato: YYYY-MM-DD
- Tablas para decisiones (facil de escanear)
- Bullet points para listas
- Headers ### para separar entradas del historial
- Negrita para campos clave

### Regla 5: Seguridad
- NUNCA escribir valores de tokens, passwords o API keys
- Solo registrar: "Token GitHub: configurado" (sin el valor)
- Si el usuario pide guardar un secret, advertir y guardar solo referencia

## Flujo Recomendado por Sesion

```
┌─────────────────────────────────────────────────────────┐
│  INICIO DE SESION                                        │
│                                                          │
│  Usuario: "carga la memoria"                             │
│  Claude: Read CLAUDE-MEMORY.md → resume contexto         │
│          "Bienvenido Sergio. Ultima sesion: [fecha].     │
│           Trabajamos en [tema]. Tienes [N] proyectos     │
│           activos. ¿Continuamos con algo pendiente?"     │
│                                                          │
├─────────────────────────────────────────────────────────┤
│  DURANTE LA SESION                                       │
│                                                          │
│  Claude tiene contexto completo del usuario.             │
│  Puede referenciar decisiones previas, proyectos,        │
│  preferencias, etc. sin que el usuario repita info.      │
│                                                          │
│  Si el usuario dice "recuerda esto" o "apunta que..."   │
│  → Actualizar CLAUDE-MEMORY.md inmediatamente            │
│                                                          │
├─────────────────────────────────────────────────────────┤
│  FIN DE SESION                                           │
│                                                          │
│  Usuario: "guarda en la memoria"                         │
│  Claude: Analiza toda la sesion, extrae:                 │
│          - Decisiones tomadas                            │
│          - Proyectos tocados y su nuevo estado           │
│          - Problemas resueltos                           │
│          - Nuevas preferencias descubiertas              │
│          → Write/Edit CLAUDE-MEMORY.md                   │
│          "Memoria actualizada con [N] items nuevos."     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Prerequisito Critico

Para que este skill funcione, el usuario DEBE tener una carpeta seleccionada
en Cowork (mount). Si no la tiene:

```
Claude: "Para guardar tu memoria necesito acceso a una carpeta de tu
computadora. Voy a pedirte que selecciones una."
→ Usar request_cowork_directory tool
→ Guardar CLAUDE-MEMORY.md en esa carpeta
```

La ubicacion por defecto es: `/sessions/*/mnt/outputs/CLAUDE-MEMORY.md`

Si el usuario tiene una carpeta montada, preferir esa ubicacion para que
el archivo persista entre sesiones de Cowork.

## Deteccion Automatica

Cuando esta skill esta activa, Claude DEBERIA:

1. **Al inicio de sesion**: Verificar si existe CLAUDE-MEMORY.md en la
   carpeta montada. Si existe, mencionarlo proactivamente:
   "Veo que tienes una memoria guardada. ¿Quieres que la cargue?"

2. **Al detectar informacion valiosa**: Si durante la sesion se toman
   decisiones importantes o se resuelven problemas complejos, sugerir:
   "Esto parece importante. ¿Quieres que lo guarde en la memoria?"

3. **Al final de sesion larga**: Si la sesion fue productiva (>10 tool calls),
   recordar: "Hemos hecho bastante hoy. ¿Guardo en la memoria?"
