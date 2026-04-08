---
name: subagent-driven-development
description: >
  Ejecuta planes de implementación despachando subagentes frescos por tarea, con revisión
  en dos etapas (cumplimiento de especificación + calidad de código) después de cada tarea.
triggers:
  - subagent development
  - parallel implementation
  - task execution
  - implementer dispatch
type: workflow
---

# Subagent-Driven Development

Execute plan by dispatching fresh subagent per task, with two-stage review after each: spec compliance review first, then code quality review.

**Why subagents:** You delegate tasks to specialized agents with isolated context. By precisely crafting their instructions and context, you ensure they stay focused and succeed at their task. They should never inherit your session's context or history — you construct exactly what they need. This also preserves your own context for coordination work.

**Core principle:** Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration

## When to Use

**vs. Executing Plans (parallel session):**
- Same session (no context switch)
- Fresh subagent per task (no context pollution)
- Two-stage review after each task: spec compliance first, then code quality
- Faster iteration (no human-in-loop between tasks)
