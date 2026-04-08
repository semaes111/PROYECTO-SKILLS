---
name: writing-plans
description: >
  Escribe planes de implementación comprensivos asumiendo que el ingeniero tiene contexto cero
  y desglosa el trabajo en tareas pequeñas, verificables, con TDD y commits frecuentes.
triggers:
  - writing plans
  - implementation planning
  - task decomposition
  - feature planning
type: workflow
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)
